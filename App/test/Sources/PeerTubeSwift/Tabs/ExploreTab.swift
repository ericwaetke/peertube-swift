//
//  ExploreTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import ComposableArchitecture
import Dependencies
import SQLiteData
import SwiftUI
import TubeSDK
import WebURL

extension View {
    @ViewBuilder
    func minimizedSearch() -> some View {
        if #available(iOS 26.0, *) {
            searchToolbarBehavior(.minimize)
        } else {
            self
        }
    }
}

@Reducer
struct ExploreTabFeature {
    @ObservableState
    struct State: Equatable {
        var navigation = FeedNavigationFeature.State()

        var searchText = String()
        var isSearchActive = false

        @Shared(.inMemory("session")) var session: UserSession?
    }

    enum Action {
        case navigation(FeedNavigationFeature.Action)

        case setSearch(String)
        case startSearch
        case activateSearch
        case setSearchActive(Bool)

        case delegate(Delegate)

        enum Delegate {
            case openSettings
        }
    }

    var body: some ReducerOf<Self> {
        Scope(state: \.navigation, action: \.navigation) {
            FeedNavigationFeature()
        }
        Reduce { state, action in
            switch action {
            case .navigation(.path(let action)):
                switch action {
                case .element(
                    id: _,
                    action: .videoDetail(
                        .delegate(.navigateToChannel(host: let host, channel: let channel)))):
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
                    .map { (action: FeedNavigationFeature.Action) -> ExploreTabFeature.Action in
                        .navigation(action)
                    }

                case .element(
                    id: _,
                    action: .channelDetail(
                        .delegate(.navigateToVideo(host: let host, videoId: let videoId)))):
                    return FeedNavigationFeature.navigateToVideo(
                        &state.navigation.path, host: host, videoId: videoId
                    )
                    .map { (action: FeedNavigationFeature.Action) -> ExploreTabFeature.Action in
                        .navigation(action)
                    }

                default:
                    return .none
                }

            case .delegate:
                return .none

            case .setSearch(let text):
                state.searchText = text
                return .none

            case .startSearch:
                guard !state.searchText.isEmpty else { return .none }
                state.navigation.path.append(.feed(FeedFeature.State(feedType: .search)))
                return .send(
                    .navigation(
                        .path(
                            .element(
                                id: state.navigation.path.ids.last!,
                                action: .feed(
                                    .loadVideosBySearch(
                                        TubeSDK.SearchVideoQueryParameters(search: state.searchText)
                                    ))))))

            case .activateSearch:
                state.isSearchActive = true
                return .none

            case .setSearchActive(let active):
                state.isSearchActive = active
                return .none
            }
        }
    }
}

struct ExploreTab: View {
    @Bindable var store: StoreOf<ExploreTabFeature>

    var body: some View {
        NavigationStack(path: $store.scope(state: \.navigation.path, action: \.navigation.path)) {
            contentView
        } destination: { pathStore in
            destinationView(for: pathStore)
        }
    }

    @ViewBuilder
    private var contentView: some View {
        Form {
            if store.session != nil {
                // Only show Continue Watching for logged-in users
                NavigationLink(
                    "Continue Watching",
                    state: FeedNavigationFeature.Path.State.feed(
                        FeedFeature.State(feedType: .continueWatching))
                )
            }
            NavigationLink(
                "Newest",
                state: FeedNavigationFeature.Path.State.feed(
                    FeedFeature.State(feedType: .exploreNewest))
            )
            NavigationLink(
                "Recommended",
                state: FeedNavigationFeature.Path.State.feed(
                    FeedFeature.State(feedType: .recommended))
            )
        }
        .navigationTitle("Explore")
        .searchable(
            text: $store.searchText.sending(\.setSearch),
            isPresented: $store.isSearchActive.sending(\.setSearchActive)
        )
        .onSubmit(of: .search) {
            self.store.send(.startSearch)
        }
        .minimizedSearch()
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                FeedSettingsMenu(
                    searchText: $store.searchText.sending(\.setSearch),
                    session: store.session,
                    onOpenSettings: { store.send(.delegate(.openSettings)) }
                )
            }
        }
    }

    @ViewBuilder
    private func destinationView(for pathStore: StoreOf<FeedNavigationFeature.Path>) -> some View {
        switch pathStore.case {
        case .videoDetail(let store):
            VideoDetails(store: store)
        case .channelDetail(let store):
            VideoChannelView(store: store)
        case .feed(let store):
            Feed(store: store)
        }
    }
}
