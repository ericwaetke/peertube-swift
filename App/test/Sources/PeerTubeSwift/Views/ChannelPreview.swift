import ComposableArchitecture
import Dependencies
import SQLiteData
import SwiftUI
import TubeSDK
import UIKit

@Reducer
struct ChannelPreviewFeature {
    @ObservableState
    struct State: Equatable {
        let host: String
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
            scheme: "https", host: "peertube.wtf")

        @Presents var alert: AlertState<AlertAction>?

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
        case updateAlertState(AlertState<AlertAction>?)
        case changeSubscriptionState(Bool)
        case subscriptionStateLoaded(Bool, Bool)
        case channelTapped
        case alert(PresentationAction<AlertAction>)
    }

    enum AlertAction: Equatable {
        case openSettings
        case dismiss
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadChannelPreview(let videoDetails):
                state.videoDetails = videoDetails

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
                    [client = state.client, channelHost = channelHost, channelId = channelId] send
                    in
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
                        try PeertubeSubscription.find(channelId).fetchOne(db)
                    }) {
                        localNotificationState = subscription.notifyOnNewVideo
                    }

                    if client.currentToken != nil {
                        if let isSubscribed = try? await client.checkSubscription(
                            channelUri: channelId)
                        {
                            await send(
                                .subscriptionStateLoaded(isSubscribed, localNotificationState))
                        }
                    } else {
                        let hasLocalSub = try? await database.read { db in
                            try PeertubeSubscription.find(channelId).fetchOne(db) != nil
                        }
                        await send(
                            .subscriptionStateLoaded(hasLocalSub ?? false, localNotificationState))
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
                    let status = await checkNotificationPermission()
                    switch status {
                    case .notDetermined:
                        let granted = await requestNotificationPermission()
                        if granted {
                            await send(.updateNotificationState(!currentNotificationState))
                        }
                    case .allowed:
                        await send(.updateNotificationState(!currentNotificationState))
                    case .denied:
                        await send(
                            .updateAlertState(
                                AlertState {
                                    TextState("Notifications Disabled")
                                } actions: {
                                    ButtonState(role: .cancel) {
                                        TextState("Cancel")
                                    }
                                    ButtonState(action: .openSettings) {
                                        TextState("Open Settings")
                                    }
                                } message: {
                                    TextState(
                                        "Enable notifications in Settings to receive alerts when this channel posts new videos."
                                    )
                                }))
                    }
                }

            case .updateAlertState(let alertState):
                state.alert = alertState
                return .none

            case .updateNotificationState(let notify):
                state.notifyOnNewVideo = notify
                return .run { [videoDetails = state.videoDetails, notify = notify] _ in
                    guard let videoDetails = videoDetails,
                        let channel = videoDetails.channel,
                        let channelUsername = channel.name,
                        let channelHost = channel.host
                    else { return }

                    let channelId = "\(channelUsername)@\(channelHost)"
                    try? await saveNotificationPreference(channelId: channelId, notify: notify)
                }

            case .alert(.presented(.openSettings)):
                return .run { _ in
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        @Dependency(\.openURL) var openURL
                        await openURL(url)
                    }
                }

            case .alert(.dismiss):
                state.alert = nil
                return .none

            case .alert(.presented(.dismiss)):
                state.alert = nil
                return .none

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
                                    PeertubeSubscription.Draft(
                                        channelID: channelId, createdAt: .now)
                                }.execute(db)
                            }
                            if client.currentToken != nil {
                                try? await client.addSubscription(channelUri: channelId)
                            }
                        } else {
                            try await database.write { db in
                                try PeertubeSubscription.where { $0.channelID.eq(channelId) }
                                    .delete().execute(db)
                            }
                            if client.currentToken != nil {
                                try? await client.removeSubscription(channelUri: channelId)
                            }
                        }
                    }
                }

            case .subscriptionStateLoaded(let isSubscribed, let notifyOnNewVideo):
                state.isSubscribedToChannel = isSubscribed
                state.notifyOnNewVideo = notifyOnNewVideo
                return .none

            case .channelTapped:
                return .none
            }
        }
        .ifLet(\.$alert, action: \.alert)
    }
}

struct ChannelPreviewView: View {
    @Bindable var store: StoreOf<ChannelPreviewFeature>

    private var channelDisplayName: String {
        store.state.videoDetails?.channel?.displayName ?? "Channel"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                store.send(.channelTapped)
            } label: {
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
                            InstanceIndicator(
                                instanceName: instanceHost,
                                instanceImage: store.state.instance?.avatarUrl)
                        }

                        Spacer()
                    }
                }
            }
            .buttonStyle(.plain)

            subscribeButton
        }
        .alert($store.scope(state: \.alert, action: \.alert))
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
