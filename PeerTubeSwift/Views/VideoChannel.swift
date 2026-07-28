import ComposableArchitecture
import Dependencies
import SQLiteData
import SwiftUI
import TubeSDK

@Reducer
struct VideoChannelFeature {
  @ObservableState
  struct State: Equatable {
    let host: String
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
      scheme: "https", host: "peertube.wtf")

    var notificationBell: NotificationBellFeature.State

    var instance: Instance?
    var videoChannel: VideoChannel?
    var videoDetails: TubeSDK.VideoDetails?
    var channelName: String?

    var isSubscribedToChannel = false

    // Video list state
    var videos: [TubeSDK.Video] = []
    var isLoadingVideos = false
    var hasLoadedAtLeastOnce = false
    var currentPage = 0
    let pageSize = 15
    var hasMoreVideos = true
  }

  enum Action {
    case loadChannelFromRow(
      channelId: String, channelName: String, avatarUrl: String?, description: String?, host: String
    )
    case channelDetailsLoaded(
      channelId: String, channelName: String, avatarUrl: String?, description: String?, host: String
    )
    case saveChannel(VideoChannel)
    case instanceLoaded(Instance)
    case notificationBell(NotificationBellFeature.Action)
    case subscribeButtonTapped
    case changeSubscriptionState(Bool)
    case subscriptionStateLoaded(Bool, Bool)

    // Video list actions
    case loadVideos
    case loadMoreVideosIfNeeded(currentItem: TubeSDK.Video?)
    case finishLoadingVideos([TubeSDK.Video])
    case videoTapped(TubeSDK.Video)

    case delegate(Delegate)

    enum Delegate: Equatable {
      case navigateToVideo(host: String, videoId: String)
    }
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.notificationBell, action: \.notificationBell) {
      NotificationBellFeature()
    }
    Reduce { state, action in
      switch action {
      case .loadChannelFromRow(
        let channelId, let channelName, let avatarUrl, let description, let host):
        print(
          "🔍 loadChannelFromRow: channelId='\(channelId)', channelName='\(channelName)', host='\(host)'"
        )
        // Set channel name immediately for navigation title
        state.channelName = channelName

        // Fetch full channel details from API to get description
        return .run {
          [
            client = state.client, channelId = channelId, channelName = channelName,
            avatarUrl = avatarUrl, description = description, host = host
          ] send in
          @Dependency(\.defaultDatabase) var database

          do {
            // Fetch full channel details from API
            print("🔍 loadChannelFromRow: Calling getChannel with '\(channelId)'")
            let fullChannel = try await client.getChannel(channelIdentifier: channelId)
            print(
              "🔍 loadChannelFromRow: getChannel success - displayName='\(fullChannel.displayName ?? "nil")'"
            )

            // Update state with full channel info including description
            await send(
              .channelDetailsLoaded(
                channelId: channelId,
                channelName: fullChannel.displayName ?? channelName,
                avatarUrl: fullChannel.avatars?.first?.fileUrl ?? avatarUrl,
                description: fullChannel.description,
                host: host
              ))
          } catch {
            // If API call fails, fall back to basic info from row
            print("🔍 loadChannelFromRow: getChannel FAILED - \(error), using fallback")
            await send(
              .channelDetailsLoaded(
                channelId: channelId,
                channelName: channelName,
                avatarUrl: avatarUrl,
                description: description,
                host: host
              ))
          }

          // Load subscription state
          var localNotificationState = false
          if let subscription = try? await database.read({ db in
            try PeertubeSubscription.where { $0.channelID == channelId }.fetchOne(db)
          }) {
            localNotificationState = subscription.notifyOnNewVideo
          }

          if client.currentToken != nil {
            if let isSubscribed = try? await client.checkSubscription(channelUri: channelId) {
              await send(.subscriptionStateLoaded(isSubscribed, localNotificationState))
            }
          } else {
            let hasLocalSub = try? await database.read { db in
              try PeertubeSubscription.find(channelId).fetchOne(db) != nil
            }
            await send(.subscriptionStateLoaded(hasLocalSub ?? false, localNotificationState))
          }
        }

      case .channelDetailsLoaded(
        let channelId, let channelName, let avatarUrl, let description, let host):
        // Update channel name if we got a better one from API
        if channelName != state.channelName {
          state.channelName = channelName
        }
        // Create a local VideoChannel from the data
        state.videoChannel = VideoChannel(
          id: channelId,
          name: channelName,
          avatarUrl: avatarUrl,
          description: description,
          instanceID: host
        )
        // Also create a minimal VideoDetails so the view has channel info
        state.videoDetails = TubeSDK.VideoDetails(
          channel: TubeSDK.VideoChannel(
            name: channelId.components(separatedBy: "@").first,
            avatars: avatarUrl.flatMap { url in
              [TubeSDK.ActorImage(fileUrl: url)]
            },
            host: host,
            displayName: channelName,
            description: description
          )
        )
        print(
          "🔍 channelDetailsLoaded: videoChannel.id='\(state.videoChannel?.id ?? "nil")', videoDetails.channel.name='\(state.videoDetails?.channel?.name ?? "nil")'"
        )
        // Now load videos (channel details are set)
        return .run { send in
          await send(.notificationBell(.setChannelId(channelId)))
          await send(.loadVideos)
        }

      case .saveChannel(let channel):
        state.videoChannel = channel
        return .run { [client = state.client, channel = channel] send in
          @Dependency(\.defaultDatabase) var database
          var localNotificationState = false
          if let subscription = try? await database.read({ db in
            try PeertubeSubscription.find(channel.id).fetchOne(db)
          }) {
            print("subscription found in table")
            print(subscription)
            localNotificationState = subscription.notifyOnNewVideo
          } else {
            print("Subscription not found in table")
            print(channel.id)
          }

          if client.currentToken != nil {
            if let isSubscribed = try? await client.checkSubscription(channelUri: channel.id) {
              await send(.subscriptionStateLoaded(isSubscribed, localNotificationState))
            }
          } else {
            let hasLocalSub = try? await database.read { db in
              try PeertubeSubscription.find(channel.id).fetchOne(db) != nil
            }
            await send(.subscriptionStateLoaded(hasLocalSub ?? false, localNotificationState))
          }
        }

      case .instanceLoaded(let instance):
        state.instance = instance
        return .none

      case .notificationBell:
        return .none

      case .subscribeButtonTapped:
        let isSubscribed = state.isSubscribedToChannel
        return .send(.changeSubscriptionState(!isSubscribed))

      case .changeSubscriptionState(let newSubscriptionState):
        state.isSubscribedToChannel = newSubscriptionState
        // Capture videoChannel before async block to avoid mutable capture error
        let videoChannel = state.videoChannel
        return .run {
          [
            client = state.client,
            videoDetails = state.videoDetails,
            newSubscriptionState = newSubscriptionState,
            videoChannel = videoChannel
          ] _ in
          @Dependency(\.defaultDatabase) var database

          let channelId: String
          if let videoDetails = videoDetails,
            let channel = videoDetails.channel,
            let channelUsername = channel.name,
            let channelHost = channel.host
          {
            channelId = "\(channelUsername)@\(channelHost)"
          } else if let channel = videoChannel {
            channelId = channel.id
          } else {
            return
          }

          await withErrorReporting {
            if newSubscriptionState {
              try await database.write { db in
                try PeertubeSubscription.insert {
                  PeertubeSubscription.Draft(channelID: channelId, createdAt: .now)
                }.execute(db)
              }
              if client.currentToken != nil {
                try? await client.addSubscription(channelUri: channelId)
              }
            } else {
              try await database.write { db in
                try PeertubeSubscription.where { $0.channelID == channelId }.delete().execute(db)
              }
              if client.currentToken != nil {
                try? await client.removeSubscription(channelUri: channelId)
              }
            }
          }
        }

      case .subscriptionStateLoaded(let isSubscribed, let notifyOnNewVideo):
        state.isSubscribedToChannel = isSubscribed
        return .run { send in
          await send(.notificationBell(.setToggleState(notifyOnNewVideo)))
        }

      case .loadVideos:
        // Determine channel ID from either videoDetails or videoChannel
        let channelId: String
        if let videoDetails = state.videoDetails,
          let channel = videoDetails.channel,
          let channelUsername = channel.name,
          let channelHost = channel.host
        {
          channelId = "\(channelUsername)@\(channelHost)"
        } else if let channel = state.videoChannel {
          channelId = channel.id
        } else {
          print(
            "🔍 loadVideos: FAILED - videoDetails=\(state.videoDetails != nil), videoChannel=\(state.videoChannel != nil)"
          )
          return .none
        }
        print(
          "🔍 loadVideos: channelId='\(channelId)', videoChannel=\(state.videoChannel?.id ?? "nil")")

        state.isLoadingVideos = true
        state.currentPage = 0
        state.videos = []

        return .run {
          [client = state.client, channelId = channelId, pageSize = state.pageSize] send in
          print("🔍 loadVideos API call: channelId='\(channelId)'")
          do {
            let videos = try await client.getVideosPaginated(
              channelIdentifier: channelId,
              start: 0,
              count: pageSize
            )
            print("🔍 loadVideos API success: \(videos.count) videos")
            await send(.finishLoadingVideos(videos))
          } catch {
            print("🔍 loadVideos API error: \(error)")
            await send(.finishLoadingVideos([]))
          }
        }

      case .loadMoreVideosIfNeeded(let currentItem):
        // Load more when user scrolls near the end
        guard let currentItem = currentItem,
          state.hasMoreVideos,
          !state.isLoadingVideos
        else {
          return .none
        }

        // Check if we're near the end (last 3 items)
        let currentIndex = state.videos.firstIndex { $0.uuid == currentItem.uuid } ?? -1
        guard currentIndex >= state.videos.count - 3 else {
          return .none
        }

        // Load more
        let channelId: String
        if let videoDetails = state.videoDetails,
          let channel = videoDetails.channel,
          let channelUsername = channel.name,
          let channelHost = channel.host
        {
          channelId = "\(channelUsername)@\(channelHost)"
        } else if let channel = state.videoChannel {
          channelId = channel.id
        } else {
          return .none
        }

        let nextPage = state.currentPage + 1
        state.isLoadingVideos = true

        return .run {
          [client = state.client, channelId = channelId, pageSize = state.pageSize, nextPage] send
          in
          do {
            let videos = try await client.getVideosPaginated(
              channelIdentifier: channelId,
              start: nextPage * pageSize,
              count: pageSize
            )
            await send(.finishLoadingVideos(videos))
          } catch {
            await send(.finishLoadingVideos([]))
          }
        }

      case .finishLoadingVideos(let newVideos):
        if state.currentPage == 0 {
          state.videos = newVideos
        } else {
          state.videos.append(contentsOf: newVideos)
        }
        state.hasMoreVideos = newVideos.count >= state.pageSize
        state.currentPage += 1
        state.isLoadingVideos = false
        state.hasLoadedAtLeastOnce = true
        return .none

      case .videoTapped(let video):
        guard let videoId = video.uuid?.uuidString else { return .none }
        return .send(.delegate(.navigateToVideo(host: state.host, videoId: videoId)))

      case .delegate:
        return .none
      }
    }
  }
}

