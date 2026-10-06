import ComposableArchitecture
import Dependencies
import FontKit
import SQLiteData
import SwiftUI
import TubeSDK

enum ChannelPreviewVariant {
  case regular
  case prominent
}

@Reducer
struct ChannelPreviewFeature {
  @ObservableState
  struct State: Equatable {
    let host: String
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
      scheme: "https", host: "peertube.wtf")

    var userBadge: UserBadgeFeature.State
    var notificationBell: NotificationBellFeature.State
    var videoChannel: TubeSDK.VideoChannel?
    var instance: Instance?
    var isSubscribedToChannel = false
    var variant: ChannelPreviewVariant = .regular
    var language: String?
    var primaryCategory: String?

    init(
      host: String,
      notificationBell: NotificationBellFeature.State,
      videoChannel: TubeSDK.VideoChannel?,
      instance: Instance? = nil,
      isSubscribedToChannel: Bool = false,
      variant: ChannelPreviewVariant = .regular,
      language: String? = nil,
      primaryCategory: String? = nil
    ) {
      self.host = host
      self.notificationBell = notificationBell
      self.videoChannel = videoChannel
      self.instance = instance
      self.isSubscribedToChannel = isSubscribedToChannel
      self.userBadge = UserBadgeFeature.State(
        variant: .medium,
        avatarUrl: videoChannel?.avatars?.first?.fileUrl,
        channelDisplayName: videoChannel?.displayName ?? "Unknown Channel",
        instanceDisplayName: videoChannel?.host ?? "Unknown Community",
        instanceIconUrl: instance?.avatarUrl
      )
      self.variant = variant
      self.language = language
      self.primaryCategory = primaryCategory
    }
  }

  enum Action {
    case notificationBell(NotificationBellFeature.Action)
    case userBadge(UserBadgeFeature.Action)

    case loadChannelPreview(TubeSDK.VideoChannel)
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
      case .userBadge(_):
        return .none

      case .loadChannelPreview(let videoChannel):
        state.videoChannel = videoChannel
        state.userBadge = UserBadgeFeature.State(
          variant: .medium,
          avatarUrl: videoChannel.avatars?.first?.fileUrl,
          channelDisplayName: videoChannel.displayName ?? "Unknown Channel",
          instanceDisplayName: videoChannel.host ?? "Unknown Community",
          instanceIconUrl: state.instance?.avatarUrl
        )
        // Get channel info for subscription
        guard let channelUsername = videoChannel.name,
          let channelHost = videoChannel.host
        else {
          return .none
        }

        let channelId = "\(channelUsername)@\(channelHost)"

        // Fetch instance info for avatar
        return .run {
          [client = state.client, channelHost = channelHost, channelId = channelId] send in
          @Dependency(\.defaultDatabase) var database
          @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator

          await send(.notificationBell(.setChannelId(channelId)))

          // Fetch instance avatar
          if let instanceObj = try? await peertubeOrchestrator.syncInstanceInfo(
            channelHost, database)
          {
            await send(.instanceLoaded(instanceObj))
          }

          // Load subscription state
          var localNotificationState = false
          if let subscription = try? await database.read({ db in
            try PeertubeSubscription.where { $0.channelID.eq(channelId) }.fetchOne(db)
          }) {
            localNotificationState = subscription.notifyOnNewVideo
          }

          if client.currentToken != nil {
            if let isSubscribed = try? await client.checkSubscription(channelUri: channelId) {
              await send(.subscriptionStateLoaded(isSubscribed, localNotificationState))
            }
          } else {
            let hasLocalSub = try? await database.read { db in
              try PeertubeSubscription.where { $0.channelID.eq(channelId) }.fetchOne(db) != nil
            }
            await send(.subscriptionStateLoaded(hasLocalSub ?? false, localNotificationState))
          }
        }

      case .instanceLoaded(let instance):
        state.instance = instance
        if state.userBadge.instanceIconUrl != instance.avatarUrl {
          state.userBadge = UserBadgeFeature.State(
            variant: .medium,
            avatarUrl: state.videoChannel?.avatars?.first?.fileUrl,
            channelDisplayName: state.videoChannel?.displayName ?? "Unknown Channel",
            instanceDisplayName: state.videoChannel?.host ?? "Unknown Community",
            instanceIconUrl: instance.avatarUrl
          )
        }

        return .none

      case .subscribeButtonTapped:
        let isSubscribed = state.isSubscribedToChannel
        return .send(.changeSubscriptionState(!isSubscribed))

      case .changeSubscriptionState(let newSubscriptionState):
        state.isSubscribedToChannel = newSubscriptionState
        let videoChannel = state.videoChannel
        return .run {
          [
            client = state.client,
            videoChannel = videoChannel,
            newSubscriptionState = newSubscriptionState
          ] _ in
          @Dependency(\.defaultDatabase) var database

          guard let videoChannel = videoChannel,
            let channelUsername = videoChannel.name,
            let channelHost = videoChannel.host
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
                try PeertubeSubscription.where { $0.channelID.eq(channelId) }.delete().execute(db)
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
      }
    }
  }
}

