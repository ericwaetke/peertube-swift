//
//  SettingsTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import SQLiteData
import ComposableArchitecture
import SwiftUI
import TubeSDK
import WebURL

@Reducer
struct SettingsTabFeature {
    @ObservableState
    struct State {
        var path = StackState<SettingsPath>()
        
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(scheme: "https", host: "peertube.wtf")
        @Presents var editInstance: InstanceManagerFeature.State?
    }
    
    enum Action {
        case path(StackActionOf<SettingsPath>)
        
        case editInstanceButtonTapped
        case editInstance(PresentationAction<InstanceManagerFeature.Action>)
        case goToCCVideo
        case setClient(TubeSDKClient)
    }

    @Reducer
    struct SettingsPath {
        enum State {

        }
        enum Action {
            
        }
        var body: some ReducerOf<Self> {
            
        }
    }
    
    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .path(_):
                return .none
            case .goToCCVideo:
                return .none
            case .editInstanceButtonTapped:
                guard let url = state.client.instance.urlComponents.url?.absoluteString else {
                    print("Couldnt get current instance url")
                    return .none
                }
                state.editInstance = InstanceManagerFeature.State(instanceUrlString: url)
                return .none
            case let .editInstance(.presented(.delegate(delegate))):
                switch delegate {
                case let .saveNewInstance(url):
                    state.editInstance = nil
                    
                    return .run { send in
                        guard let host = url.host?.serialized else {
                            print("Could not get host")
                            return
                        }
                        
                        do {
                            await send(.setClient(try TubeSDKClient(scheme: url.scheme, host: host)))
                        } catch {
                            print("Couldnt update client")
                            print(error)
                        }
                    }
                }
            case let .setClient(client):
                state.$client.withLock { $0 = client }
                return .none
            case .editInstance:
                return .none
            }
        }
        .ifLet(\.$editInstance, action: \.editInstance) {
            InstanceManagerFeature()
        }
    }
}

struct SettingsTab: View {
    @Bindable var store: StoreOf<SettingsTabFeature>
    var body: some View {
        NavigationStack {
            Form {
                Section("Your Home Instance") {
                    Text("Connected to: \(self.store.client.instance.host)")
                    Button("Change Connected Instance") {
                        self.store.send(.editInstanceButtonTapped)
                    }
                }
                Section("Debugging") {
                    Button("Go to Collective Change Video") {
                        self.store.send(.goToCCVideo)
                    }
                }
            }
            .navigationTitle("Settings")
            .sheet(item: $store.scope(state: \.editInstance, action: \.editInstance)) { store in
                NavigationStack {
                    InstanceManager(store: store)
                        .navigationTitle("Edit Instance")
                        .navigationBarTitleDisplayMode(.inline)
                        .toolbar {
                            ToolbarItem {
                                Button("Save") {
                                    guard let url = store.state.instanceUrl else { return }
                                    
                                    store.send(.delegate(.saveNewInstance(url: url)))
                                }
                                .disabled(!store.state.readyToSaveInstance)
                            }
                        }
                }
            }
        }
    }
}


#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }
    
    SettingsTab(
        store: Store(initialState: SettingsTabFeature.State()) {
            SettingsTabFeature()
        }
    )
}
