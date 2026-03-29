import ComposableArchitecture
import Dependencies
import PostHog
import SQLiteData
import SwiftUI
import TubeSDK

@Reducer
struct ChannelPreviewFeature {
    @ObservableState
    struct State: Equatable {
        let host: String
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")

        var videoDetails: TubeSDK.VideoDetails?
        var instance: Instance?

        var isSubscribedToChannel = false
        var notifyOnNewVideo = false
    }

    enum Action {
        case loadChannelPreview(TubeSDK.VideoDetails)
        case instanceLoaded(Instance)
        case subscribeButtonTapped
        case toggleNotificationButtonTapped
        case updateNotificationState(Bool)
        case changeSubscriptionState(Bool)
        case subscriptionStateLoaded(Bool, Bool)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadChannelPreview(let videoDetails):
                state.videoDetails = videoDetails

                // Get channel info for subscription
                guard let channel = videoDetails.channel,
                      let channelUsername = channel.name,
                      let channelHost = channel.host else {
                    return .none
                }

                let channelId = "\(channelUsername)@\(channelHost)"

                // Fetch instance info for avatar
                return .run { [client = state.client, channelHost = channelHost, channelId = channelId] send in
                    @Dependency(\.defaultDatabase) var database
                    @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator

                    // Fetch instance avatar
                    if let instanceObj = try? await peertubeOrchestrator.syncInstanceInfo(channelHost, database) {
                        await send(.instanceLoaded(instanceObj))
                    }

                    // Load subscription state
                    var localNotificationState = false
                    if let subscription = try? await database.read({ db in
                        try PeertubeSubscription.find(channelId).fetchOne(db)
                    }) {
                        localNotificationState = subscription.notifyOnNewVideo
                    }

                    if client.currentToken != nil {
                        if let isSubscribed = try? await client.checkSubscription(channelUri: channelId) {
                            await send(.subscriptionStateLoaded(isSubscribed, localNotificationState))
                        }
                    } else {
                        let hasLocalSub = try? await database.read({ db in
                            try PeertubeSubscription.find(channelId).fetchOne(db) != nil
                        })
                        await send(.subscriptionStateLoaded(hasLocalSub ?? false, localNotificationState))
                    }
                }

            case .instanceLoaded(let instance):
                state.instance = instance
                return .none

            case .subscribeButtonTapped:
                let isSubscribed = state.isSubscribedToChannel
                return .send(.changeSubscriptionState(!isSubscribed))

            case .toggleNotificationButtonTapped:
                let currentNotificationState = state.notifyOnNewVideo
                return .run { send in
                    let center = UNUserNotificationCenter.current()
                    let settings = await center.notificationSettings()

                    if settings.authorizationStatus == .notDetermined {
                        let granted = try? await center.requestAuthorization(options: [.alert, .sound])
                        if granted == true {
                            await send(.updateNotificationState(!currentNotificationState))
                        }
                    } else if settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional {
                        await send(.updateNotificationState(!currentNotificationState))
                    }
                }

            case .updateNotificationState(let notify):
                state.notifyOnNewVideo = notify
                return .run { [videoDetails = state.videoDetails, notify = notify] _ in
                    guard let videoDetails = videoDetails,
                          let channel = videoDetails.channel,
                          let channelUsername = channel.name,
                          let channelHost = channel.host else { return }

                    let channelId = "\(channelUsername)@\(channelHost)"
                    @Dependency(\.defaultDatabase) var database
                    try? await database.write { db in
                        try PeertubeSubscription
                            .where { $0.channelID == channelId }
                            .update { $0.notifyOnNewVideo = notify }
                            .execute(db)
                    }
                }

            case .changeSubscriptionState(let newSubscriptionState):
                state.isSubscribedToChannel = newSubscriptionState
                let videoDetails = state.videoDetails
                return .run { [
                    client = state.client,
                    videoDetails = videoDetails,
                    newSubscriptionState = newSubscriptionState
                ] send in
                    @Dependency(\.defaultDatabase) var database

                    guard let videoDetails = videoDetails,
                          let channel = videoDetails.channel,
                          let channelUsername = channel.name,
                          let channelHost = channel.host else {
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
                            PostHogSDK.shared.capture("channel_subscribed", properties: ["channel_id": channelId])
                        } else {
                            try await database.write { db in
                                try PeertubeSubscription.where { $0.channelID == channelId }.delete().execute(db)
                            }
                            if client.currentToken != nil {
                                try? await client.removeSubscription(channelUri: channelId)
                            }
                            PostHogSDK.shared.capture("channel_unsubscribed", properties: ["channel_id": channelId])
                        }
                    }
                }

            case .subscriptionStateLoaded(let isSubscribed, let notifyOnNewVideo):
                state.isSubscribedToChannel = isSubscribed
                state.notifyOnNewVideo = notifyOnNewVideo
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
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top) {
                AvatarView(
                    url: store.state.videoDetails?.channel?.avatars?.first?.fileUrl,
                    name: store.state.videoDetails?.channel?.displayName ?? "Unknown Channel",
                    size: 60
                )

                VStack(alignment: .leading, spacing: 4) {
                    Text(store.state.videoDetails?.channel?.displayName ?? "Unknown Channel")
                        .font(.headline)

                    if let instanceHost = store.state.videoDetails?.channel?.host {
                        InstanceIndicator(instanceName: instanceHost, instanceImage: store.state.instance?.avatarUrl)
                    }
                }

                Spacer()

                subscribeButton
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
                Button {
                    store.send(.toggleNotificationButtonTapped)
                } label: {
                    Image(systemName: store.state.notifyOnNewVideo ? "bell.fill" : "bell")
                }
                .buttonStyle(.bordered)
                .foregroundStyle(.primary)
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
