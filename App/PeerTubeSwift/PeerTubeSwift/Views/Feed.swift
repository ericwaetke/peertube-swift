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
    static func == (lhs: VideoRow, rhs: VideoRow) -> Bool {
        return lhs.video.id == rhs.video.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(video.id)
    }

    let video: Video
    let channel: VideoChannel?
    let instance: Instance?
}

// MARK: - Feed Filter Types (Top-level to allow referencing from FeedCacheActor)

enum FeedFilter: Equatable, Hashable {
    case exploreNewest
    case recommended
    case subscriptions
    case search
    case continueWatching
}

enum FeedOrder: Equatable, Hashable {
    case ascending
    case descending
}

// MARK: - Feed Navigation Feature

/// Shared navigation reducer for feed tabs.
/// Handles video and channel navigation with consistent behavior.
@Reducer
struct FeedNavigationFeature {
    @Reducer
    enum Path {
        case videoDetail(VideoDetailsFeature)
        case channelDetail(VideoChannelFeature)
        case feed(FeedFeature)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
    }

    enum Action {
        case path(StackActionOf<Path>)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                case let .element(id: _, action: .videoDetail(.delegate(.navigateToChannel(host: host, channel: channel)))):
                    guard let channelName = channel.name else {
                        // TODO: Error handeling
                        return .none
                    }
                    let channelIdentifier = "\(channelName)@\(host)"
                    return Self.navigateToChannel(
                        &state.path,
                        host: host,
                        channelIdentifier: channelIdentifier,
                        channelName: channel.name,
                        avatarUrl: channel.avatars?.first?.fileUrl,
                        channelDescription: channel.description
                    )
                case let .element(id: _, action: .channelDetail(.delegate(.navigateToVideo(host: host, videoId: videoId)))):
                    return Self.navigateToVideo(&state.path, host: host, videoId: videoId)
                case let .element(id: _, action: .feed(.videoTapped(row: row))):
                    return Self.navigateToVideoFromRow(&state.path, row: row)
                case let .element(id: _, action: .feed(.channelTapped(row: row))):
                    return Self.navigateToChannelFromRow(&state.path, row: row)
                default:
                    return .none
                }
            }
        }
        .forEach(\.path, action: \.path)
    }

    /// Helper to navigate to a channel with proper state management
    static func navigateToChannel(
        _ path: inout StackState<Path.State>,
        host: String,
        channelIdentifier: String, // Can be Int? from VideoChannelSummary or String?
        channelName: String?,
        avatarUrl: String?,
        channelDescription: String?
    ) -> Effect<Action> {
        guard let channelName = channelName else { return .none }

        var channelState = VideoChannelFeature.State(host: host)
        channelState.channelName = channelName
        path.append(.channelDetail(channelState))

        // Capture path ID before async block
        let pathId = path.ids.last!

        return .run { send in
            await send(.path(.element(
                id: pathId,
                action: .channelDetail(.loadChannelFromRow(
                    channelId: channelIdentifier,
                    channelName: channelName,
                    avatarUrl: avatarUrl,
                    description: channelDescription,
                    host: host
                ))
            )))
        }
    }

    /// Navigate to video detail
    static func navigateToVideo(
        _ path: inout StackState<Path.State>,
        host: String,
        videoId: String
    ) -> Effect<Action> {
        path.append(.videoDetail(VideoDetailsFeature.State(host: host, videoId: videoId)))
        return .none
    }

    /// Navigate to channel from a VideoRow
    static func navigateToChannelFromRow(
        _ path: inout StackState<Path.State>,
        row: VideoRow
    ) -> Effect<Action> {
        guard let channel = row.channel,
              let instance = row.instance
        else {
            return .none
        }

        var channelState = VideoChannelFeature.State(host: instance.host)
        channelState.channelName = channel.name
        path.append(.channelDetail(channelState))

        let pathId = path.ids.last!

        return .run { send in
            await send(.path(.element(
                id: pathId,
                action: .channelDetail(.loadChannelFromRow(
                    channelId: channel.id,
                    channelName: channel.name,
                    avatarUrl: channel.avatarUrl,
                    description: channel.description,
                    host: instance.host
                ))
            )))
        }
    }

    /// Navigate to video from a VideoRow
    static func navigateToVideoFromRow(
        _ path: inout StackState<Path.State>,
        row: VideoRow
    ) -> Effect<Action> {
        guard let instance = row.instance else { return .none }

        path.append(.videoDetail(VideoDetailsFeature.State(host: instance.host, videoId: row.video.id.uuidString)))
        return .none
    }
}