struct VideoChannelView: View {
  @Bindable var store: StoreOf<VideoChannelFeature>

  private var channelDisplayName: String {
    store.state.channelName
      ?? store.state.videoDetails?.channel?.displayName
      ?? store.state.videoChannel?.name
      ?? "Channel"
  }

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 16) {
        // Channel header
        channelHeader

        Divider()

        // Videos section
        videosSection
      }
      .padding()
    }
    .navigationTitle(channelDisplayName)
  }

  private var channelHeader: some View {
    VStack(alignment: .leading, spacing: 12) {
      HStack(alignment: .top) {
        AvatarView(
          url: store.state.videoDetails?.channel?.avatars?.first?.fileUrl
            ?? store.state.videoChannel?.avatarUrl,
          name: store.state.videoDetails?.channel?.displayName ?? store.state.videoChannel?.name
            ?? "Unknown Channel",
          size: 60
        )

        VStack(alignment: .leading, spacing: 4) {
          Text(
            store.state.videoDetails?.channel?.displayName ?? store.state.videoChannel?.name
              ?? "Unknown Channel"
          )
          .font(.headline)

          if let instanceName = store.state.videoDetails?.channel?.host
            ?? store.state.videoChannel?.instanceID
          {
            InstanceIndicator(
              instanceName: instanceName, instanceImage: store.state.instance?.avatarUrl)
          }
        }

        Spacer()

        subscribeButton
      }

      // Channel description
      if let description = store.state.videoDetails?.channel?.description
        ?? store.state.videoChannel?.description,
        !description.isEmpty
      {
        Text(description)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(3)
      }
    }
  }

  private var subscribeButton: some View {
    HStack {
      Button(store.state.isSubscribedToChannel ? "Unsubscribe" : "Subscribe") {
        store.send(.subscribeButtonTapped)
      }
      .buttonStyle(.bordered)
      .foregroundStyle(.primary)

      if store.state.isSubscribedToChannel {
        NotificationBell(
          store: store.scope(
            state: \.notificationBell,
            action: \.notificationBell
          )
        )
      }
    }
  }

  private var videosSection: some View {
    VStack(alignment: .leading, spacing: 12) {
      Text("Videos")
        .font(.headline)

      if store.state.isLoadingVideos && store.state.videos.isEmpty {
        ProgressView()
          .frame(maxWidth: .infinity, minHeight: 200)
      } else if store.state.videos.isEmpty && store.state.hasLoadedAtLeastOnce {
        ContentUnavailableView {
          Label("No videos", systemImage: "video")
        } description: {
          Text("This channel doesn't have any videos yet")
        }
      } else {
        LazyVStack(spacing: 16) {
          ForEach(store.state.videos, id: \.uuid) { video in
            VideoCard(
              video: video,
              channelName: channelDisplayName,
              channelAvatarUrl: video.channel?.avatars?.first?.fileUrl,
              instanceHost: store.host,
              instanceAvatarUrl: store.state.instance?.avatarUrl,
              client: store.client,
              onVideoTap: {
                store.send(.videoTapped(video))
              },
              openChannel: {
                // Already in channel view, don't navigate
              }
            )
            .onAppear {
              store.send(.loadMoreVideosIfNeeded(currentItem: video))
            }
          }

          if store.state.isLoadingVideos && !store.state.videos.isEmpty {
            ProgressView()
              .padding()
          }
        }
      }
    }
  }
}

#Preview {
  let _ = prepareDependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }

  return NavigationStack {
    VideoChannelView(
      store: Store(
        initialState: VideoChannelFeature.State(
          host: "peertube.cpy.re",
          notificationBell: NotificationBellFeature.State(
            channelId: "chocopie@peertube.cpy.re",
            isOn: false
          ),
          videoDetails: TubeSDK.VideoDetails(
            channel: TubeSDK.VideoChannel(
              id: 1,
              name: "chocopie",
              host: "peertube.cpy.re",
              displayName: "Choco Pie Channel",
              description:
                "This is a test channel description that shows what the channel is about."
            )
          )
        )
      ) {
        VideoChannelFeature()
      }
    )
  }
}
