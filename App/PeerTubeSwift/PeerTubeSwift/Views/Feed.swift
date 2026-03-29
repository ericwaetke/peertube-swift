//
//  Feed.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 29.12.25.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI
import TubeSDK

@Selection struct VideoRow: Hashable, Equatable {
    public static func == (lhs: VideoRow, rhs: VideoRow) -> Bool {
        return lhs.video.id == rhs.video.id
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(video.id)
    }
    
    let video: Video
    let channel: VideoChannel?
    let instance: Instance?
}

@Reducer
struct FeedFeature {
    @ObservableState
    struct State: Equatable {
        let feedType: FeedFilter
        
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
        var isLoadingVideos: Bool = false
        var hasLoadedAtLeastOnce: Bool = false
        var order: FeedOrder = .descending
        var errorMessage: String? = nil
        
        @FetchAll var instances: [Instance] = []
        
        //        @FetchAll(VideoRow.none)
        var feed: [VideoRow] = []
    }
    
    enum Action {
        case videoTapped(row: VideoRow)
        case videoOverflowMenuTapped(row: VideoRow, host: String)
        case initialScreenLoad
        case pulledToRefresh
        
        case channelTapped(row: VideoRow)
        case instanceTapped
        case addInstanceButtonTapped
        
        case loadVideos
        case finishLoading([VideoRow])
        
        case loadVideosNewestOfInstance
        case loadRecommendedVideos
        case loadChannelVideos
        case loadSubscriptionVideos
        case loadVideosBySearch(TubeSDK.SearchVideoQueryParameters)
        case loadContinueWatching
        
        case loadingFailed(String)
        case setLoading(Bool)
    }
    
    enum FeedFilter {
        case exploreNewest
        case recommended
        case subscriptions
        case search
        case continueWatching
    }
    
    enum FeedOrder {
        case ascending
        case descending
    }
    
    @Dependency(\.defaultDatabase) var database
    @Dependency(\.authClient) var authClient
    @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator
    
    func fetchLocalVideos(for feedType: FeedFilter) async -> [VideoRow]? {
        return await withErrorReporting {
            return try await database.read { db in
                switch feedType {
                case .exploreNewest, .recommended:
                    let orderedVideos = Video
                        .order { $0.publishDate.desc() }
                        .leftJoin(VideoChannel.all) { $0.channelID.eq($1.id) }
                        .leftJoin(Instance.all) { $0.instanceID.eq($2.host) }
                    
                    return try orderedVideos
                        .select {
                            VideoRow.Columns(
                                video: $0,
                                channel: $1,
                                instance: $2
                            )
                        }
                        .fetchAll(db)
                case .subscriptions:
                    let orderedVideos = Video
                        .order { $0.publishDate.desc() }
                        .join(PeertubeSubscription.all) { $0.channelID.eq($1.channelID) }
                        .leftJoin(VideoChannel.all) { $0.channelID.eq($2.id) }
                        .leftJoin(Instance.all) { $0.instanceID.eq($3.host) }
                    
                    return try orderedVideos
                        .select {
                            VideoRow.Columns(
                                video: $0,
                                channel: $2,
                                instance: $3
                            )
                        }
                        .fetchAll(db)
                case .search:
                    return []
                case .continueWatching:
                    // Query local DB for videos with watch progress
                    // Filter: watched > 1 minute AND remaining > 3 minutes
                    return try Self.fetchAllVideosWithProgress(db: db)
                }
            }
        }
    }
    
    private static func fetchAllVideosWithProgress(db: Database) throws -> [VideoRow] {
        // Fetch all videos ordered by publish date
        let allVideos = Video
            .order { $0.publishDate.desc() }
            .leftJoin(VideoChannel.all) { $0.channelID.eq($1.id) }
            .leftJoin(Instance.all) { $0.instanceID.eq($2.host) }
        
        let rows = try allVideos
            .select {
                VideoRow.Columns(
                    video: $0,
                    channel: $1,
                    instance: $2
                )
            }
            .fetchAll(db)
        
        // Filter for continue watching: watched > 1 minute AND remaining > 3 minutes
        return rows.filter { row in
            guard let currentTime = row.video.currentTime,
                  let duration = row.video.duration,
                  duration > 0 else {
                return false
            }
            let remaining = duration - currentTime
            return currentTime > 60 && remaining > 180
        }
    }
    
