//
//  SearchTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 02.01.26.
//

import ComposableArchitecture
import PostHog
import SQLiteData
import SwiftUI
import TubeSDK

@Reducer
struct SearchFeature {
    @ObservableState
    struct State: Equatable {
        var search = String()
        
        var videoFeed = FeedFeature.State(feedType: .search)
    }
    
    enum Action {
        case setSearch(String)
        
        case videoFeed(FeedFeature.Action)
        
        case startSearch
    }
    
    var body: some ReducerOf<Self>{
        Scope(state: \.videoFeed, action: \.videoFeed) {
            FeedFeature()
        }
        Reduce { state, action in
            switch action {
            case let .setSearch(search):
                state.search = search
                return .none
            case .videoFeed(_):
                return .none
            case .startSearch:
                print("searching for: \(state.search)")
                return .merge(
                    .send(
                        .videoFeed(
                            .loadVideosBySearch(TubeSDK.SearchVideoQueryParameters(search: state.search))
                        )
                    ),
                    .run { [search = state.search] _ in
                        PostHogSDK.shared.capture("search_performed", properties: ["query": search])
                    }
                )
            }
        }
    }
}


struct SearchTab: View {
    @Bindable var store: StoreOf<SearchFeature>
    
    var body: some View {
        NavigationStack {
            Feed(store: self.store.scope(state: \.videoFeed, action: \.videoFeed))
                .navigationTitle("Search")
        }
        .searchable(text: $store.search.sending(\.setSearch))
        .onSubmit(of: .search) {
            self.store.send(.startSearch)
        }
    }
}


#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }
    
    SearchTab(
        store: Store(initialState: SearchFeature.State()) {
            SearchFeature()
        }
    )
}
