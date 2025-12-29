//
//  SettingsTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import SQLiteData
import ComposableArchitecture
import SwiftUI

@Reducer
struct SettingsTabFeature {
    struct State {
        var path = StackState<SettingsPath>()
    }
    
    enum Action {
        case path(StackActionOf<SettingsPath>)
        
        case goToCCVideo
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
            }
        }
    }
}

struct SettingsTab: View {
    let store: StoreOf<SettingsTabFeature>
    var body: some View {
        NavigationStack {
            Form {
                Button("Go to Collective Change Video") {
                    self.store.send(.goToCCVideo)
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