    func saveVideos(videos: [TubeSDK.Video], client: TubeSDKClient) async throws -> [VideoRow] {
        var insertedVideos: [VideoRow] = []
        for peertubeVideo in videos {
            guard let channel = peertubeVideo.channel,
                  let videoId = peertubeVideo.uuid,
                  let videoName = peertubeVideo.name,
                  let publishedAt = peertubeVideo.publishedAt,
                  let channelUsername = channel.name,
                  let channelDisplayName = channel.displayName,
                  let instanceHost = channel.host
            else {
                print("Error adding video")
                continue
            }
            
            let video: Optional<VideoRow> = await withErrorReporting {
                let avatarUrl: String? = channel.avatars?.first?.fileUrl
                
                let instance = try await self.peertubeOrchestrator.syncInstanceInfo(instanceHost, database)
                
                return try await database.write { db in
                    let channel = try VideoChannel
                        .upsert {
                            VideoChannel(
                                id: "\(channelUsername)@\(instanceHost)",
                                name: channelDisplayName,
                                avatarUrl: avatarUrl,
                                instanceID: instance.id
                            )
                        }
                        .returning(\.self)
                        .fetchOne(db)
                    
                    var thumbnailUrl: String? = nil
                    if let thumbnailPath = peertubeVideo.thumbnailPath {
                        do {
                            thumbnailUrl = try client.getImageUrl(
                                path: thumbnailPath
                            ).absoluteString
                        } catch {
                            print("could not get thumbnail url")
                        }
                    }
                    
                    let existingTime = try Video.find(videoId).fetchOne(db)?.currentTime
                    
                    let video = try Video
                        .upsert {
                            Video(
                                id: videoId,
                                channelID: "\(channelUsername)@\(instanceHost)",
                                instanceID: instance.id,
                                name: videoName,
                                publishDate: publishedAt,
                                duration: peertubeVideo.duration,
                                currentTime: peertubeVideo.userHistory?.currentTime ?? existingTime,
                                thumbnailUrl: thumbnailUrl
                            )
                        }
                        .returning(\.self)
                        .fetchOne(db)
                    
                    if let inserted = video {
                        return .some(VideoRow(video: inserted, channel: channel, instance: instance))
                    } else {
                        return .none
                    }
                }
            }
            if let video = video {
                insertedVideos.append(video)
            }
        }
        
        return insertedVideos
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .videoTapped(let row):
                let _ = row
                return .none
            case .videoOverflowMenuTapped(let row, let host):
                let _ = row
                return .none
            case .initialScreenLoad:
                return .send(.loadVideos)
            case .loadVideos:
                state.errorMessage = nil
                
                switch state.feedType {
                case .exploreNewest:
                    return .send(.loadVideosNewestOfInstance)
                case .recommended:
                    return .send(.loadRecommendedVideos)
                case .subscriptions:
                    return .send(.loadSubscriptionVideos)
                case .search:
                    return .send(.setLoading(false))
                case .continueWatching:
                    return .send(.loadContinueWatching)
                }
            case .setLoading(let isLoading):
                state.isLoadingVideos = isLoading
                return .none
            case .loadVideosNewestOfInstance:
                return .run { [client = state.client, feedType = state.feedType] send in
                    await send(.setLoading(true))
                    
                    print("Getting new videos from instance")
                    // Get Videos from Peertube (skip DB for Explore tab)
                    
                    let peertubeVideos = try await client.getVideos()
                    
                    // Save to DB for caching and use returned VideoRows (preserves server order)
                    let videos = try await self.saveVideos(videos: peertubeVideos, client: client)
                    
                    await send(.finishLoading(videos))
                }
            case .loadRecommendedVideos:
                return .run { [client = state.client, feedType = state.feedType] send in
                    await send(.setLoading(true))
                    
                    print("Getting recommended videos from instance")
                    
                    // Use -best for logged in users, -hot for not logged in
                    let sort: TubeSDK.VideoSort
                    if client.currentToken != nil {
                        print("User is authenticated, using -best sort for personalized recommendations")
                        sort = TubeSDK.VideoSort(key: TubeSDK.VideoSortKey.best, direction: TubeSDK.SortDirection.descending)
                    } else {
                        print("User is not authenticated, using -hot sort")
                        sort = TubeSDK.VideoSort(key: TubeSDK.VideoSortKey.hot, direction: TubeSDK.SortDirection.descending)
                    }
                    
                    let peertubeVideos = try await client.getVideos(sort: sort)
                    
                    // Save to DB for caching and use returned VideoRows (preserves server order)
                    let videos = try await self.saveVideos(videos: peertubeVideos, client: client)
                    
                    await send(.finishLoading(videos))
                }
            case .loadVideosBySearch(let searchParameters):
                return .run { [client = state.client, searchParameters = searchParameters] send in
                    await send(.setLoading(true))
                    
                    let searchResult = try await client.searchVideos(search: searchParameters)
                    
                    let videos = try await self.saveVideos(videos: searchResult, client: client)
                    await send(.finishLoading(videos ?? []))
                }
            case .loadChannelVideos:
                return .none
            case .loadContinueWatching:
                return .run { [client = state.client, authClient = self.authClient] send in
                    await send(.setLoading(true))
                    
                    // Only fetch if user is authenticated
                    guard client.currentToken != nil else {
                        print("User not authenticated, cannot fetch watch history")
                        await send(.finishLoading([]))
                        return
                    }
                    
                    print("Fetching continue watching videos from server history")
                    
                    do {
                        // Fetch watch history from server
                        let historyVideos = try await client.getMyHistory(count: 20)
                        
                        // Save to DB and get VideoRows
                        let videos = try await self.saveVideos(videos: historyVideos, client: client)
                        
                        // Filter: watched > 1 minute AND remaining > 3 minutes
                        let continueWatchingVideos = videos.filter { row in
                            guard let currentTime = row.video.currentTime,
                                  let duration = row.video.duration,
                                  duration > 0 else {
                                return false
                            }
                            let remaining = duration - currentTime
                            return currentTime > 60 && remaining > 180
                        }
                        
                        await send(.finishLoading(continueWatchingVideos))
                    } catch TubeError.unauthorized {
                        print("Token expired while fetching history")
                        try? await authClient.deleteSession()
                        client.currentToken = nil
                        await send(.finishLoading([]))
                    } catch {
                        print("Error fetching continue watching: \(error)")
                        await send(.finishLoading([]))
                    }
                }
            case .loadSubscriptionVideos:
                return .run { [client = state.client, authClient = self.authClient, feedType = state.feedType, stateFeedEmpty = state.feed.isEmpty] send in
                    let localVideos = await self.fetchLocalVideos(for: feedType)
                    
                    if let localVideos, !localVideos.isEmpty {
                        await send(.finishLoading(localVideos))
                    } else if stateFeedEmpty {
                        await send(.setLoading(true))
                    }
                    
                    print("Getting new videos from subscriptions")
                    
                    if client.currentToken != nil {
                        print("User is authenticated, fetching native subscription feed")
                        do {
                            let peertubeVideos = try await client.getMySubscriptionVideos()
                            let videos = try await self.saveVideos(videos: peertubeVideos, client: client)
                            await send(.finishLoading(videos))
                        } catch TubeError.unauthorized {
                            print("Token expired, attempting to refresh")
                            if let session = try? await authClient.getSession() {
                                let refreshToken = session.token.refreshToken
                                do {
                                    let credentials = try await client.getClientOAuthCredentials()
                                    let newToken = try await client.refresh(refreshToken: refreshToken, client: credentials)
                                    var newSession = session
                                    newSession.token = newToken
                                    try await authClient.saveSession(newSession)
                                    
                                    // Retry
                                    let peertubeVideos = try await client.getMySubscriptionVideos()
                                    let videos = try await self.saveVideos(videos: peertubeVideos, client: client)
                                    await send(.finishLoading(videos))
                                    return
                                } catch {
                                    print("Failed to refresh token: \(error)")
                                    try? await authClient.deleteSession()
                                    client.currentToken = nil
                                    await send(.loadingFailed("Your session has expired. Please log in again."))
                                }
                            } else {
                                try? await authClient.deleteSession()
                                client.currentToken = nil
                                await send(.loadingFailed("Your session has expired. Please log in again."))
                            }
                        } catch {
                            print("Error fetching native subscription feed: \(error)")
                            await send(.loadingFailed("Failed to load feed: \(error.localizedDescription)"))
                        }
                        return
                    }
                    
                    // Fallback for unauthenticated users
                    let subscriptions = try await database.read { db in
                        try PeertubeSubscription
                            .leftJoin(VideoChannel.all) { $0.channelID.eq($1.id) }
                            .select {
                                SubRecord.Columns(
                                    subscription: $0,
                                    channel: $1
                                )
                            }
                            .fetchAll(db)
                    }
                    
                    for subscription in subscriptions {
                        guard let channel = subscription.channel else {
                            continue
                        }
                        
                        let videos = try await client.getVideos(channelIdentifier: channel.id)
                        let _ = try await self.saveVideos(videos: videos, client: client)
                    }
                    
                    // Query the database
                    let videos = await self.fetchLocalVideos(for: feedType)
                    await send(.finishLoading(videos ?? []))
                }
            case let .finishLoading(videos):
                state.feed = videos
                state.isLoadingVideos = false
                state.hasLoadedAtLeastOnce = true
                return .none
            case let .loadingFailed(message):
                state.errorMessage = message
                state.isLoadingVideos = false
                state.hasLoadedAtLeastOnce = true
                return .none
            case .pulledToRefresh:
                return .send(.loadVideos)
            case .channelTapped(let row):
                let _ = row
                return .none
            case .instanceTapped:
                return .none
            case .addInstanceButtonTapped:
                return .none
            }
        }
    }
}

