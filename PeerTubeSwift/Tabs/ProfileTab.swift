//
//  SettingsTab.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import ComposableArchitecture
import FontKit
import SQLiteData
import SwiftUI
import TubeSDK
import WebURL

@Reducer
enum ProfileTabPath {
    case settings(SettingsFeature)
}
extension ProfileTabPath.State: Equatable {}

@Reducer
struct ProfileTabFeature {
  @ObservableState
    struct State: Equatable {
        var path = StackState<ProfileTabPath.State>()
      var profileTabView = ProfileTabViewFeature.State()
  }

  enum Action {
      case path(StackAction<ProfileTabPath.State, ProfileTabPath.Action>)
      case profileTabView(ProfileTabViewFeature.Action)

  }

  var body: some ReducerOf<Self> {
      Scope(state: \.profileTabView, action: \.profileTabView) {
          ProfileTabViewFeature()
      }
      
    Reduce { state, action in
      switch action {
      case .profileTabView(.accountButtonTapped):
          state.path.append(.settings(SettingsFeature.State(text: "accountButtonTapped")))
          return .none
      case .profileTabView:
          return .none
      case .path(_):
          return .none
      }
    }
    .forEach(\.path, action: \.path)
  }
}

struct ProfileTab: View {
    @Bindable var store: StoreOf<ProfileTabFeature>
    var body: some View {
        NavigationStack(path: $store.scope(state: \.path, action: \.path)) {
            ProfileTabView(store: store.scope(state: \.profileTabView, action: \.profileTabView))
        } destination: { store in
            switch store.case {
            case let .settings(store):
                SettingsView(store: store)
            }
        }
    }
}

#Preview {
    let _ = prepareDependencies {
        try! $0.bootstrapDatabase()
        try! $0.defaultDatabase.seed()
    }
    
    ProfileTab(
        store: Store(initialState: ProfileTabFeature.State()) {
      ProfileTabFeature()
    }
  )
}