struct ChannelPreviewView: View {
  @Bindable var store: StoreOf<ChannelPreviewFeature>

  var body: some View {
    if store.variant == .prominent {
      VStack(alignment: .leading, spacing: 12) {
        mainChannelPreview

        if let description = store.videoChannel?.description {
          Text(description)
            .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 15, relativeTo: .subheadline))
            .foregroundStyle(Color.Label.primary)
        }

        if store.language != nil || store.primaryCategory != nil {
          // Language and Category Tag
          HStack {
            if let language = store.language {
              HStack(spacing: 4) {
                Image(systemName: "globe")
                Text(language)
              }
              .foregroundStyle(Color.Label.primary)
              .padding(.horizontal, 6)
              .padding(.vertical, 3)
              .background(
                RoundedRectangle(cornerRadius: 7)
                  .fill(Color.Fill.secondary)
              )
            }

            if let primaryCategory = store.primaryCategory {
              Text(primaryCategory)
                .foregroundStyle(Color.Label.primary)
                .padding(.horizontal, 6)
                .padding(.vertical, 3)
                .background(
                  RoundedRectangle(cornerRadius: 7)
                    .fill(Color(uiColor: .quaternaryLabel))
                )
            }
          }
        }
      }
      .padding(.horizontal, 12)
      .padding(.vertical, 20)
      .background(
        RoundedRectangle(cornerRadius: 26)
          .fill(.white)
          .stroke(.separator, lineWidth: 0.33)
      )
    } else {
      mainChannelPreview
    }
  }

  @ViewBuilder
  var mainChannelPreview: some View {
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
    HStack(spacing: 4) {
      if store.state.isSubscribedToChannel {
        NotificationBell(
          store: store.scope(
            state: \.notificationBell,
            action: \.notificationBell
          )
        )
      }
      Button(store.state.isSubscribedToChannel ? "Unsubscribe" : "Subscribe") {
        store.send(.subscribeButtonTapped)
      }
      .buttonStyle(RiverButtonSmall(type: store.state.isSubscribedToChannel ? .tinted : .tertiary))
    }
  }
}

#Preview {
  let _ = prepareDependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }

  return VStack {
    Spacer()
    VStack {
      Text("Regular")
      ChannelPreviewView(
        store: Store(
          initialState: ChannelPreviewFeature.State(
            host: "peertube.cpy.re",
            notificationBell: NotificationBellFeature.State(
              channelId: "chocopie@peertube.cpy.re",
              isOn: false
            ),
            videoChannel: TubeSDK.VideoChannel(
              id: 1,
              name: "chocopie",
              host: "peertube.cpy.re",
              displayName: "Choco Pie Channel",
              description: "This is a test channel description."
            ),
            variant: .regular
          )
        ) {
          ChannelPreviewFeature()
        }
      )
    }
    VStack {
      Text("Prominent")
      ChannelPreviewView(
        store: Store(
          initialState: ChannelPreviewFeature.State(
            host: "peertube.cpy.re",
            notificationBell: NotificationBellFeature.State(
              channelId: "chocopie@peertube.cpy.re",
              isOn: false
            ),
            videoChannel: TubeSDK.VideoChannel(
              id: 1,
              name: "chocopie",
              host: "peertube.cpy.re",
              displayName: "Choco Pie Channel",
              description: "This is a test channel description."
            ),
            variant: .prominent,
            language: "EN",
          )
        ) {
          ChannelPreviewFeature()
        }
      )
    }
    Spacer()
  }
  .background(Color(uiColor: .secondarySystemBackground))
}
