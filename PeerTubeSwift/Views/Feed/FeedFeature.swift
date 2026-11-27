//
//  FeedFeature.swift
//  PeerTubeSwift
//

import ComposableArchitecture
import PeerSeekSDK
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

enum FeedFilter: Equatable, Hashable {
  case exploreNewest
  case recommended
  case subscriptions
  case search(String)
  case continueWatching
  case category(String)

  var videoCardVariant: VideoCardVariant {
    switch self {
    case .search, .category:
      .small
    default:
      .large
    }
  }

  var navigationTitle: String {
    switch self {
    case .exploreNewest:
      "Newest Videos"
    case .recommended:
      "Recommendations"
    case .subscriptions:
      "Subscriptions"
    case .search(let string):
      "“\(string)”"
    case .continueWatching:
      "Continue Watching"
    case .category(let string):
      string
    }
  }
}

// MARK: - FeedFeature

@Reducer
struct FeedFeature {
  @ObservableState
  struct State: Equatable {
    let feedType: FeedFilter

    @Shared(.inMemory("client")) var client: TubeSDKClient?
    @Shared(.inMemory("session")) var session: UserSession?
    var isLoadingVideos: Bool = false
    var hasLoadedAtLeastOnce: Bool = false
    var errorMessage: String? = nil

    // Pagination state
    var currentOffset: Int = 0
    var isLoadingMore: Bool = false
    var hasMoreVideos: Bool = true

    @FetchAll var instances: [Instance] = []

    var videoCards: IdentifiedArrayOf<VideoCardFeature.State> = []

    var continueWatching: ContinueWatchingFeature.State = .init()
  }

  enum Action {
    case videoTapped(row: VideoRow)
    case initialScreenLoad
    case pulledToRefresh

    case channelTapped(row: VideoRow)
    case addInstanceButtonTapped

    case videoCards(IdentifiedActionOf<VideoCardFeature>)
    case continueWatching(ContinueWatchingFeature.Action)

    case loadVideos
    case finishLoading([VideoRow])

    // Pagination actions
    case loadInitialVideos
    case loadMoreVideos
    case setLoadingMore(Bool)

    case loadSubscriptionVideos
    case loadVideosBySearch(String)
    case loadVideosByCategory(PeerSeekSDK.Category)
    case loadContinueWatching

    case loadingFailed(String)
    case setLoading(Bool)
  }

  @Dependency(\.defaultDatabase) var database
  @Dependency(\.authClient) var authClient
  @Dependency(\.tubeSDK) var tubeSDK
  @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator
  @Dependency(\.peerSeekClient) var peerSeekClient

