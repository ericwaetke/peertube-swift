//
//  ExploreTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct ExploreTabFeature {
    @Reducer
    enum Path {
      case oldExplore(ExploreFeature)
        // case screenB(ScreenB)
    }
    
    @ObservableState
    struct State: Equatable {
      var path = StackState<Path.State>()
    }
    
    enum Action {
        case path(StackActionOf<Path>)
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
                
            case let .path(action):
                switch action {
//                case .element(id: _, action: .exploreFeature(. …)):
//                    return .none
                    
                default:
                    return .none
                }
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
            EmptyView()
        } destination: { store in
            switch store.case {
            case let .oldExplore(store):
                Explore(store: store)
            }
        }
        .navigationTitle("Explore View")
    }
}

#Preview {
  ExploreTab(
    store: Store(initialState: ExploreTabFeature.State()) {
        ExploreTabFeature()
    }
  )
}
