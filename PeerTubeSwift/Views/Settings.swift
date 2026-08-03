//
//  Settings.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 03.08.26.
//

import ComposableArchitecture
import SwiftUI
import TubeSDK

@Reducer
public struct SettingsFeature {
  @ObservableState
  public struct State: Equatable {
      let text: String
  }

  public enum Action {
      case buttonTapped
  }


  public var body: some Reducer<State, Action> {
    Reduce<State, Action> { state, action in
      switch action {
      case .buttonTapped:
          return .none
      }
    }
  }
}

public struct SettingsView: View {
  @Bindable var store: StoreOf<SettingsFeature>

  public var body: some View {
    Form {
      
    }
    .navigationTitle("Settings")
  }
}
