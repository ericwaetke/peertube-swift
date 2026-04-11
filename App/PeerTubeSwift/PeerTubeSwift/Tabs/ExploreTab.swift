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
    @Reducer
    enum Path {
        case exploreFeed(FeedFeature)
        case searchResults(FeedFeature)
    }

    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        var navigation = FeedNavigationFeature.State()
        var searchResults = FeedFeature.State(feedType: .search)

        var searchText = String()
        var isSearchActive = false

        @Shared(.inMemory("session")) var session: UserSession?
    }

    enum Action {
        case path(StackActionOf<Path>)
        case navigation(FeedNavigationFeature.Action)
        case searchResults(FeedFeature.Action)

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
        Scope(state: \.searchResults, action: \.searchResults) {
            FeedFeature()
        }
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                case let .element(id: _, action: .exploreFeed(.videoTapped(row: row))):
                    return FeedNavigationFeature.navigateToVideoFromRow(&state.navigation.path, row: row)
                        .map { (action: FeedNavigationFeature.Action) -> ExploreTabFeature.Action in .navigation(action) }

                case let .element(id: _, action: .exploreFeed(.channelTapped(row: row))):
                    return FeedNavigationFeature.navigateToChannelFromRow(&state.navigation.path, row: row)
                        .map { (action: FeedNavigationFeature.Action) -> ExploreTabFeature.Action in .navigation(action) }

                case let .element(id: _, action: .searchResults(.videoTapped(row: row))):
                    return FeedNavigationFeature.navigateToVideoFromRow(&state.navigation.path, row: row)
                        .map { (action: FeedNavigationFeature.Action) -> ExploreTabFeature.Action in .navigation(action) }

                case let .element(id: _, action: .searchResults(.channelTapped(row: row))):
                    return FeedNavigationFeature.navigateToChannelFromRow(&state.navigation.path, row: row)
                        .map { (action: FeedNavigationFeature.Action) -> ExploreTabFeature.Action in .navigation(action) }

                default:
                    return .none
                }

            case let .navigation(.path(action)):
                switch action {
                case let .element(id: _, action: .videoDetail(.delegate(.navigateToChannel(host: host, channel: channel)))):
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
                    .map { (action: FeedNavigationFeature.Action) -> ExploreTabFeature.Action in .navigation(action) }

                default:
                    return .none
                }

            case let .searchResults(action):
                switch action {
                case let .videoTapped(row: row):
                    return FeedNavigationFeature.navigateToVideoFromRow(&state.navigation.path, row: row)
                        .map { (action: FeedNavigationFeature.Action) -> ExploreTabFeature.Action in .navigation(action) }

                case let .channelTapped(row: row):
                    return FeedNavigationFeature.navigateToChannelFromRow(&state.navigation.path, row: row)
                        .map { (action: FeedNavigationFeature.Action) -> ExploreTabFeature.Action in .navigation(action) }

                default:
                    return .none
                }

            case .delegate:
                return .none

            case let .setSearch(text):
                state.searchText = text
                return .none

            case .startSearch:
                guard !state.searchText.isEmpty else { return .none }
                state.path.append(.searchResults(FeedFeature.State(feedType: .search)))
                return .send(.path(.element(id: state.path.ids.last!, action: .searchResults(.loadVideosBySearch(TubeSDK.SearchVideoQueryParameters(search: state.searchText))))))

            case .activateSearch:
                state.isSearchActive = true
                return .none

            case let .setSearchActive(active):
                state.isSearchActive = active
                return .none
            }
        }
        .forEach(\.path, action: \.path)
    }
}

extension ExploreTabFeature.Path.State: Equatable {}

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
                    state: FeedFeature.State(feedType: .continueWatching)
                )
            }
            NavigationLink(
                "Newest",
                state: FeedFeature.State(feedType: .exploreNewest)
            )
            NavigationLink(
                "Recommended",
                state: FeedFeature.State(feedType: .recommended)
            )
        }
        .navigationTitle("Explore")
        .searchable(text: $store.searchText.sending(\.setSearch), isPresented: $store.isSearchActive.sending(\.setSearchActive))
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
        case let .videoDetail(store):
            VideoDetails(store: store)
        case let .channelDetail(store):
            VideoChannelView(store: store)
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }

    ExploreTab(
        store: Store(initialState: ExploreTabFeature.State()) {
            ExploreTabFeature()
        }
    )
}
