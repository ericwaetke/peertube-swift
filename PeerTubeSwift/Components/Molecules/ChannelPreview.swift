import ComposableArchitecture
import Dependencies
import SQLiteData
import SwiftUI
import TubeSDK

@Reducer
struct ChannelPreviewFeature {
  @ObservableState
  struct State: Equatable {
    let host: String
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
      scheme: "https", host: "peertube.wtf")

    var userBadge: UserBadgeFeature.State
    var notificationBell: NotificationBellFeature.State
    var videoDetails: TubeSDK.VideoDetails?
    var instance: Instance?
    var isSubscribedToChannel = false

    init(
      host: String,
      notificationBell: NotificationBellFeature.State,
      videoDetails: TubeSDK.VideoDetails? = nil,
      instance: Instance? = nil,
      isSubscribedToChannel: Bool = false
    ) {
      self.host = host
      self.notificationBell = notificationBell
      self.videoDetails = videoDetails
      self.instance = instance
      self.isSubscribedToChannel = isSubscribedToChannel
      self.userBadge = UserBadgeFeature.State(
        avatarUrl: videoDetails?.channel?.avatars?.first?.fileUrl,
        channelDisplayName: videoDetails?.channel?.displayName ?? "Unknown Channel",
        instanceDisplayName: videoDetails?.channel?.host ?? "Unknown Community",
        instanceIconUrl: instance?.avatarUrl
      )
    }
  }

  enum Action {
    case notificationBell(NotificationBellFeature.Action)
    case userBadge(UserBadgeFeature.Action)

    case loadChannelPreview(TubeSDK.VideoDetails)
    case instanceLoaded(Instance)
    case subscribeButtonTapped
    case changeSubscriptionState(Bool)
    case subscriptionStateLoaded(Bool, Bool)
    case channelTapped
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.notificationBell, action: \.notificationBell) {
      NotificationBellFeature()
    }
    Reduce { state, action in
      switch action {
      case .notificationBell:
        return .none

      case .loadChannelPreview(let videoDetails):
        state.videoDetails = videoDetails
        state.userBadge = UserBadgeFeature.State(
          avatarUrl: videoDetails.channel?.avatars?.first?.fileUrl,
          channelDisplayName: videoDetails.channel?.displayName ?? "Unknown Channel",
          instanceDisplayName: videoDetails.channel?.host ?? "Unknown Community",
          instanceIconUrl: state.instance?.avatarUrl
        )

        // Get channel info for subscription
        guard let channel = videoDetails.channel,
          let channelUsername = channel.name,
          let channelHost = channel.host
        else {
          return .none
        }

        let channelId = "\(channelUsername)@\(channelHost)"

        // Fetch instance info for avatar
        return .run {
          [client = state.client, channelHost = channelHost, channelId = channelId] send in
          @Dependency(\.defaultDatabase) var database
          @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator

          // Fetch instance avatar
          if let instanceObj = try? await peertubeOrchestrator.syncInstanceInfo(
            channelHost, database)
          {
            await send(.instanceLoaded(instanceObj))
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
              try PeertubeSubscription.where { $0.channelID == channelId }.fetchOne(db) != nil
            }
            await send(.subscriptionStateLoaded(hasLocalSub ?? false, localNotificationState))
          }
        }

      case .instanceLoaded(let instance):
        state.instance = instance
        state.userBadge = UserBadgeFeature.State(
          avatarUrl: state.videoDetails?.channel?.avatars?.first?.fileUrl,
          channelDisplayName: state.videoDetails?.channel?.displayName ?? "Unknown Channel",
          instanceDisplayName: state.videoDetails?.channel?.host ?? "Unknown Community",
          instanceIconUrl: instance.avatarUrl
        )

        return .none

      case .subscribeButtonTapped:
        let isSubscribed = state.isSubscribedToChannel
        return .send(.changeSubscriptionState(!isSubscribed))

      case .changeSubscriptionState(let newSubscriptionState):
        state.isSubscribedToChannel = newSubscriptionState
        let videoDetails = state.videoDetails
        return .run {
          [
            client = state.client,
            videoDetails = videoDetails,
            newSubscriptionState = newSubscriptionState
          ] _ in
          @Dependency(\.defaultDatabase) var database

          guard let videoDetails = videoDetails,
            let channel = videoDetails.channel,
            let channelUsername = channel.name,
            let channelHost = channel.host
          else {
            return
          }

          let channelId = "\(channelUsername)@\(channelHost)"

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

      case .channelTapped:
        return .none
      case .userBadge(_):
        return .none
      }
    }
  }
}

struct ChannelPreviewView: View {
  @Bindable var store: StoreOf<ChannelPreviewFeature>

  private var channelDisplayName: String {
    store.state.videoDetails?.channel?.displayName ?? "Channel"
  }

  var body: some View {
    HStack(alignment: .center, spacing: 12) {
      UserBadge(
        store: store.scope(
          state: \.userBadge,
          action: \.userBadge
        ))

      Spacer()

      subscribeButton
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
}

#Preview {
  let _ = prepareDependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }

  return ChannelPreviewView(
    store: Store(
      initialState: ChannelPreviewFeature.State(
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
            description: "This is a test channel description."
          )
        )
      )
    ) {
      ChannelPreviewFeature()
    }
  )
}
