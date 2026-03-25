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
        var order: FeedOrder = .descending
        
        @FetchAll var instances: [Instance] = []
        
        //        @FetchAll(VideoRow.none)
        var feed: [VideoRow] = []
        
        let columns = Array(repeating: GridItem(.flexible()), count: 2)
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
        case loadChannelVideos
        case loadSubscriptionVideos
        case loadVideosBySearch(TubeSDK.SearchVideoQueryParameters)
    }
    
    enum FeedFilter {
        case exploreNewest
        case subscriptions
        case search
    }
    
    enum FeedOrder {
        case ascending
        case descending
    }
    
    @Dependency(\.defaultDatabase) var database
    
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
                return try await database.write { db in
                    let avatarUrl: String? = channel.avatars?.first?.fileUrl
                    
                    let instance = try Instance
                        .upsert { Instance(host: instanceHost, scheme: "https") }
                        .returning(\.self)
                        .fetchOne(db)
                    
                    guard let instance = instance else {
                        return .none
                    }
                    
                    let channel = try VideoChannel
                        .upsert {
                            VideoChannel(
                                id: "\(channelUsername)@\(instanceHost)",
                                name: channelDisplayName,
                                avatarUrl: avatarUrl,
                                instanceID: instance.id,
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
                    
                    let video = try Video
                        .upsert {
                            Video(
                                id: videoId,
                                channelID: "\(channelUsername)@\(instanceHost)",
                                instanceID: instance.id,
                                name: videoName,
                                publishDate: publishedAt,
                                duration: peertubeVideo.duration,
                                currentTime: peertubeVideo.userHistory?.currentTime,
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
                if (state.feed.isEmpty) {
                    state.isLoadingVideos = true
                }
                
                switch state.feedType {
                case .exploreNewest:
                    return .send(.loadVideosNewestOfInstance)
                case .subscriptions:
                    return .send(.loadSubscriptionVideos)
                case .search:
                    state.isLoadingVideos = false
                    return .none
                }
            case .loadVideosNewestOfInstance:
                return .run { [client = state.client] send in
                    print("Getting new videos from instance")
                    // Get Videos from Peertube
                    
                    let peertubeVideos = try await client.getVideos()
                    
//                    await send(.saveVideos(peertubeVideos))
                    let _ = try await self.saveVideos(videos: peertubeVideos, client: client)
                    
                    let videos = await withErrorReporting {
                        return try await database.read { db in
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
                        }
                    }
                    
                    await send(.finishLoading(videos ?? []))
                }
            case .loadVideosBySearch(let searchParameters):
                return .run { [client = state.client, searchParameters = searchParameters] send in
                    let searchResult = try await client.searchVideos(search: searchParameters)
                    
                    let videos = try await self.saveVideos(videos: searchResult, client: client)
                    await send(.finishLoading(videos ?? []))
                }
            case .loadChannelVideos:
                return .none
            case .loadSubscriptionVideos:
                return .run { [client = state.client] send in
                    print("Getting new videos from subscriptions")
                    
                    if client.currentToken != nil {
                        print("User is authenticated, fetching native subscription feed")
                        do {
                            let peertubeVideos = try await client.getMySubscriptionVideos()
                            let videos = try await self.saveVideos(videos: peertubeVideos, client: client)
                            await send(.finishLoading(videos))
                        } catch {
                            print("Error fetching native subscription feed: \(error)")
                            await send(.finishLoading([]))
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
                    let videos = await withErrorReporting {
                        return try await database.read { db in
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
                        }
                    }
                    
                    await send(.finishLoading(videos ?? []))
                }
            case let .finishLoading(videos):
                state.feed = videos
                state.isLoadingVideos = false
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
        ZStack {
            if self.store.isLoadingVideos {
                ProgressView()
            } else if self.store.feed.isEmpty {
                if self.store.instances.isEmpty {
                    ContentUnavailableView {
                        Label("Your Feed is empty", systemImage: "video")
                    } description: {
                        Button("Add an Instance to get their latest videos") {
                            self.store.send(.addInstanceButtonTapped)
                        }
                    }
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
        .task {
            await self.store.send(.initialScreenLoad).finish()
        }
        .refreshable {
            self.store.send(.pulledToRefresh)
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
