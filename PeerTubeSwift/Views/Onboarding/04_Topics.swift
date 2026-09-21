//
//  04_Topics.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 21.09.26.
//

import ComposableArchitecture
import FontKit
import SwiftUI

@Reducer
struct OnboardingTopicsFeature {
  @ObservableState
  struct State: Equatable {

  }

  enum Action {

  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {

      }
    }
  }
}

struct OnboardingTopicsView: View {
  let store: StoreOf<OnboardingTopicsFeature>
  let locale: Locale = .current

  var body: some View {
    Text("Topics")
  }

}

#Preview {
  NavigationStack {
    OnboardingTopicsView(
      store: Store(initialState: OnboardingTopicsFeature.State()) {
        OnboardingTopicsFeature()
      }
    )
  }
}