  func fetchLocalVideos(for feedType: FeedFilter) async -> [VideoRow]? {
    return await withErrorReporting {
      try await database.read { db in
        switch feedType {
        case .exploreNewest, .recommended:
          let orderedVideos =
            Video
            .order { $0.publishDate.desc() }
            .leftJoin(VideoChannel.all) { $0.channelID.eq($1.id) }
            .leftJoin(Instance.all) { $0.instanceID.eq($2.host) }

          return
            try orderedVideos
            .select {
              VideoRow.Columns(
                video: $0,
                channel: $1,
                instance: $2
              )
            }
            .fetchAll(db)
        case .subscriptions:
          let orderedVideos =
            Video
            .order { $0.publishDate.desc() }
            .join(PeertubeSubscription.all) { $0.channelID.eq($1.channelID) }
            .leftJoin(VideoChannel.all) { $0.channelID.eq($2.id) }
            .leftJoin(Instance.all) { $0.instanceID.eq($3.host) }

          return
            try orderedVideos
            .select {
              VideoRow.Columns(
                video: $0,
                channel: $2,
                instance: $3
              )
            }
            .fetchAll(db)
        case .search, .category:
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
    let allVideos =
      Video
      .order { $0.publishDate.desc() }
      .leftJoin(VideoChannel.all) { $0.channelID.eq($1.id) }
      .leftJoin(Instance.all) { $0.instanceID.eq($2.host) }

    let rows =
      try allVideos
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

  func saveVideos(videos: [AssembledVideo]) async throws -> [VideoRow] {
    let videoRows: [VideoRow] = try await database.write { db -> [VideoRow] in
      var rows: [VideoRow] = []

      for video in videos {
        if try Instance.find(video.instance.host).fetchOne(db) == nil {
          try Instance.insert { video.instance }.execute(db)
        }

        let channel =
          try VideoChannel
          .upsert { video.channel }
          .returning(\.self)
          .fetchOne(db)

        let insertedVideo =
          try Video
          .upsert { Video(assembledVideo: video) }
          .returning(\.self)
          .fetchOne(db)

        if let insertedVideo = insertedVideo {
          rows.append(VideoRow(video: insertedVideo, channel: channel, instance: video.instance))
        }
      }
      return rows
    }

    return videoRows
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
        for url in thumbnailUrls.prefix(10) {  // Only preload first 10 thumbnails
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
      case .videoTapped, .channelTapped, .addInstanceButtonTapped:
        return .none

      case .initialScreenLoad:
        return .send(.loadVideos)

      case .loadVideos:
        return startLoading(&state)

      case .setLoading(let isLoading):
        state.isLoadingVideos = isLoading
        return .none

      case .loadInitialVideos:
        return fetchInitialVideos(state)

      case .loadVideosBySearch(let q):
        return searchVideos(query: q)

      case .loadVideosByCategory(let category):
        return loadVideos(in: category)

      case .loadContinueWatching:
        return fetchContinueWatching(state)

      case .loadSubscriptionVideos:
        return fetchSubscriptionVideos(state)

      case .finishLoading(let rows):
        return finishLoading(&state, rows: rows)

      case .loadMoreVideos:
        return fetchMoreVideos(state)

      case .setLoadingMore(let isLoading):
        state.isLoadingMore = isLoading
        return .none

      case .loadingFailed(let message):
        state.errorMessage = message
        state.isLoadingVideos = false
        state.hasLoadedAtLeastOnce = true
        return .none

      case .pulledToRefresh:
        return refreshFeed(state)

      case .videoCards(.element(id: let id, action: .delegate(.videoTapped))):
        guard let card = state.videoCards[id: id], let row = card.videoRow else { return .none }
        return .send(.videoTapped(row: row))

      case .videoCards(.element(id: let id, action: .delegate(.openChannel))):
        guard let card = state.videoCards[id: id], let row = card.videoRow else { return .none }
        return .send(.channelTapped(row: row))

      case .videoCards:
        return .none

      case .continueWatching(.delegate(.videoTapped(let row))):
        return .send(.videoTapped(row: row))

      case .continueWatching(.delegate(.channelTapped(let row))):
        return .send(.channelTapped(row: row))

      case .continueWatching:
        return .none
      }
    }
    .forEach(\.videoCards, action: \.videoCards) {
      VideoCardFeature()
    }
    Scope(state: \.continueWatching, action: \.continueWatching) {
      ContinueWatchingFeature()
    }
  }

  // MARK: - Effect builders

  /// Resets paging and dispatches the fetch that matches the current feed type.
  private func startLoading(_ state: inout State) -> Effect<Action> {
    state.errorMessage = nil
    state.currentOffset = 0
    state.hasMoreVideos = true

    switch state.feedType {
    case .exploreNewest, .recommended:
      return .send(.loadInitialVideos)
    case .subscriptions:
      return .send(.loadSubscriptionVideos)
    case .search, .category:
      return .send(.setLoading(false))
    case .continueWatching:
      return .send(.loadContinueWatching)
    }
  }

  private func fetchInitialVideos(_ state: State) -> Effect<Action> {
    return .run { [sharedClient = state.$client, feedType = state.feedType] send in
      print("loadInitialVideo")
      await send(.setLoading(true))
      let client = sharedClient.wrappedValue

      // Check global cache first
      if let cachedVideos = await FeedCacheActor.shared.get(feedType) {
        await send(.finishLoading(cachedVideos))
        return
      }

      // Determine sort based on feed type
      let sort: TubeSDK.VideoSort?
      switch feedType {
      case .recommended:
        // Use -best for logged in users, -hot for not logged in
        if let client = client {
          if client.currentToken != nil {
            sort = TubeSDK.VideoSort(
              key: TubeSDK.VideoSortKey.best, direction: TubeSDK.SortDirection.descending)
          } else {
            sort = TubeSDK.VideoSort(
              key: TubeSDK.VideoSortKey.hot, direction: TubeSDK.SortDirection.descending)
          }
        } else {
          // TODO: Implement Peerseek
        }

      default:
        sort = nil
      }

      if let client = client {
        // Load first 4 videos with pagination
        let peertubeVideos: [TubeSDK.Video]
        peertubeVideos = try await client.getVideos(count: 15, start: 0)
        let assembledVideos = try peertubeVideos.map { video in
          try AssembledVideo(tubeVideo: video, client: client)
        }

        let videos = try await self.saveVideos(videos: assembledVideos)

        // Update global cache
        await FeedCacheActor.shared.set(feedType, videos: videos)

        // Fire-and-forget image preloading
        self.preloadThumbnails(for: videos)

        await send(.finishLoading(videos))
      } else {
        // TODO: Use PeerSeek
      }
    }
  }

  private func searchVideos(query q: String) -> Effect<Action> {
    return .run { [peerSeekClient = peerSeekClient, q = q] send in
      await send(.setLoading(true))

      do {
        let searchResult = try await peerSeekClient.search(q: q)
        //            let assembledVideos = searchResult.map { video in
        //                // TODO: Get playback time from db
        //                try await AssembledVideo(seekVideo: video, currentTime: 0)
        //            }
        print("found \(searchResult.count) videos")
        var assembledVideos: [AssembledVideo] = []

        for video in searchResult {
          assembledVideos.append(try await AssembledVideo(seekVideo: video, currentTime: 0))
        }

        print("assembled \(assembledVideos.count) videos")

        let videos = try await self.saveVideos(videos: assembledVideos)
        print("saved \(videos.count) videos")
        await send(.finishLoading(videos))
      } catch {
        print("Search failed with error: \(error)")
        await send(.setLoading(false))
      }
    }
  }

  private func loadVideos(in category: PeerSeekSDK.Category) -> Effect<Action> {
    return .run { [peerSeekClient = peerSeekClient, category = category] send in
      await send(.setLoading(true))

      do {
        let searchResult = try await peerSeekClient.search(q: "", category: category)
        // TODO: Get playback time from db

        print("found \(searchResult.count) videos")
        var assembledVideos: [AssembledVideo] = []

        for video in searchResult {
          assembledVideos.append(try await AssembledVideo(seekVideo: video, currentTime: 0))
        }

        print("assembled \(assembledVideos.count) videos")

        let videos = try await self.saveVideos(videos: assembledVideos)
        print("saved \(videos.count) videos")
        await send(.finishLoading(videos))
      } catch {
        print("Search failed with error: \(error)")
        await send(.setLoading(false))
      }
    }
  }

  private func fetchContinueWatching(_ state: State) -> Effect<Action> {
    return .run { [sharedClient = state.$client, authClient = self.authClient] send in
      await send(.setLoading(true))
      let client = sharedClient.wrappedValue

      guard let client = client else {
        print("No peertube client initialized, cannot fetch watch history")
        await send(.finishLoading([]))
        return
      }

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
        let videos = try await self.saveVideos(
          videos: historyVideos.map({ video in
            try AssembledVideo(tubeVideo: video, client: client)
          }))

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
  }

  private func fetchSubscriptionVideos(_ state: State) -> Effect<Action> {
    return .run {
      [
        sharedClient = state.$client, authClient = self.authClient, tubeSDK = self.tubeSDK,
        feedType = state.feedType, stateFeedEmpty = state.videoCards.isEmpty,
        session = state.session
      ] send in
      let localVideos = await self.fetchLocalVideos(for: feedType)
      let client = sharedClient.wrappedValue

      if let localVideos, !localVideos.isEmpty {
        await send(.finishLoading(localVideos))
      } else if stateFeedEmpty {
        await send(.setLoading(true))
      }

      print("Getting new videos from subscriptions")

      if let client, client.currentToken != nil, let session {
        print("User is authenticated, fetching native subscription feed")
        do {
          let subscriptionClient = try tubeSDK.make("https", session.host, session.token)
          let peertubeVideos = try await subscriptionClient.getMySubscriptionVideos()
          let videos = try await self.saveVideos(
            videos: peertubeVideos.map({ video in
              try AssembledVideo(tubeVideo: video, client: client)
            }))
          await send(.finishLoading(videos))
        } catch TubeError.unauthorized {
          print("Token expired, attempting to refresh")
          if let storedSession = try? await authClient.getSession() {
            let refreshToken = storedSession.token.refreshToken
            do {
              let credentials = try await client.getClientOAuthCredentials()
              let newToken = try await client.refresh(
                refreshToken: refreshToken, client: credentials)
              var newSession = storedSession
              newSession.token = newToken
              try await authClient.saveSession(newSession)

              // Retry with the refreshed session
              let retryClient = try tubeSDK.make("https", newSession.host, newSession.token)
              let peertubeVideos = try await retryClient.getMySubscriptionVideos()
              let videos = try await self.saveVideos(
                videos: peertubeVideos.map({ video in
                  try AssembledVideo(tubeVideo: video, client: client)
                }))
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
      } else {
        print("no authenticated client/session, cant refresh subscriptions")
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

        if let client = client {
          let videos = try await client.getVideos(channelIdentifier: channel.id)
          let _ = try await self.saveVideos(
            videos: videos.map({ video in
              try AssembledVideo(tubeVideo: video, client: client)
            }))
        } else {
          // TODO: Fallback for no client
        }
      }

      // Query the database
      let videos = await self.fetchLocalVideos(for: feedType)
      await send(.finishLoading(videos ?? []))
    }
  }

  private func finishLoading(_ state: inout State, rows: [VideoRow]) -> Effect<Action> {
    let newCards = rows.map {
      VideoCardFeature.State.init(row: $0, variant: state.feedType.videoCardVariant)
    }
    // First load (offset 0): replace
    if state.currentOffset == 0 {
      state.videoCards = IdentifiedArray(uncheckedUniqueElements: newCards)
      state.currentOffset = rows.count
    }
    // Second batch or more: append
    else {
      state.videoCards.append(contentsOf: newCards)
      state.currentOffset += rows.count
    }
    state.isLoadingVideos = false
    state.hasLoadedAtLeastOnce = true
    state.hasMoreVideos = rows.count > 0
    return .none
  }

  private func fetchMoreVideos(_ state: State) -> Effect<Action> {
    return .run {
      [sharedClient = state.$client, feedType = state.feedType, offset = state.currentOffset]
      send in
      if let client = sharedClient.wrappedValue {
        await send(.setLoadingMore(true))

        // Determine sort based on feed type
        let sort: TubeSDK.VideoSort?

        switch feedType {
        case .recommended:

          if client.currentToken != nil {
            sort = TubeSDK.VideoSort(
              key: TubeSDK.VideoSortKey.best, direction: TubeSDK.SortDirection.descending)
          } else {
            sort = TubeSDK.VideoSort(
              key: TubeSDK.VideoSortKey.hot, direction: TubeSDK.SortDirection.descending)
          }

        default:
          sort = nil
        }

        // Load 15 more videos with current offset
        let peertubeVideos: [TubeSDK.Video]
        if let sort = sort {
          peertubeVideos = try await client.getVideos(sort: sort, count: 15, start: offset)
        } else {
          peertubeVideos = try await client.getVideos(count: 15, start: offset)
        }

        // Save to DB for caching and use returned VideoRows
        let videos = try await self.saveVideos(
          videos: peertubeVideos.map({ video in
            try AssembledVideo(tubeVideo: video, client: client)
          }))

        // Update global cache with combined results
        let currentFeed = await FeedCacheActor.shared.get(feedType) ?? []
        let combinedVideos = currentFeed + videos
        await FeedCacheActor.shared.set(feedType, videos: combinedVideos)

        // Fire-and-forget image preloading
        self.preloadThumbnails(for: videos)

        await send(.finishLoading(videos))
      } else {
        // TODO: PeerSeek
      }
    }
  }

  private func refreshFeed(_ state: State) -> Effect<Action> {
    return .run { [feedType = state.feedType] send in
      // Invalidate global cache on refresh
      await FeedCacheActor.shared.invalidate(feedType)
      await send(.loadVideos)
    }
  }
}
