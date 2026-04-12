//
//  FeedTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI
import TubeSDK

@Reducer
struct FeedTabFeature {
    @ObservableState
    struct State: Equatable {
        var navigation = FeedNavigationFeature.State()
        var subscriptionFeed = FeedFeature.State(feedType: .subscriptions)

        @Presents var manageSubscriptions: SubscriptionFeature.State?

        @Shared(.inMemory("session")) var session: UserSession?

        var searchText = ""
    }

    enum Action {
        case navigation(FeedNavigationFeature.Action)

        case subscriptionFeed(FeedFeature.Action)
        case manageSubscriptionButtonTapped
        case manageSubsctiptions(PresentationAction<SubscriptionFeature.Action>)

        case delegate(Delegate)

        enum Delegate {
            case openSettings
        }
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.navigation, action: \.navigation) {
            FeedNavigationFeature()
        }
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

            case let .navigation(.path(action)):
                switch action {
                case let .element(id: _, action: .videoDetail(.delegate(.navigateToChannel(host: host, channel: channel)))):
                    // Map FeedNavigationFeature.Action to FeedTabFeature.Action
                    guard let channelName = channel.name else {
                        // TODO: Error handeling
                        return .none
                    }
                    let channelIdentifier = "\(channelName)@\(host)"
                    return FeedNavigationFeature.navigateToChannel(
                        &state.navigation.path,
                        host: host,
                        channelIdentifier: channelIdentifier,
                        channelName: channel.name,
                        avatarUrl: channel.avatars?.first?.fileUrl,
                        channelDescription: channel.description
                    )
                    .map { (action: FeedNavigationFeature.Action) -> FeedTabFeature.Action in .navigation(action) }

                case let .element(id: _, action: .channelDetail(.delegate(.navigateToVideo(host: host, videoId: videoId)))):
                    return FeedNavigationFeature.navigateToVideo(&state.navigation.path, host: host, videoId: videoId)
                        .map { (action: FeedNavigationFeature.Action) -> FeedTabFeature.Action in .navigation(action) }

                default:
                    return .none
                }

            case let .subscriptionFeed(action):
                switch action {
                case let .videoTapped(row: row):
                    return FeedNavigationFeature.navigateToVideoFromRow(&state.navigation.path, row: row)
                        .map { (action: FeedNavigationFeature.Action) -> FeedTabFeature.Action in .navigation(action) }

                case let .channelTapped(row: row):
                    return FeedNavigationFeature.navigateToChannelFromRow(&state.navigation.path, row: row)
                        .map { (action: FeedNavigationFeature.Action) -> FeedTabFeature.Action in .navigation(action) }

                default:
                    return .none
                }

            case .delegate:
                return .none
            }
        }
        .ifLet(\.$manageSubscriptions, action: \.manageSubsctiptions) {
            SubscriptionFeature()
        }
    }
}

struct FeedTab: View {
    @Bindable var store: StoreOf<FeedTabFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.navigation.path, action: \.navigation.path)) {
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
        } destination: { pathStore in
            switch pathStore.case {
            case let .videoDetail(store):
                VideoDetails(store: store)
            case let .channelDetail(store):
                VideoChannelView(store: store)
            case let .feed(store):
                Feed(store: store)
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
