//
//  SearchTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 02.01.26.
//

import ComposableArchitecture
import SQLiteData
import SwiftUI
import TubeSDK

@Reducer
struct SearchFeature {
    @ObservableState
    struct State {
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
                return .send(
                    .videoFeed(
                        .loadVideosBySearch(TubeSDK.SearchVideoQueryParameters(search: state.search))
                    )
                )
            }
        }
    }
}


struct SearchTab: View {
    @Bindable var store: StoreOf<SearchFeature>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    Text("Searching for \(self.store.state.search)")
                    Feed(store: self.store.scope(state: \.videoFeed, action: \.videoFeed))
                }
            }
            .navigationTitle("Searchable Example")
        }
        .searchable(text: $store.search.sending(\.setSearch))
        .onSubmit(of: .search) {
            self.store.send(.startSearch)
        }
//        .onSubmit {
//            self.store.send(.startSearch)
//        }
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
