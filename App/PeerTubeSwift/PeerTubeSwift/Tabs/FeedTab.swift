//
//  FeedTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import SQLiteData
import ComposableArchitecture
import SwiftUI

@Reducer
struct FeedTabFeature {
    @Reducer
    enum Path {
        case videoDetail(VideoDetailsFeature)
    }
    
    @ObservableState
    struct State {
        var path = StackState<Path.State>()
        var subscriptionFeed = FeedFeature.State(feedType: .subscriptions)
        
        @Presents var manageSubscriptions: SubscriptionFeature.State?
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        
        case subscriptionFeed(FeedFeature.Action)
        case manageSubscriptionButtonTapped
        case manageSubsctiptions(PresentationAction<SubscriptionFeature.Action>)
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
                return .none
//                switch action {
//                case let .element(id: _, action: .fe(.videoTapped(row: row))):
//                    guard let instance = row.instance else {
//                        return .none
//                    }
//                    state.path.append(.videoDetail(VideoDetailsFeature.State(host: instance.host, videoId: row.video.id.uuidString)))
//                    return .none
//                    
//                default:
//                    return .none
//                }
            case let .subscriptionFeed(action):
                switch action {
                    
                case .videoTapped(row: let row):
                    guard let instance = row.instance else {
                        return .none
                    }
                    state.path.append(.videoDetail(VideoDetailsFeature.State(host: instance.host, videoId: row.video.id.uuidString)))
                    return .none
                    
                default:
                    return .none
                }
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
            ScrollView {
                Feed(store: self.store.scope(state: \.subscriptionFeed, action: \.subscriptionFeed))
            }
            .navigationTitle("Subscriptions")
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button {
                        self.store.send(.manageSubscriptionButtonTapped)
                    } label: {
                        Label("Manage Subscriptions", systemImage: "heart")
                    }
                }
            }
        } destination: { store in
            switch store.case {
            case let .videoDetail(store):
                VideoDetails(store: store)
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