extension FeedNavigationFeature.Path.State: Equatable {}

// MARK: - Shared Settings Menu

/// Shared settings menu component for feed tabs
struct FeedSettingsMenu: View {
    @Binding var searchText: String
    let session: UserSession?
    let onOpenSettings: () -> Void

    var body: some View {
        Menu {
            if let session = session {
                VStack(alignment: .leading) {
                    Text(session.username)
                        .font(.headline)
                    Text(session.host)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Divider()
            } else {
                Text("Not logged in")
                    .font(.headline)
            }

            Divider()

            Button {
                onOpenSettings()
            } label: {
                Label("Settings", systemImage: "gear")
            }
        } label: {
            if let session = session {
                AvatarView(
                    url: session.avatarUrl,
                    name: session.username,
                    size: 32
                )
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 32, height: 32)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Feed Cache Types

/// Cache entry storing videos and timestamp for TTL validation
struct FeedCacheEntry: Equatable {
    let videos: [VideoRow]
    let timestamp: Date
}

/// Feed filter types that can be cached
enum CachedFeedType: String, Equatable, Hashable {
    case exploreNewest
    case recommended
    case subscriptions
    case continueWatching

    init(from feedFilter: FeedFilter) {
        switch feedFilter {
        case .exploreNewest:
            self = .exploreNewest
        case .recommended:
            self = .recommended
        case .subscriptions:
            self = .subscriptions
        case .continueWatching:
            self = .continueWatching
        case .search:
            self = .exploreNewest // Don't cache search results
        }
    }
}

/// Global actor-based cache for feed videos
/// Lives outside of TCA State to survive navigation-based State recreation
actor FeedCacheActor {
    static let shared = FeedCacheActor()

    private var cache: [CachedFeedType: FeedCacheEntry] = [:]
    private let ttl: TimeInterval = 300 // 5 minutes

    private init() {}

    /// Get cached videos for a feed type if valid
    func get(_ feedType: FeedFilter) -> [VideoRow]? {
        let cachedType = CachedFeedType(from: feedType)
        guard let cached = cache[cachedType],
              Date().timeIntervalSince(cached.timestamp) < ttl
        else {
            return nil
        }
        return cached.videos
    }

    /// Store videos in cache with current timestamp
    func set(_ feedType: FeedFilter, videos: [VideoRow]) {
        let cachedType = CachedFeedType(from: feedType)
        cache[cachedType] = FeedCacheEntry(videos: videos, timestamp: Date())
    }

    /// Invalidate cache for a specific feed type
    func invalidate(_ feedType: FeedFilter) {
        let cachedType = CachedFeedType(from: feedType)
        cache.removeValue(forKey: cachedType)
    }

    /// Invalidate all cached feeds
    func invalidateAll() {
        cache.removeAll()
    }
}

// MARK: - FeedFeature

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

        // Pagination state
        var currentOffset: Int = 0
        var isLoadingMore: Bool = false
        var hasMoreVideos: Bool = true

        @FetchAll var instances: [Instance] = []

        ///        @FetchAll(VideoRow.none)
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

        // Pagination actions
        case loadInitialVideos
        case loadSecondBatch
        case loadMoreVideos
        case finishLoadingMore([VideoRow])
        case setLoadingMore(Bool)

        case loadChannelVideos
        case loadSubscriptionVideos
        case loadVideosBySearch(TubeSDK.SearchVideoQueryParameters)
        case loadContinueWatching

        case loadingFailed(String)
        case setLoading(Bool)
    }

    @Dependency(\.defaultDatabase) var database
    @Dependency(\.authClient) var authClient
    @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator

    func fetchLocalVideos(for feedType: FeedFilter) async -> [VideoRow]? {
        return await withErrorReporting {
            try await database.read { db in
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
                  duration > 0
            else {
                return false
            }
            let remaining = duration - currentTime
            return currentTime > 60 && remaining > 180
        }
    }

    /// Save videos to database with parallel network calls but serialized DB writes
    /// This avoids SQLite "database is locked" errors from concurrent writes
    func saveVideos(videos: [TubeSDK.Video], client: TubeSDKClient) async throws -> [VideoRow] {
        // Phase 1: Process all videos concurrently for network calls (syncInstanceInfo)
        let processedVideos = await withTaskGroup(of: (Int, TubeSDK.Video, ProcessedVideoData?).self) { group in
            for (index, peertubeVideo) in videos.enumerated() {
                group.addTask {
                    let data = await self.processVideoNetwork(peertubeVideo: peertubeVideo, client: client)
                    return (index, peertubeVideo, data)
                }
            }

            var results: [(Int, TubeSDK.Video, ProcessedVideoData?)] = []
            for await result in group {
                results.append(result)
            }
            return results.sorted { $0.0 < $1.0 }
        }

        // Phase 2: Batch DB writes in a single transaction to avoid SQLite lock contention
        return try await database.write { db -> [VideoRow] in
            var rows: [VideoRow] = []
            for (_, peertubeVideo, data) in processedVideos {
                guard let data = data,
                      let videoId = peertubeVideo.uuid,
                      let videoName = peertubeVideo.name,
                      let publishedAt = peertubeVideo.publishedAt else { continue }

                let channel = try VideoChannel
                    .upsert {
                        VideoChannel(
                            id: "\(data.channelUsername)@\(data.instanceHost)",
                            name: data.channelDisplayName,
                            avatarUrl: data.avatarUrl,
                            description: data.channelDescription,
                            instanceID: data.instance.id
                        )
                    }
                    .returning(\.self)
                    .fetchOne(db)

                var thumbnailUrl: String? = nil
                // Use bestThumbnailUrl for highest resolution available
                thumbnailUrl = peertubeVideo.bestThumbnailUrl(client: client, size: .medium)

                let existingTime = try Video.find(videoId).fetchOne(db)?.currentTime

                let video = try Video
                    .upsert {
                        Video(
                            id: videoId,
                            channelID: "\(data.channelUsername)@\(data.instanceHost)",
                            instanceID: data.instance.id,
                            name: videoName,
                            publishDate: publishedAt,
                            duration: peertubeVideo.duration,
                            currentTime: peertubeVideo.userHistory?.currentTime ?? existingTime,
                            views: peertubeVideo.views ?? 0,
                            thumbnailUrl: thumbnailUrl
                        )
                    }
                    .returning(\.self)
                    .fetchOne(db)

                if let inserted = video {
                    rows.append(VideoRow(video: inserted, channel: channel, instance: data.instance))
                }
            }
            return rows
        }
    }

    /// Intermediate data structure for processed video info
    private struct ProcessedVideoData {
        let channelUsername: String
        let channelDisplayName: String
        let avatarUrl: String?
        let channelDescription: String?
        let instanceHost: String
        let instance: Instance
    }

    /// Process video network calls (instance sync) - called in parallel
    private func processVideoNetwork(
        peertubeVideo: TubeSDK.Video,
        client _: TubeSDKClient
    ) async -> ProcessedVideoData? {
        guard let channel = peertubeVideo.channel,
              let videoId = peertubeVideo.uuid,
              let videoName = peertubeVideo.name,
              let publishedAt = peertubeVideo.publishedAt,
              let channelUsername = channel.name,
              let channelDisplayName = channel.displayName,
              let instanceHost = channel.host
        else {
            print("Error adding video: missing required fields")
            return nil
        }

        return await withErrorReporting {
            let avatarUrl: String? = channel.avatars?.first?.fileUrl
            // Note: VideoChannelSummary doesn't have description - it's only available in full VideoChannel
            // Description will be fetched when navigating to channel detail

            let instance = try await self.peertubeOrchestrator.syncInstanceInfo(instanceHost, database)

            return ProcessedVideoData(
                channelUsername: channelUsername,
                channelDisplayName: channelDisplayName,
                avatarUrl: avatarUrl,
                channelDescription: nil,
                instanceHost: instanceHost,
                instance: instance
            )
        }
    }

    /// Preload thumbnails in the background (fire-and-forget)
    /// Does not block - runs independently of UI updates
    private func preloadThumbnails(for videos: [VideoRow]) {
        let thumbnailUrls = videos.compactMap { $0.video.thumbnailUrl }
        let orchestrator = peertubeOrchestrator
        let db = database

        // Fire-and-forget - don't block the caller, but log errors for debugging
        Task {
            await withTaskGroup(of: Void.self) { group in
                for url in thumbnailUrls.prefix(10) { // Only preload first 10 thumbnails
                    group.addTask {
                        do {
                            try await orchestrator.cacheImageIfNeeded(url, db)
                        } catch {
                            print("[PRELOAD] Failed to cache thumbnail \(url): \(error)")
                        }
                    }
                }
            }
        }
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case let .videoTapped(row):
                let _ = row
                return .none
            case let .videoOverflowMenuTapped(row, host):
                let _ = row
                return .none
            case .initialScreenLoad:
                return .send(.loadVideos)
            case .loadVideos:
                state.errorMessage = nil
                state.currentOffset = 0
                state.hasMoreVideos = true

                switch state.feedType {
                case .exploreNewest:
                    return .send(.loadInitialVideos)
                case .recommended:
                    return .send(.loadInitialVideos)
                case .subscriptions:
                    return .send(.loadSubscriptionVideos)
                case .search:
                    return .send(.setLoading(false))
                case .continueWatching:
                    return .send(.loadContinueWatching)
                }
            case let .setLoading(isLoading):
                state.isLoadingVideos = isLoading
                return .none
            case .loadInitialVideos:
                return .run { [client = state.client, feedType = state.feedType] send in
                    await send(.setLoading(true))

                    // Check global cache first
                    if let cachedVideos = await FeedCacheActor.shared.get(feedType) {
                        print("[CACHE] Using cached videos for initial load")
                        await send(.finishLoading(cachedVideos))
                        return
                    }

                    // Determine sort based on feed type
                    let sort: TubeSDK.VideoSort?
                    switch feedType {
                    case .recommended:
                        // Use -best for logged in users, -hot for not logged in
                        if client.currentToken != nil {
                            sort = TubeSDK.VideoSort(key: TubeSDK.VideoSortKey.best, direction: TubeSDK.SortDirection.descending)
                        } else {
                            sort = TubeSDK.VideoSort(key: TubeSDK.VideoSortKey.hot, direction: TubeSDK.SortDirection.descending)
                        }
                    default:
                        sort = nil
                    }

                    print("[TIMING] InitialLoad: Starting fetch (4 videos)...")
                    let fetchStart = Date()

                    // Load first 4 videos with pagination
                    let peertubeVideos: [TubeSDK.Video]
                    if let sort = sort {
                        peertubeVideos = try await client.getVideos(sort: sort, count: 4, start: 0)
                    } else {
                        peertubeVideos = try await client.getVideos(count: 4, start: 0)
                    }
                    let apiTime = Date().timeIntervalSince(fetchStart)
                    print("[TIMING] InitialLoad: API call took \(String(format: "%.3f", apiTime))s (\(peertubeVideos.count) videos)")

                    // Save to DB for caching and use returned VideoRows
                    let dbStart = Date()
                    let videos = try await self.saveVideos(videos: peertubeVideos, client: client)
                    let dbTime = Date().timeIntervalSince(dbStart)
                    print("[TIMING] InitialLoad: DB writes took \(String(format: "%.3f", dbTime))s")

                    // Update global cache
                    await FeedCacheActor.shared.set(feedType, videos: videos)

                    // Fire-and-forget image preloading
                    self.preloadThumbnails(for: videos)

                    let totalTime = Date().timeIntervalSince(fetchStart)
                    print("[TIMING] InitialLoad: TOTAL \(String(format: "%.3f", totalTime))s")

                    await send(.finishLoading(videos))

                    // Automatically load second batch (11 more videos)
                    await send(.loadSecondBatch)
                }
            case .loadSecondBatch:
                return .run { [client = state.client, feedType = state.feedType] send in
                    // Show loading spinner for second batch
                    await send(.setLoadingMore(true))

                    // Determine sort based on feed type
                    let sort: TubeSDK.VideoSort?

                    switch feedType {
                    case .recommended:
                        // Use -best for logged in users, -hot for not logged in
                        if client.currentToken != nil {
                            sort = TubeSDK.VideoSort(key: TubeSDK.VideoSortKey.best, direction: TubeSDK.SortDirection.descending)
                        } else {
                            sort = TubeSDK.VideoSort(key: TubeSDK.VideoSortKey.hot, direction: TubeSDK.SortDirection.descending)
                        }
                    default:
                        sort = nil
                    }

                    print("[TIMING] SecondBatch: Starting fetch (11 videos at offset 4)...")
                    let fetchStart = Date()

                    // Load 11 more videos starting at offset 4
                    let peertubeVideos: [TubeSDK.Video]
                    if let sort = sort {
                        peertubeVideos = try await client.getVideos(sort: sort, count: 11, start: 4)
                    } else {
                        peertubeVideos = try await client.getVideos(count: 11, start: 4)
                    }

                    let apiTime = Date().timeIntervalSince(fetchStart)
                    print("[TIMING] SecondBatch: API call took \(String(format: "%.3f", apiTime))s (\(peertubeVideos.count) videos)")

                    // Save to DB for caching and use returned VideoRows
                    let dbStart = Date()
                    let videos = try await self.saveVideos(videos: peertubeVideos, client: client)
                    let dbTime = Date().timeIntervalSince(dbStart)
                    print("[TIMING] SecondBatch: DB writes took \(String(format: "%.3f", dbTime))s")

                    // Update global cache with combined results
                    let currentFeed = await FeedCacheActor.shared.get(feedType) ?? []
                    let combinedVideos = currentFeed + videos
                    await FeedCacheActor.shared.set(feedType, videos: combinedVideos)

                    // Fire-and-forget image preloading
                    self.preloadThumbnails(for: videos)

                    let totalTime = Date().timeIntervalSince(fetchStart)
                    print("[TIMING] SecondBatch: TOTAL \(String(format: "%.3f", totalTime))s")

                    await send(.finishLoadingMore(videos))
                }
            case let .loadVideosBySearch(searchParameters):
                return .run { [client = state.client, searchParameters = searchParameters] send in
                    await send(.setLoading(true))

                    let searchResult = try await client.searchVideos(search: searchParameters)

                    let videos = try await self.saveVideos(videos: searchResult, client: client)
                    await send(.finishLoading(videos))
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
                                  duration > 0
                            else {
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
                // First load (offset 0): replace feed
                if state.currentOffset == 0 {
                    state.feed = videos
                    state.currentOffset = videos.count
                }
                // Second batch or more: append to existing feed
                else {
                    state.feed.append(contentsOf: videos)
                    state.currentOffset += videos.count
                }
                state.isLoadingVideos = false
                state.hasLoadedAtLeastOnce = true
                // If we got any videos, there might be more
                state.hasMoreVideos = videos.count > 0
                return .none
            case .loadMoreVideos:
                return .run { [client = state.client, feedType = state.feedType, offset = state.currentOffset] send in
                    await send(.setLoadingMore(true))

                    // Determine sort based on feed type
                    let sort: TubeSDK.VideoSort?

                    switch feedType {
                    case .recommended:
                        if client.currentToken != nil {
                            sort = TubeSDK.VideoSort(key: TubeSDK.VideoSortKey.best, direction: TubeSDK.SortDirection.descending)
                        } else {
                            sort = TubeSDK.VideoSort(key: TubeSDK.VideoSortKey.hot, direction: TubeSDK.SortDirection.descending)
                        }
                    default:
                        sort = nil
                    }

                    print("[TIMING] LoadMore: Starting fetch at offset \(offset) (15 videos)...")
                    let fetchStart = Date()

                    // Load 15 more videos with current offset
                    let peertubeVideos: [TubeSDK.Video]
                    if let sort = sort {
                        peertubeVideos = try await client.getVideos(sort: sort, count: 15, start: offset)
                    } else {
                        peertubeVideos = try await client.getVideos(count: 15, start: offset)
                    }

                    let apiTime = Date().timeIntervalSince(fetchStart)
                    print("[TIMING] LoadMore: API call took \(String(format: "%.3f", apiTime))s (\(peertubeVideos.count) videos)")

                    // Save to DB for caching and use returned VideoRows
                    let dbStart = Date()
                    let videos = try await self.saveVideos(videos: peertubeVideos, client: client)
                    let dbTime = Date().timeIntervalSince(dbStart)
                    print("[TIMING] LoadMore: DB writes took \(String(format: "%.3f", dbTime))s")

                    // Update global cache with combined results
                    let currentFeed = await FeedCacheActor.shared.get(feedType) ?? []
                    let combinedVideos = currentFeed + videos
                    await FeedCacheActor.shared.set(feedType, videos: combinedVideos)

                    // Fire-and-forget image preloading
                    self.preloadThumbnails(for: videos)

                    let totalTime = Date().timeIntervalSince(fetchStart)
                    print("[TIMING] LoadMore: TOTAL \(String(format: "%.3f", totalTime))s")

                    await send(.finishLoadingMore(videos))
                }
            case let .finishLoadingMore(videos):
                state.feed.append(contentsOf: videos)
                state.currentOffset += videos.count
                state.isLoadingMore = false
                // If we got any videos, there might be more
                state.hasMoreVideos = videos.count > 0
                return .none
            case let .setLoadingMore(isLoading):
                state.isLoadingMore = isLoading
                return .none
            case let .loadingFailed(message):
                state.errorMessage = message
                state.isLoadingVideos = false
                state.hasLoadedAtLeastOnce = true
                return .none
            case .pulledToRefresh:
                return .run { [feedType = state.feedType] send in
                    // Invalidate global cache on refresh
                    await FeedCacheActor.shared.invalidate(feedType)
                    await send(.loadVideos)
                }
            case let .channelTapped(row):
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
    ///    @Environment(AppState.self) private var appState: AppState
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
                    VStack(spacing: 0) {
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

                        // Load More Button
                        if self.store.hasMoreVideos && self.store.hasLoadedAtLeastOnce {
                            Group {
                                if self.store.isLoadingMore {
                                    ProgressView("Loading more...")
                                        .padding()
                                } else {
                                    Button {
                                        self.store.send(.loadMoreVideos)
                                    } label: {
                                        Label("Load More", systemImage: "arrow.down.circle")
                                            .padding()
                                    }
                                    .buttonStyle(.bordered)
                                    .padding(.bottom)
                                }
                            }
                        }
                    }
                }
            }
        }
        .task {
            await self.store.send(.initialScreenLoad).finish()
        }
        .refreshable {
            await self.store.send(.pulledToRefresh).finish()
        }
        .navigationTitle(navigationTitle)
    }

    private var navigationTitle: String {
        switch store.feedType {
        case .exploreNewest: return "Newest Videos"
        case .recommended: return "Recommendations"
        case .subscriptions: return "Subscriptions"
        case .search: return "Search Results"
        case .continueWatching: return "Continue Watching"
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
