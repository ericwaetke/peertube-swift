//
//  NextButton.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 09.10.26.
//

import ComposableArchitecture
import SwiftUI

enum O_NextButtonVariant {
  case next
  case login
  case finish

  var label: String {
    switch self {
    case .next:
      return "Next"
    case .login:
      return "Login"
    case .finish:
      return "Finish"
    }
  }
}

@Reducer
struct O_NextButtonFeature {
  @ObservableState
  struct State: Equatable {
    var variant: O_NextButtonVariant = .next
  }

  enum Action {
    case nextButtonTapped(O_NextButtonVariant)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .nextButtonTapped(_):
        return .none
      }
    }
  }
}

struct O_NextButtonView: View {
  let store: StoreOf<O_NextButtonFeature>

  var body: some View {
    Button(store.variant.label) {
      store.send(.nextButtonTapped(store.variant))
    }
    .buttonStyle(RiverButtonLarge(type: .filled))
    .transition(.offset(y: 50).combined(with: .blurReplace))
    .animation(.default, value: store.variant)
  }
}

#Preview {
  O_NextButtonView(
    store: Store(
      initialState: O_NextButtonFeature.State()
    ) {
      O_NextButtonFeature()
    })
}
