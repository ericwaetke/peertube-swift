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
        
        @Presents var addInstance: InstanceManagerFeature.State?
    }
    
    enum Action {
        case path(StackActionOf<Path>)
        case addInstanceButtonPressed
        case addInstance(PresentationAction<InstanceManagerFeature.Action>)
        case saveNewInstance
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .addInstanceButtonPressed:
                state.addInstance = InstanceManagerFeature.State()
                return .none
            case .addInstance:
                return .none
            case .saveNewInstance:
                return .none
                
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
        .ifLet(\.$addInstance, action: \.addInstance) {
            InstanceManagerFeature()
        }
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
            .toolbar {
                ToolbarItemGroup(placement: .secondaryAction) {
                    Button {
                        self.store.send(.addInstanceButtonPressed)
                    } label: {
                        Label("Add Instance", systemImage: "plus")
                    }
                }
            }
        } destination: { store in
            switch store.case {
            case let .oldExplore(store):
                Explore(store: store)
            case let .screenB(store):
                ScreenBView(store: store)
            }
        }
        .sheet(item: $store.scope(state: \.addInstance, action: \.addInstance)) { store in
            NavigationStack {
                InstanceManager(store: store)
                .navigationTitle("Add new Instance")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem {
                        Button("Save") {
                            self.store.send(.saveNewInstance)
                        }
                        .disabled(true)
                    }
                }
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
