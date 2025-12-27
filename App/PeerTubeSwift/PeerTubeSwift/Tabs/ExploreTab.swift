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
        case screenB(ScreenB)
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
            Form {
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Instances")
                            .font(.title2)
                            .padding(.horizontal, 16)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0...12, id: \.self) { i in
                                    VStack(alignment: .leading) {
                                        Color.secondary
                                            .frame(width: 128, height: 128)
                                            .clipShape(.rect(cornerRadius: 8))
                                        Text("Instance \(i)")
                                    }
                                }
                            }
                        }
                        .contentMargins(.horizontal, 16)
                    }
                }
                
                Section {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Channels")
                            .font(.title2)
                            .padding(.horizontal, 16)
                        ScrollView(.horizontal) {
                            HStack {
                                ForEach(0...12, id: \.self) { i in
                                    VStack(alignment: .leading) {
                                        Color.secondary
                                            .frame(width: 128, height: 128)
                                            .clipShape(.circle)
                                        Text("Channel \(i)")
                                    }
                                }
                            }
                        }
                        .contentMargins(.horizontal, 16)
                    }
                }
                
                NavigationLink(
                  "Newest",
                  state: ExploreTabFeature.Path.State.oldExplore(ExploreFeature.State())
                )
                NavigationLink(
                  "Trending",
                  state: ExploreTabFeature.Path.State.screenB(ScreenB.State())
                )
            }
            .navigationTitle("Explore")
        } destination: { store in
            switch store.case {
            case let .oldExplore(store):
                Explore(store: store)
            case let .screenB(store):
                ScreenBView(store: store)
            }
        }
    }
}

#Preview {
    ExploreTab(
        store: Store(initialState: ExploreTabFeature.State()) {
            ExploreTabFeature()
        }
    )
}
