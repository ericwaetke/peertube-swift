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
        var isLoaded = false
        var selectedTab: TubeTab = .feed
        
        var feedTab = FeedTabFeature.State()
        var exploreTab = ExploreTabFeature.State()
        var settingsTab = SettingsTabFeature.State()
        var searchTab = SearchFeature.State()
        
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
    }
    
    enum Action {
        case task
        case sessionLoaded(UserSession?)
        case syncSubscriptions
        
        case selectedTabChanged(TubeTab)
        
        case feedTab(FeedTabFeature.Action)
        case exploreTab(ExploreTabFeature.Action)
        case settingsTab(SettingsTabFeature.Action)
        case searchTab(SearchFeature.Action)
    }

    @Dependency(\.authClient) var authClient

    var body: some ReducerOf<AppFeature> {
        Reduce { state, action in
            switch action {
            case .task:
                return .run { send in
                    let session = try? await authClient.getSession()
                    await send(.sessionLoaded(session))
                }
            case let .sessionLoaded(session):
                state.isLoaded = true
                if let session = session {
                    state.$client.withLock {
                        $0 = try! TubeSDKClient(scheme: "https", host: session.host, token: session.token)
                    }
                    return .run { send in
                        await send(.syncSubscriptions)
                    }
                }
                return .none
            case .syncSubscriptions:
                return .run { [client = state.client] _ in
                    @Dependency(\.defaultDatabase) var database
                    if let remoteSubs = try? await client.getMySubscriptions() {
                        try? await database.write { db in
                            var remoteIds = Set<String>()
                            for channel in remoteSubs {
                                guard let host = channel.host, let username = channel.name else { continue }
                                let id = "\(username)@\(host)"
                                remoteIds.insert(id)
                                
                                let instance = try Instance
                                    .upsert {
                                        Instance(host: host, scheme: "https")
                                    }
                                    .returning(\.self)
                                    .fetchOne(db)
                                
                                guard let instance = instance else { continue }
                                
                                try VideoChannel
                                    .upsert {
                                        VideoChannel(
                                            id: id,
                                            name: channel.displayName ?? channel.name,
                                            avatarUrl: channel.avatars?.first?.fileUrl,
                                            instanceID: instance.id
                                        )
                                    }
                                    .execute(db)
                                
                                try PeertubeSubscription
                                    .insert {
                                        PeertubeSubscription.Draft(
                                            channelID: id, createdAt: channel.createdAt ?? .now)
                                    }
                                    .onConflict { _, _ in }
                                    .execute(db)
                            }
                            
                            // Delete local subscriptions that are not in the remote list
                            let localSubs = try PeertubeSubscription.all.fetchAll(db)
                            for localSub in localSubs {
                                if !remoteIds.contains(localSub.channelID) {
                                    try PeertubeSubscription
                                        .where { $0.id == localSub.id }
                                        .delete()
                                        .execute(db)
                                }
                            }
                        }
                    }
                }
            case let .selectedTabChanged(tab):
                state.selectedTab = tab
                return .none
            case .settingsTab(.goToCCVideo):
                state.selectedTab = .explore
                state.exploreTab.path.append(.videoDetail(VideoDetailsFeature.State(host: "peertube.wtf",
                                                                                    videoId: "18QZB6GTN1DRd1LtkeQm22")))
                return .none
            case .searchTab(.videoFeed(.videoTapped(let row))):
                state.selectedTab = .explore
                guard let instance = row.instance else {
                    return .none
                }
                state.exploreTab.path.append(.videoDetail(VideoDetailsFeature.State(host: instance.host, videoId: row.video.id.uuidString)))
//                state.exploreTab.path.append(.videoDetail(VideoDetailsFeature.State(host: videoRow.,
//                                                                                    videoId: "18QZB6GTN1DRd1LtkeQm22")))
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
        Group {
            if store.isLoaded {
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
            } else {
                ProgressView("Loading...")
            }
        }
        .task {
            await store.send(.task).finish()
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
