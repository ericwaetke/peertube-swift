//
//  App.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import SQLiteData
import ComposableArchitecture
import SwiftUI
import TubeSDK

@Reducer
struct AppFeature {
    @ObservableState
    struct State {
        var selectedTab: TubeTab = .feed
        
        var feedTab = FeedTabFeature.State()
        var exploreTab = ExploreTabFeature.State()
        var settingsTab = SettingsTabFeature.State()
        var searchTab = SearchFeature.State()
    }
    
    enum Action {
        case selectedTabChanged(TubeTab)
        
        case feedTab(FeedTabFeature.Action)
        case exploreTab(ExploreTabFeature.Action)
        case settingsTab(SettingsTabFeature.Action)
        case searchTab(SearchFeature.Action)
    }

    var body: some ReducerOf<AppFeature> {
        Reduce { state, action in
            switch action {
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none
            case .settingsTab(.goToCCVideo):
                state.selectedTab = .explore
                state.exploreTab.path.append(.videoDetail(VideoDetailsFeature.State(host: "peertube.wtf",
                                                                                    videoId: "18QZB6GTN1DRd1LtkeQm22")))
                return .none
            case .feedTab(_), .exploreTab(_), .settingsTab(_), .searchTab(_):
                return .none
            }
        }
        
        Scope(state: \.feedTab, action: \.feedTab) {
            FeedTabFeature()
        }
        Scope(state: \.exploreTab, action: \.exploreTab) {
            ExploreTabFeature()
        }
        Scope(state: \.settingsTab, action: \.settingsTab) {
            SettingsTabFeature()
        }
        Scope(state: \.searchTab, action: \.searchTab) {
            SearchFeature()
        }
    }
}

enum TubeTab {
    case feed
    case explore
    case settings
    case search
}


struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>
    
    var body: some View {
        TabView(selection: $store.selectedTab.sending(\.selectedTabChanged)) {
            // Subscriptions Tab
            Tab(
                "Feed",
                systemImage: "heart",
                value: .feed
            ) {
                FeedTab(
                    store: self.store.scope(state: \.feedTab, action: \.feedTab)
                )
            }
            
            Tab(
                "Explore",
                systemImage: "play.tv",
                value: .explore
            ) {
                ExploreTab(
                    store: self.store.scope(state: \.exploreTab, action: \.exploreTab)
                )
            }
            
            Tab(
                "Settings",
                systemImage: "gear",
                value: .settings,
            ) {
                SettingsTab(
                    store: self.store.scope(state: \.settingsTab, action: \.settingsTab)
                )
            }
            
            Tab(
                "Search",
                systemImage: "magnifyingglass",
                value: .search,
                role: .search
            ) {
                SearchTab(
                    store: self.store.scope(state: \.searchTab, action: \.searchTab)
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
    ContentView(store: Store(initialState: AppFeature.State()) {
        AppFeature()
    })
}
