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
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
        
        var instance: Instance?
        var videoChannel: VideoChannel?
        var videoDetails: TubeSDK.VideoDetails?
        
        var isSubscribedToChannel = false
        var notifyOnNewVideo = false
    }

    enum Action {
        case loadChannel(TubeSDK.VideoDetails)
        case saveChannel(VideoChannel)
        case subscribeButtonTapped
        case toggleNotificationButtonTapped
        case updateNotificationState(Bool)
        case changeSubscriptionState(Bool)
        case subscriptionStateLoaded(Bool, Bool)
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .loadChannel(let videoDetails):
                return .run { [videoDetails = videoDetails, host = state.host, instance = state.instance] send in
                    @Dependency(\.defaultDatabase) var database

                    guard let instanceId = instance?.id,
                          let channelDetails = videoDetails.channel,
                          let channelId = channelDetails.id,
                          let channelName = channelDetails.displayName,
                          let channelUsername = channelDetails.name,
                          let channelHost = channelDetails.host else { return }

                    let channel = withErrorReporting {
                        return try database.write { db in
                            return try VideoChannel.upsert {
                                VideoChannel(
                                    id: "\(channelUsername)@\(channelHost)",
                                    name: channelName,
                                    avatarUrl: channelDetails.avatars?.first?.fileUrl,
                                    instanceID: instanceId
                                )
                            }.returning(\.self).fetchOne(db)
                        }
                    }
                    if let channel = channel {
                        await send(.saveChannel(channel))
                    }
                }
                
            case .saveChannel(let channel):
                state.videoChannel = channel
                return .run { [client = state.client, channel = channel] send in
                    @Dependency(\.defaultDatabase) var database
                    var localNotificationState = false
                    if let subscription = try? await database.read({ db in
                        try PeertubeSubscription.find(channel.id).fetchOne(db)
                    }) {
                        localNotificationState = subscription.notifyOnNewVideo
                    }

                    if client.currentToken != nil {
                        if let isSubscribed = try? await client.checkSubscription(channelUri: channel.id) {
                            await send(.subscriptionStateLoaded(isSubscribed, localNotificationState))
                        }
                    } else {
                        let hasLocalSub = try? await database.read({ db in
                            try PeertubeSubscription.find(channel.id).fetchOne(db) != nil
                        })
                        await send(.subscriptionStateLoaded(hasLocalSub ?? false, localNotificationState))
                    }
                }
                
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
                return .run { [channel = state.videoChannel, notify = notify] _ in
                    guard let channelId = channel?.id else { return }
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
                return .run { [
                    client = state.client,
                    videoDetails = state.videoDetails,
                    newSubscriptionState = newSubscriptionState
                ] send in
                    @Dependency(\.defaultDatabase) var database

                    guard let videoDetails = videoDetails,
                          let channel = videoDetails.channel,
                          let channelUsername = channel.name,
                          let channelHost = channel.host else { return }

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
                state.notifyOnNewVideo = notifyOnNewVideo
                return .none
            }
        }
    }
}

struct VideoChannelView: View {
    @Bindable var store: StoreOf<VideoChannelFeature>

    var body: some View {
        HStack {
            ZStack(alignment: .bottomLeading) {
                HStack(alignment: .top) {
                    if let avatars = store.state.videoDetails?.channel?.avatars,
                       let avatar = avatars.first,
                       let fileUrl = avatar.fileUrl,
                       let url = URL(string: fileUrl) {
                        AsyncImage(url: url) { image in
                            image.resizable()
                        } placeholder: {
                            Color.secondary
                        }
                        .frame(width: 48, height: 48)
                        .clipShape(.circle)
                    } else {
                        Color.secondary
                            .frame(width: 48, height: 48)
                            .clipShape(.circle)
                    }
                    Text("\(store.state.videoDetails?.channel?.displayName ?? "Unknown Channel")")
                        .lineLimit(1)
                }
                if let instanceName = store.state.videoDetails?.channel?.host {
                    InstanceIndicator(instanceName: instanceName, instanceImage: nil)
                        .padding(.leading, 36)
                }
            }
            Spacer()
            HStack {
                if store.state.isSubscribedToChannel {
                    Button {
                        store.send(.toggleNotificationButtonTapped)
                    } label: {
                        Image(systemName: store.state.notifyOnNewVideo ? "bell.fill" : "bell")
                    }
                    .buttonStyle(.bordered)
                }

                Button(store.state.isSubscribedToChannel ? "Unsubscribe" : "Subscribe") {
                    store.send(.subscribeButtonTapped)
                }
                .buttonStyle(.bordered)
            }
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }

    return VideoChannelView(
        store: Store(
            initialState: VideoChannelFeature.State(
                host: "peertube.cpy.re"
            )
        ) {
            VideoChannelFeature()
        }
    )
}
