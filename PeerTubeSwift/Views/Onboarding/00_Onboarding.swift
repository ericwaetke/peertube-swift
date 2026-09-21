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
  case withLogin = 4
  case withoutLogin = 3
}

enum OnboardingStep {
  case launchScreen
  case login
  case preferedLanguage
  case topics

  func stepIndex(for stepCount: OnboardingStepCount) -> Int {
    switch (self, stepCount) {
    case (.launchScreen, _): 0
    case (.login, .withLogin): 1
    case (.preferedLanguage, .withLogin): 2
    case (.topics, .withLogin): 3
    case (.preferedLanguage, .withoutLogin): 1
    case (.topics, .withoutLogin): 2
    case (.login, .withoutLogin): -1  // shouldn't happen
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
    case .launchScreen, .login:
      false
    case .preferedLanguage, .topics:
      true
    }
  }
  var backButtonVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .login, .preferedLanguage, .topics:
      true
    }
  }
  var onboardingHeaderVisible: Bool {
    switch self {
    case .launchScreen, .login:
      false
    case .preferedLanguage, .topics:
      true
    }
  }
  var skipButtonVisible: Bool {
    switch self {
    case .launchScreen, .login:
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

    // 01 Launch Screen
    var launchScreen: OnboardingLaunchScreenFeature.State

    // 02 Login Screen
    var login: LoginFeature.State

    // 03 Prefered Language
    var preferedLanguage: OnboardingPreferedLanguageFeature.State

    // 02 Topics
    var topics: OnboardingTopicsFeature.State
  }

  enum Action {
    case setOnboardingStepCount(OnboardingStepCount)
    case setOnboardingStep(OnboardingStep)

    case backButtonTapped
    case nextButtonTapped
    case skipButtonTapped

    // 01 Launch Screen
    case launchScreen(OnboardingLaunchScreenFeature.Action)

    // 02 Login Screen
    case login(LoginFeature.Action)

    // 03 Prefered Language
    case preferedLanguage(OnboardingPreferedLanguageFeature.Action)

    // 04 Topics
    case topics(OnboardingTopicsFeature.Action)
  }

  var body: some Reducer<State, Action> {
    // 01 Launch Screen
    Scope(state: \.launchScreen, action: \.launchScreen) {
      OnboardingLaunchScreenFeature()
    }
    // 02 Login Screen
    Scope(state: \.login, action: \.login) {
      LoginFeature()
    }
    // 03 Prefered Language
    Scope(state: \.preferedLanguage, action: \.preferedLanguage) {
      OnboardingPreferedLanguageFeature()
    }
    // 04 Topics
    Scope(state: \.topics, action: \.topics) {
      OnboardingTopicsFeature()
    }
    Reduce { state, action in
      switch action {
      case .setOnboardingStepCount(let stepCount):
        state.onboardingStepCount = stepCount
        return .none

      case .backButtonTapped:
        return .run { [step = state.onboardingStep, stepCount = state.onboardingStepCount] send in
          await UIImpactFeedbackGenerator(style: .soft).impactOccurred()
          switch step {
          case .launchScreen:
            return
          case .login:
            return await send(.setOnboardingStep(.launchScreen))
          case .preferedLanguage:
            if stepCount == .withLogin {
              return await send(.setOnboardingStep(.login))
            } else {
              return await send(.setOnboardingStep(.launchScreen))
            }
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
          case .login:
            return await send(.setOnboardingStep(.preferedLanguage))
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

      // Login
      case .login(_):
        return .none

      // 01 Launch Screen
      case .launchScreen(.startWithoutAccountButtonTapped):
        state.onboardingStepCount = .withoutLogin
        return .send(.setOnboardingStep(.preferedLanguage))
      case .launchScreen(.usePeerTubeAccountButtonTapped):
        state.onboardingStepCount = .withLogin
        return .send(.setOnboardingStep(.login))
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
  @Bindable var store: StoreOf<OnboardingFeature>

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

          if store.onboardingStepCount == .withLogin {
            LoginView(store: store.scope(state: \.login, action: \.login))
              .containerRelativeFrame(.horizontal)
          }

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
        .offset(
          x: CGFloat(store.state.onboardingStep.stepIndex(for: store.state.onboardingStepCount))
            * -geometry.size.width)
      }

      bottomBar
    }
    .background(Color(uiColor: .secondarySystemBackground))
    .animation(.default, value: store.onboardingStep.onboardingHeaderVisible)
    .animation(.default, value: store.state.onboardingStep)
  }

  @ViewBuilder
  var bottomBar: some View {
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
        if store.onboardingStep == .topics && store.state.topics.selectedCategories.count > 0 {
          Text("\(store.state.topics.selectedCategories.count) Selected")
            .contentTransition(
              .numericText(value: Double(store.state.topics.selectedCategories.count))
            )
            .padding(.horizontal, 14)
            .padding(.vertical, 6)
            .background(
              Capsule()
                .fill(.white)
            )
            .transition(.offset(y: 50).combined(with: .blurReplace))

          Spacer()
        }
        if store.onboardingStep.nextButtonVisible {
          Button("Next") {
            store.send(.nextButtonTapped)
          }
          .buttonStyle(RiverButtonLarge(type: .filled))
          .transition(.offset(y: 50).combined(with: .blurReplace))
        }
      }
      .animation(.default, value: store.state.topics.selectedCategories.count)
      .padding()
      .padding(.bottom, 44)
      .background {
        gradientView
      }

    }
    .ignoresSafeArea()
    .containerRelativeFrame(.horizontal)
    .containerRelativeFrame(.vertical)
    .zIndex(2)
    .animation(.default, value: store.state.onboardingStep.backButtonVisible)
    .animation(.default, value: store.state.onboardingStep.nextButtonVisible)
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
                    x: store.onboardingStep.stepIndex(for: store.onboardingStepCount) - 1 >= index
                      ? 1 : 0,
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

  @ViewBuilder
  var gradientView: some View {
    Rectangle()
      .fill(.ultraThinMaterial)
      .mask {
        VStack(spacing: 0) {
          LinearGradient(
            colors: [
              Color.black.opacity(0),
              Color.white.opacity(1),
            ],
            startPoint: .top,
            endPoint: .bottom
          )
          Rectangle()
        }
      }
      .allowsHitTesting(false)
      .frame(height: .infinity)
  }
}

#Preview {
  OnboardingView(
    store: Store(
      initialState: OnboardingFeature.State(
        onboardingStep: .topics,
        launchScreen: OnboardingLaunchScreenFeature.State(),
        login: LoginFeature.State(),
        preferedLanguage: OnboardingPreferedLanguageFeature.State(),
        topics: OnboardingTopicsFeature.State()
      )
    ) {
      OnboardingFeature()
    }
  )
}
