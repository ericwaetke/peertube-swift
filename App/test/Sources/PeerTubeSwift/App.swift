//
//  App.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import ComposableArchitecture
import SQLiteData
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

        @Presents var settingsSheet: SettingsTabFeature.State?

        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
            scheme: "https", host: "peertube.wtf")
        @Shared(.inMemory("session")) var session: UserSession?
    }

    enum Action {
        case task
        case sessionLoaded(UserSession?)
        case syncSubscriptions

        case selectedTabChanged(TubeTab)

        case feedTab(FeedTabFeature.Action)
        case exploreTab(ExploreTabFeature.Action)

        case settingsSheet(PresentationAction<SettingsTabFeature.Action>)
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
            case .sessionLoaded(let session):
                state.isLoaded = true
                state.$session.withLock { $0 = session }
                if let session = session {
                    state.$client.withLock {
                        $0 = try! TubeSDKClient(
                            scheme: "https", host: session.host, token: session.token,
                            session: urlSession)
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
                                guard let host = channel.host, let username = channel.name else {
                                    continue
                                }
                                let id = "\(username)@\(host)"
                                remoteIds.insert(id)

                                let instance =
                                    try Instance
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

                                let exists =
                                    try PeertubeSubscription.where { $0.channelID.eq(id) }.fetchOne(
                                        db) != nil
                                if !exists {
                                    try PeertubeSubscription
                                        .insert {
                                            PeertubeSubscription.Draft(
                                                channelID: id, createdAt: channel.createdAt ?? .now
                                            )
                                        }
                                        .execute(db)
                                }
                            }

                            // Delete local subscriptions that are not in the remote list
                            let localSubs = try PeertubeSubscription.all.fetchAll(db)
                            for localSub in localSubs {
                                if !remoteIds.contains(localSub.channelID) {
                                    try PeertubeSubscription
                                        .where { $0.id.eq(localSub.id) }
                                        .delete()
                                        .execute(db)
                                }
                            }
                        }
                    }
                }
            case .selectedTabChanged(let tab):
                state.selectedTab = tab
                return .none
            case .feedTab(.delegate(.openSettings)):
                state.settingsSheet = SettingsTabFeature.State()
                return .none
            case .exploreTab(.delegate(.openSettings)):
                state.settingsSheet = SettingsTabFeature.State()
                return .none
            case .feedTab(_), .exploreTab:
                return .none
            case .settingsSheet(.presented(.delegate(.didLogin))):
                return .run { send in
                    @Dependency(\.defaultDatabase) var database
                    do {
                        try await database.write { db in
                            try db.execute(sql: "DELETE FROM peertubeSubscriptions")
                            try db.execute(sql: "DELETE FROM videoChannels")
                            try db.execute(sql: "DELETE FROM videos")
                        }
                    } catch {
                        reportIssue(error)
                    }
                    await send(.syncSubscriptions)
                    await send(.feedTab(.subscriptionFeed(.loadVideos)))
                }
            case .settingsSheet(.presented(.delegate(.didLogout))):
                return .run { send in
                    @Dependency(\.defaultDatabase) var database
                    do {
                        try await database.write { db in
                            try db.execute(sql: "DELETE FROM peertubeSubscriptions")
                            try db.execute(sql: "DELETE FROM videoChannels")
                            try db.execute(sql: "DELETE FROM videos")
                        }
                    } catch {
                        reportIssue(error)
                    }
                    await send(.feedTab(.subscriptionFeed(.loadVideos)))
                }
            case .settingsSheet:
                return .none
            }
        }

        Scope(state: \.feedTab, action: \.feedTab) {
            FeedTabFeature()
        }
        Scope(state: \.exploreTab, action: \.exploreTab) {
            ExploreTabFeature()
        }
        .ifLet(\.$settingsSheet, action: \.settingsSheet) {
            SettingsTabFeature()
        }
    }
}

enum TubeTab {
    case feed
    case explore
}

struct ContentView: View {
    @Bindable var store: StoreOf<AppFeature>

    var body: some View {
        Group {
            if store.isLoaded {
                TabView(selection: $store.selectedTab.sending(\.selectedTabChanged)) {
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
                }
            } else {
                ProgressView("Loading...")
            }
        }
        .task {
            await store.send(.task).finish()
        }
        .sheet(item: $store.scope(state: \.settingsSheet, action: \.settingsSheet)) { store in
            NavigationStack {
                SettingsTab(store: store)
                    .toolbar {
                        ToolbarItem(placement: .cancellationAction) {
                            Button("Done") {
                                store.send(.dismiss)
                            }
                        }
                    }
            }
        }
    }
}