struct Feed: View {
    //    @Environment(AppState.self) private var appState: AppState
    let store: StoreOf<FeedFeature>
    
    var body: some View {
        ScrollView {
            ZStack {
                if let errorMessage = self.store.errorMessage {
                    ContentUnavailableView {
                        Label("Error loading feed", systemImage: "exclamationmark.triangle")
                    } description: {
                        VStack(spacing: 12) {
                            Text(errorMessage)
                            Button("Try Again") {
                                self.store.send(.pulledToRefresh)
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    .containerRelativeFrame([.horizontal, .vertical])
                } else if self.store.isLoadingVideos && self.store.feed.isEmpty {
                    ProgressView()
                        .containerRelativeFrame([.horizontal, .vertical])
                } else if self.store.feed.isEmpty && self.store.hasLoadedAtLeastOnce {
                    if self.store.instances.isEmpty {
                        ContentUnavailableView {
                            Label("Your Feed is empty", systemImage: "video")
                        } description: {
                            Button("Add an Instance to get their latest videos") {
                                self.store.send(.addInstanceButtonTapped)
                            }
                        }
                        .containerRelativeFrame([.horizontal, .vertical])
                    } else {
                        ContentUnavailableView {
                            Label("Your Feed is empty", systemImage: "video")
                        } description: {
                            VStack {
                                Text(
                                    "You have instances added, but they dont seem to have any videos right now"
                                )
                                Button("Reload") {
                                    self.store.send(.pulledToRefresh)
                                }
                            }
                        }
                        .containerRelativeFrame([.horizontal, .vertical])
                        
                    }
                } else {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 350))], alignment: .leading, spacing: 12) {
                        ForEach(self.store.feed, id: \.self) { row in
                            VideoCard(row: row) {
                                self.store.send(.videoTapped(row: row))
                            } openChannel: {
                                self.store.send(.channelTapped(row: row))
                            }
                        }
                    }
                    .padding()
                }
            }
        }
        .task {
            await self.store.send(.initialScreenLoad).finish()
        }
        .refreshable {
            await self.store.send(.pulledToRefresh).finish()
        }
        
    }
}

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }
    
    NavigationStack {
        Feed(
            store: Store(initialState: FeedFeature.State(feedType: .subscriptions)) {
                FeedFeature()
            }
        )
    }
}
