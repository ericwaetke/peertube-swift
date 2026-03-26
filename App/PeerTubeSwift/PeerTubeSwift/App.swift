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
    struct State: Equatable {
        var isLoaded = false
        var selectedTab: TubeTab = .feed
        
        var feedTab = FeedTabFeature.State()
        var exploreTab = ExploreTabFeature.State()
        var settingsTab = SettingsTabFeature.State()
        var searchTab = SearchFeature.State()
        
        var playingVideo: VideoDetailsFeature.State?
        var videoPresentation: VideoPresentationState = .hidden
        
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
        
        case playingVideoAction(VideoDetailsFeature.Action)
        case setVideoPresentation(VideoPresentationState)
        case closeGlobalVideo
    }

    @Dependency(\.authClient) var authClient
    @Dependency(\.urlSession) var urlSession

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
                        $0 = try! TubeSDKClient(scheme: "https", host: session.host, token: session.token, session: urlSession)
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
                                            name: channel.displayName ?? username,
                                            avatarUrl: channel.avatars?.first?.fileUrl,
                                            instanceID: instance.id
                                        )
                                    }
                                    .execute(db)
                                
                                let exists = try PeertubeSubscription.where { $0.channelID == id }.fetchOne(db) != nil
                                if !exists {
                                    try PeertubeSubscription
                                        .insert {
                                            PeertubeSubscription.Draft(
                                                channelID: id, createdAt: channel.createdAt ?? .now)
                                        }
                                        .execute(db)
                                }
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
                state.playingVideo = VideoDetailsFeature.State(host: "peertube.wtf", videoId: "18QZB6GTN1DRd1LtkeQm22")
                state.videoPresentation = .expanded
                return .none
                
            case let .searchTab(.videoFeed(.videoTapped(row: row))),
                 let .feedTab(.subscriptionFeed(.videoTapped(row: row))),
                 let .exploreTab(.path(.element(id: _, action: .exploreFeed(.videoTapped(row: row))))):
                
                guard let instance = row.instance else {
                    return .none
                }
                state.playingVideo = VideoDetailsFeature.State(host: instance.host, videoId: row.video.id.uuidString)
                state.videoPresentation = .expanded
                return .none
                
            case .feedTab(_), .exploreTab(_), .settingsTab(_), .searchTab(_):
                return .none
                
            case let .setVideoPresentation(presentation):
                state.videoPresentation = presentation
                return .none
                
            case .closeGlobalVideo:
                state.playingVideo = nil
                state.videoPresentation = .hidden
                return .none
            case .playingVideoAction:
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
        self.ifLet(\.playingVideo, action: \.playingVideoAction) {
            VideoDetailsFeature()
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
        .overlay(alignment: .bottom) {
            if store.videoPresentation != .hidden, let videoStore = store.scope(state: \.playingVideo, action: \.playingVideoAction) {
                GlobalVideoPlayerView(
                    store: videoStore,
                    presentationState: store.videoPresentation,
                    onStateChange: { state in
                        store.send(.setVideoPresentation(state))
                    },
                    onClose: {
                        store.send(.closeGlobalVideo)
                    }
                )
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

