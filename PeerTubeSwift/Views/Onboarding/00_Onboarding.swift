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
  case topics

  var stepIndex: Int {
    switch self {
    case .launchScreen: 0
    case .preferedLanguage: 1
    case .topics: 2
    }
  }

  var headline: String? {
    switch self {
    case .preferedLanguage:
      "Select your Prefered Languages"
    case .topics:
      "What topics are you interested in?"
    default:
      nil
    }
  }

  var nextButtonVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .preferedLanguage, .topics:
      true
    }
  }
  var backButtonVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .preferedLanguage, .topics:
      true
    }
  }
  var onboardingHeaderVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .preferedLanguage, .topics:
      true
    }
  }
  var skipButtonVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .preferedLanguage, .topics:
      true
    }
  }
}

@Reducer
struct OnboardingFeature {
  @Dependency(\.dismiss) var dismiss

  @ObservableState
  struct State: Equatable {
    var onboardingStep: OnboardingStep = .launchScreen
    var onboardingStepCount: OnboardingStepCount = .withoutLogin

    // Login Screen
    @Presents var login: LoginFeature.State?

    // 01 Launch Screen
    var launchScreen: OnboardingLaunchScreenFeature.State

    // 02 Prefered Language
    var preferedLanguage: OnboardingPreferedLanguageFeature.State

    // 03 Topics
    var topics: OnboardingTopicsFeature.State
  }

  enum Action {
    case setOnboardingStepCount(OnboardingStepCount)
    case setOnboardingStep(OnboardingStep)

    case backButtonTapped
    case nextButtonTapped
    case skipButtonTapped

    // Login Screen
    case login(PresentationAction<LoginFeature.Action>)

    // 01 Launch Screen
    case launchScreen(OnboardingLaunchScreenFeature.Action)

    // 02 Prefered Language
    case preferedLanguage(OnboardingPreferedLanguageFeature.Action)

    // 03 Topics
    case topics(OnboardingTopicsFeature.Action)
  }

  var body: some Reducer<State, Action> {
    // 01 Launch Screen
    Scope(state: \.launchScreen, action: \.launchScreen) {
      OnboardingLaunchScreenFeature()
    }
    // 02 Prefered Language
    Scope(state: \.preferedLanguage, action: \.preferedLanguage) {
      OnboardingPreferedLanguageFeature()
    }
    // 03 Topics
    Scope(state: \.topics, action: \.topics) {
      OnboardingTopicsFeature()
    }
    Reduce { state, action in
      switch action {
      case .setOnboardingStepCount(let stepCount):
        state.onboardingStepCount = stepCount
        return .none

      case .backButtonTapped:
        return .run { [step = state.onboardingStep] send in
          await UIImpactFeedbackGenerator(style: .soft).impactOccurred()
          switch step {
          case .launchScreen:
            return
          case .preferedLanguage:
            return await send(.setOnboardingStep(.launchScreen))
          case .topics:
            return await send(.setOnboardingStep(.preferedLanguage))
          }
        }
      case .nextButtonTapped:
        return .run { [step = state.onboardingStep] send in
          await UIImpactFeedbackGenerator(style: .medium).impactOccurred()
          switch step {
          case .launchScreen:
            return
          case .preferedLanguage:
            return await send(.setOnboardingStep(.topics))
          case .topics:
            return
          }
        }
      case .skipButtonTapped:
        return .run { send in
          await dismiss()
        }

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

      // 03
      case .topics(_):
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

          OnboardingTopicsView(
            store: store.scope(\.topics, action: \.topics)
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
            .contentTransition(.identity)
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
              .fill(Color(uiColor: .systemGray4))
              .overlay(
                Capsule()
                  .fill(Color.green)
                  .scaleEffect(
                    x: store.onboardingStep.stepIndex - 1 >= index ? 1 : 0,
                    anchor: .leading
                  )
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
        preferedLanguage: OnboardingPreferedLanguageFeature.State(),
        topics: OnboardingTopicsFeature.State()
      )
    ) {
      OnboardingFeature()
    }
  )
}
