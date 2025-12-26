//
//  SettingsTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import ComposableArchitecture
import SwiftUI

@Reducer
struct SettingsTabFeature {
    struct State {
        var path = StackState<SettingsPath>()
    }
    
    enum Action {
        case path(StackActionOf<SettingsPath>)
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
}

struct SettingsTab: View {
    let store: StoreOf<SettingsTabFeature>
    var body: some View {
        NavigationStack {
            Text("Settings")
        }
    }
}
