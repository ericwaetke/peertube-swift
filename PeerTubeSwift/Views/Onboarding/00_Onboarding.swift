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

enum OnboardingStep {
  case launchScreen
  case preferedLanguage

  var stepIndex: Int {
    switch self {
    case .launchScreen: 0
    case .preferedLanguage: 1
    }
  }

  var headline: String? {
    switch self {
    case .preferedLanguage:
      "Select your Prefered Langauges"
    default:
      nil
    }
  }

  var nextButtonVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .preferedLanguage:
      true
    }
  }
  var backButtonVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .preferedLanguage:
      true
    }
  }
  var onboardingHeaderVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .preferedLanguage:
      true
    }
  }
  var skipButtonVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .preferedLanguage:
      true
    }
  }
}

@Reducer
struct OnboardingFeature {
  @ObservableState
  struct State: Equatable {
    var onboardingStep: OnboardingStep = .launchScreen
    var onboardingStepCount: OnboardingStepCount = .withoutLogin

    // 01 Launch Screen
    var launchScreen: OnboardingLaunchScreenFeature.State

    // 02 Prefered Language
    var preferedLanguage: OnboardingPreferedLanguageFeature.State
  }

  enum Action {
    case setOnboardingStepCount(OnboardingStepCount)
    case setOnboardingStep(OnboardingStep)

    case backButtonTapped
    case nextButtonTapped

    // 01 Launch Screen
    case launchScreen(OnboardingLaunchScreenFeature.Action)

    // 02 Prefered Language
    case preferedLanguage(OnboardingPreferedLanguageFeature.Action)
  }

  var body: some Reducer<State, Action> {
    Scope(state: \.launchScreen, action: \.launchScreen) {
      OnboardingLaunchScreenFeature()
    }
    Scope(state: \.preferedLanguage, action: \.preferedLanguage) {
      OnboardingPreferedLanguageFeature()
    }
    Reduce { state, action in
      switch action {
      case .setOnboardingStepCount(let stepCount):
        state.onboardingStepCount = stepCount
        return .none

      case .backButtonTapped:
        return .send(.setOnboardingStep(.launchScreen))
      case .nextButtonTapped:
        return .none

      case .setOnboardingStep(let step):
        state.onboardingStep = step
        return .none

      // 01 Launch Screen
      case .launchScreen(.startWithoutAccountButtonTapped):
        return .send(.setOnboardingStep(.preferedLanguage))
      case .launchScreen(.usePeerTubeAccountButtonTapped):
        return .none
      case .launchScreen(.infoButtonTapped):
        return .none

      //02
      case .preferedLanguage(_):
        return .none
      }
    }
  }
}

struct OnboardingView: View {
  let store: StoreOf<OnboardingFeature>

  var body: some View {
    ZStack(alignment: .center) {

      VStack {
        onboardingHeader
        Spacer()
      }
      .containerRelativeFrame(.vertical)
      .containerRelativeFrame(.horizontal)
      .zIndex(2)

      GeometryReader { geometry in
        HStack(spacing: 0) {
          OnboardingLaunchScreenView(
            store: store.scope(state: \.launchScreen, action: \.launchScreen)
          )
          .containerRelativeFrame(.horizontal)
          OnboardingPreferedLanguageView(
            store: store.scope(\.preferedLanguage, action: \.preferedLanguage)
          )
          .containerRelativeFrame(.horizontal)
          .padding(.top, 110)  // onboarding Header is 86px + 2 × 8px top and bottom padding + 8 more padding
        }
        .zIndex(1)
        .offset(x: CGFloat(store.state.onboardingStep.stepIndex) * -geometry.size.width)
      }

      VStack {
        Spacer()
        HStack {
          if store.onboardingStep.backButtonVisible {
            Button("Back") {
              store.send(.backButtonTapped)
            }
            .buttonStyle(RiverButtonLarge(type: .gray))
            .transition(.offset(y: 50).combined(with: .blurReplace))
          }
          Spacer()
          if store.onboardingStep.nextButtonVisible {
            Button("Next") {
              store.send(.nextButtonTapped)
            }
            .buttonStyle(RiverButtonLarge(type: .filled))
            .transition(.offset(y: 50).combined(with: .blurReplace))
          }
        }
        .padding()
      }
      .containerRelativeFrame(.horizontal)
      .containerRelativeFrame(.vertical)
      .zIndex(2)
      .animation(.default, value: store.state.onboardingStep.backButtonVisible)
      .animation(.default, value: store.state.onboardingStep.nextButtonVisible)
    }
    .background(Color(uiColor: .secondarySystemBackground))
    .animation(.default, value: store.onboardingStep.onboardingHeaderVisible)
    .animation(.default, value: store.state.onboardingStep)
  }

  @ViewBuilder
  var onboardingHeader: some View {
    VStack {
      HStack(alignment: .top) {
        if store.onboardingStep.onboardingHeaderVisible {
          Text(store.onboardingStep.headline ?? "")
            .font(CustomFont.fjallaOne.swiftUIFont(size: 28, relativeTo: .title))
            .lineLimit(2)
            .transition(.offset(y: -50).combined(with: .blurReplace))
        }
        Spacer()
        if store.onboardingStep.onboardingHeaderVisible && store.onboardingStep.skipButtonVisible {
          Button("Skip") {

          }
          .buttonStyle(RiverButtonToolbar(type: .gray))
          .transition(.offset(y: -50).combined(with: .blurReplace))
        }
      }
      Spacer()
      if store.onboardingStep.onboardingHeaderVisible {
        HStack(spacing: 4) {
          ForEach(0..<store.onboardingStepCount.rawValue) { index in
            Capsule()
              .stroke(Color(uiColor: .tertiarySystemFill), lineWidth: 1)
              .fill(
                store.onboardingStep.stepIndex - 1 >= index
                  ? Color.green
                  : Color(uiColor: .systemGray4)
              )

              .frame(height: 7)
              .containerRelativeFrame(
                .horizontal,
                { length, axis in
                  return (length - 32) / CGFloat(store.onboardingStepCount.rawValue) - 2
                }
              )
              .clipShape(.capsule)

          }
        }
        .transition(.blurReplace)
      }
    }
    .frame(height: 86)
    .padding()
  }
}

#Preview {
  OnboardingView(
    store: Store(
      initialState: OnboardingFeature.State(
        onboardingStep: .preferedLanguage,
        launchScreen: OnboardingLaunchScreenFeature.State(),
        preferedLanguage: OnboardingPreferedLanguageFeature.State()
      )
    ) {
      OnboardingFeature()
    }
  )
}
