//
//  00_Onboarding.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 21.09.26.
//

//
//  LaunchScreen.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.09.26.
//

import ComposableArchitecture
import FontKit
import SwiftUI

enum OnboardingStepCount: Int {
  case withLogin = 5
  case withoutLogin = 4
}

@Reducer
struct OnboardingFeature {
  @ObservableState
  struct State: Equatable {
    var backButtonVisible = false
    var nextButtonVisible = false
    var onboardingStepCount: OnboardingStepCount = .withoutLogin

    // 01 Launch Screen
    var launchScreen: OnboardingLaunchScreenFeature.State

    // 02 Language Selection
  }

  enum Action {
    case showBackButton
    case hideBackButton
    case showNextButton
    case hideNextButton
    case setOnboardingStepCount(OnboardingStepCount)

    case backButtonTapped
    case nextButtonTapped

    // 01 Launch Screen
    case launchScreen(OnboardingLaunchScreenFeature.Action)
  }

  var body: some Reducer<State, Action> {
    Scope(state: \.launchScreen, action: \.launchScreen) {
      OnboardingLaunchScreenFeature()
    }
    Reduce { state, action in
      switch action {
      case .showBackButton:
        state.backButtonVisible = true
        return .none
      case .hideBackButton:
        state.backButtonVisible = false
        return .none
      case .showNextButton:
        state.nextButtonVisible = true
        return .none
      case .hideNextButton:
        state.nextButtonVisible = false
        return .none
      case .setOnboardingStepCount(let stepCount):
        state.onboardingStepCount = stepCount
        return .none

      case .backButtonTapped:
        return .none
      case .nextButtonTapped:
        return .none

      // 01 Launch Screen
      case .launchScreen(.startWithoutAccountButtonTapped):
        return .run { send in
          await send(.showBackButton)
          await send(.showNextButton)
        }
      case .launchScreen(.usePeerTubeAccountButtonTapped):
        return .none
      case .launchScreen(.infoButtonTapped):
        return .none
      }
    }
  }
}

struct OnboardingView: View {
  let store: StoreOf<OnboardingFeature>

  var body: some View {
    ZStack(alignment: .bottom) {
      HStack {
        OnboardingLaunchScreenView(
          store: store.scope(state: \.launchScreen, action: \.launchScreen)
        )
      }
      HStack {
        if store.backButtonVisible {
          Button("Back") {
            store.send(.backButtonTapped)
          }
          .buttonStyle(RiverButtonLarge(type: .gray))
          .transition(.blurReplace)
        }
        Spacer()
        if store.nextButtonVisible {
          Button("Next") {
            store.send(.nextButtonTapped)
          }
          .buttonStyle(RiverButtonLarge(type: .filled))
          .transition(.blurReplace)
        }
      }
      .padding()
      .animation(.default, value: store.state.backButtonVisible)
      .animation(.default, value: store.state.nextButtonVisible)
    }
  }
}

#Preview {
  OnboardingView(
    store: Store(
      initialState: OnboardingFeature.State(
        launchScreen: OnboardingLaunchScreenFeature.State()
      )
    ) {
      OnboardingFeature()
    }
  )
}
