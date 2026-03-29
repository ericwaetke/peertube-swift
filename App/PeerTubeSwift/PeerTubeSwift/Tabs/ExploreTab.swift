//
//  ExploreTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import Dependencies
import SQLiteData
import ComposableArchitecture
import SwiftUI
import TubeSDK
import WebURL

extension View {
    @ViewBuilder
    func minimizedSearch() -> some View {
        if #available(iOS 26.0, *) {
            self.searchToolbarBehavior(.minimize)
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
        case videoDetail(VideoDetailsFeature)
        case searchResults(FeedFeature)
        case channelDetail(VideoChannelFeature)
    }
    
    @ObservableState
    struct State: Equatable {
        var path = StackState<Path.State>()
        
        var searchText = String()
        var isSearchActive = false
        
        @Shared(.inMemory("session")) var session: UserSession?
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        
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
        Reduce { state, action in
            switch action {
            case let .path(action):
                switch action {
                case let .element(id: _, action: .exploreFeed(.videoTapped(row: row))):
                    guard let instance = row.instance else {
                        return .none
                    }
                    state.path.append(.videoDetail(VideoDetailsFeature.State(host: instance.host, videoId: row.video.id.uuidString)))
                    return .none

                case let .element(id: _, action: .searchResults(.videoTapped(row: row))):
                    guard let instance = row.instance else {
                        return .none
                    }
                    state.path.append(.videoDetail(VideoDetailsFeature.State(host: instance.host, videoId: row.video.id.uuidString)))
                    return .none

                case let .element(id: _, action: .exploreFeed(.channelTapped(row: row))):
                    guard let channel = row.channel,
                          let instance = row.instance else {
                        return .none
                    }
                    var channelState = VideoChannelFeature.State(host: instance.host)
                    channelState.channelName = channel.name
                    state.path.append(.channelDetail(channelState))
                    // Capture path ID before async block
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

                case let .element(id: _, action: .searchResults(.channelTapped(row: row))):
                    guard let channel = row.channel,
                          let instance = row.instance else {
                        return .none
                    }
                    var channelState = VideoChannelFeature.State(host: instance.host)
                    channelState.channelName = channel.name
                    state.path.append(.channelDetail(channelState))
                    // Capture path ID before async block
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
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
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
                    state: ExploreTabFeature.Path.State.exploreFeed(FeedFeature.State(feedType: .continueWatching))
                )
            }
            NavigationLink(
                "Newest",
                state: ExploreTabFeature.Path.State.exploreFeed(FeedFeature.State(feedType: .exploreNewest))
            )
            NavigationLink(
                "Recommended",
                state: ExploreTabFeature.Path.State.exploreFeed(FeedFeature.State(feedType: .recommended))
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
                settingsMenu
            }
        }
    }
    
    private var settingsMenu: some View {
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
    
    @ViewBuilder
    private func destinationView(for pathStore: StoreOf<ExploreTabFeature.Path>) -> some View {
        switch pathStore.case {
        case let .exploreFeed(store):
            Feed(store: store)
                .navigationTitle(navigationTitle(for: store))
        case let .searchResults(store):
            Feed(store: store)
                .navigationTitle("Search Results")
        case let .videoDetail(store):
            VideoDetails(store: store)
        case let .channelDetail(store):
            VideoChannelView(store: store)
        }
    }
    
    private func navigationTitle(for store: StoreOf<FeedFeature>) -> String {
        switch store.feedType {
        case .exploreNewest:
            return "Newest Videos"
        case .recommended:
            return "Recommended"
        case .subscriptions:
            return "Subscriptions"
        case .search:
            return "Search Results"
        case .continueWatching:
            return "Continue Watching"
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
