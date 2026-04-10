//
//  FeedTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

@Reducer
struct FeedTabFeature {
    @Reducer
    enum Path {
        case videoDetail(VideoDetailsFeature)
        case channelDetail(VideoChannelFeature)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var subscriptionFeed = FeedFeature.State(feedType: .subscriptions)

        @Presents var manageSubscriptions: SubscriptionFeature.State?

        @Shared(.inMemory("session")) var session: UserSession?
    }

    enum Action {
        case path(StackActionOf<Path>)

        case subscriptionFeed(FeedFeature.Action)
        case manageSubscriptionButtonTapped
        case manageSubsctiptions(PresentationAction<SubscriptionFeature.Action>)

        case delegate(Delegate)

        enum Delegate {
            case openSettings
        }
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.subscriptionFeed, action: \.subscriptionFeed) {
            FeedFeature()
        }
        Reduce { state, action in
            switch action {
            case .manageSubscriptionButtonTapped:
                state.manageSubscriptions = SubscriptionFeature.State()
                return .none
            case .manageSubsctiptions:
                return .none
            case let .path(action):
                switch action {
                case let .element(id: _, action: .videoDetail(.delegate(.navigateToChannel(host: host, channelName: channelName)))):
                    var channelState = VideoChannelFeature.State(host: host)
                    channelState.channelName = channelName
                    state.path.append(.channelDetail(channelState))
                    return .none

                default:
                    return .none
                }
            case let .subscriptionFeed(action):
                switch action {
                case let .videoTapped(row: row):
                    guard let instance = row.instance else {
                        return .none
                    }
                    state.path.append(.videoDetail(VideoDetailsFeature.State(host: instance.host, videoId: row.video.id.uuidString)))
                    return .none

                case let .channelTapped(row: row):
                    guard let channel = row.channel,
                          let instance = row.instance
                    else {
                        return .none
                    }
                    var channelState = VideoChannelFeature.State(host: instance.host)
                    channelState.channelName = channel.name
                    state.path.append(.channelDetail(channelState))
                    // Load channel data from the row - capture path ID before async block
                    let pathId = state.path.ids.last!
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

                default:
                    return .none
                }
            case .delegate:
                return .none
            }
        }
        .forEach(\.path, action: \.path)
        .ifLet(\.$manageSubscriptions, action: \.manageSubsctiptions) {
            SubscriptionFeature()
        }
    }
}

struct FeedTab: View {
    @Bindable var store: StoreOf<FeedTabFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            Feed(store: self.store.scope(state: \.subscriptionFeed, action: \.subscriptionFeed))
                .navigationTitle("Subscriptions")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            if let session = store.session {
                                VStack(alignment: .leading) {
                                    Text(session.username)
                                        .font(.headline)
                                    Text(session.host)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                Divider()

                                Button {
                                    self.store.send(.manageSubscriptionButtonTapped)
                                } label: {
                                    Label("Manage Subscriptions", systemImage: "heart")
                                }
                            } else {
                                Text("Not logged in")
                                    .font(.headline)
                            }

                            Divider()

                            Button {
                                self.store.send(.delegate(.openSettings))
                            } label: {
                                Label("Settings", systemImage: "gear")
                            }
                        } label: {
                            if let session = store.session {
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
        } destination: { store in
            switch store.case {
            case let .videoDetail(store):
                VideoDetails(store: store)
            case let .channelDetail(store):
                VideoChannelView(store: store)
            }
        }
        .sheet(item: $store.scope(state: \.manageSubscriptions, action: \.manageSubsctiptions)) { store in
            NavigationStack {
                Subscriptions(store: store)
                    .navigationTitle("Manage Subscriptions")
                    .navigationBarTitleDisplayMode(.inline)
            }
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }

    FeedTab(
        store: Store(initialState: FeedTabFeature.State()) {
            FeedTabFeature()
        }
    )
}

extension FeedTabFeature.Path.State: Equatable {}
