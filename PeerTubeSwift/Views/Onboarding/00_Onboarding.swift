//
//  00_Onboarding.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 21.09.26.
//

import ComposableArchitecture
import FontKit
import SwiftUI

enum OnboardingStepCount: Int {
  case withLogin = 5
  case withoutLogin = 3
}

enum OnboardingStep {
  case launchScreen
  case login
  case preferedLanguage
  case topics
  case recommendedChannels

  func stepIndex(for stepCount: OnboardingStepCount) -> Int {
    switch (self, stepCount) {
    case (.launchScreen, _): 0
    case (.login, .withLogin): 1
    case (.preferedLanguage, .withLogin): 2
    case (.topics, .withLogin): 3
    case (.recommendedChannels, .withLogin): 4
    case (.preferedLanguage, .withoutLogin): 1
    case (.topics, .withoutLogin): 2
    case (.recommendedChannels, .withoutLogin): 3
    case (.login, .withoutLogin): -1  // shouldn't happen
    }
  }

  var headline: String? {
    switch self {
    case .preferedLanguage:
      "Select your Prefered Languages"
    case .topics:
      "What topics are you interested in?"
    case .recommendedChannels:
      "Which Creators Do You Find Interesting?"
    default:
      nil
    }
  }

  var nextButtonVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .preferedLanguage, .topics, .recommendedChannels, .login:
      true
    }
  }
  var nextButtonVariant: O_NextButtonVariant {
    switch self {
    case .login: .login
    case .recommendedChannels: .finish
    default: .next
    }
  }
  var backButtonVisible: Bool {
    switch self {
    case .launchScreen:
      false
    case .login, .preferedLanguage, .topics, .recommendedChannels:
      true
    }
  }
  var onboardingHeaderVisible: Bool {
    switch self {
    case .launchScreen, .login:
      false
    case .preferedLanguage, .topics, .recommendedChannels:
      true
    }
  }
  var skipButtonVisible: Bool {
    switch self {
    case .launchScreen, .login:
      false
    case .preferedLanguage, .topics, .recommendedChannels:
      true
    }
  }
}

let TOP_PADDING: CGFloat = 48

@Reducer
struct OnboardingFeature {
  @Dependency(\.dismiss) var dismiss

  @ObservableState
  struct State: Equatable {
    var onboardingStep: OnboardingStep = .launchScreen
    var onboardingStepCount: OnboardingStepCount = .withoutLogin
    var nextButton: O_NextButtonFeature.State = O_NextButtonFeature.State()

    // 01 Launch Screen
    var launchScreen: OnboardingLaunchScreenFeature.State

    // 02 Login Screen
    var login: LoginFeature.State

    // 03 Prefered Language
    var preferedLanguage: OnboardingPreferedLanguageFeature.State

    // 04 Topics
    var topics: OnboardingTopicsFeature.State

    // 05 Channel Recommendations
    var recommendedChannels: OnboardingRecommendedChannelsFeature.State
  }

  enum Action {
    case setOnboardingStepCount(OnboardingStepCount)
    case setOnboardingStep(OnboardingStep)

    case backButtonTapped
    case nextButton(O_NextButtonFeature.Action)
    case skipButtonTapped
    case finishOnboarding
    case collapseKeyboard

    // 01 Launch Screen
    case launchScreen(OnboardingLaunchScreenFeature.Action)

    // 02 Login Screen
    case login(LoginFeature.Action)

    // 03 Prefered Language
    case preferedLanguage(OnboardingPreferedLanguageFeature.Action)

    // 04 Topics
    case topics(OnboardingTopicsFeature.Action)

    // 05
    case recommendedChannels(OnboardingRecommendedChannelsFeature.Action)
  }

  var body: some Reducer<State, Action> {
    Scope(state: \.nextButton, action: \.nextButton) {
      O_NextButtonFeature()
    }
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
    // 05 Channel Recommendations
    //    Scope(state)
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
            await send(.collapseKeyboard)
            return await send(.setOnboardingStep(.launchScreen))
          case .preferedLanguage:
            if stepCount == .withLogin {
              return await send(.setOnboardingStep(.login))
            } else {
              return await send(.setOnboardingStep(.launchScreen))
            }
          case .topics:
            return await send(.setOnboardingStep(.preferedLanguage))
          case .recommendedChannels:
            return await send(.setOnboardingStep(.topics))
          }
        }

      case .nextButton(.nextButtonTapped(let type)):
        switch type {
        case .next:
          return .run { [step = state.onboardingStep, stepCount = state.onboardingStepCount] send in
            await UIImpactFeedbackGenerator(style: .medium).impactOccurred()
            switch step {
            case .launchScreen:
              return
            case .login:
              await send(.collapseKeyboard)
              return await send(.setOnboardingStep(.preferedLanguage))
            case .preferedLanguage:
              return await send(.setOnboardingStep(.topics))
            case .topics:
              return await send(.setOnboardingStep(.recommendedChannels))
            case .recommendedChannels:
              if stepCount == .withoutLogin {
                return await send(.finishOnboarding)
              } else {
                //              return await send(.setOnboardingStep(.rules))
                return
              }
            }
          }
        case .login:
          return .send(.login(.loginButtonTapped))
        case .finish:
          return .send(.finishOnboarding)
        }

      case .skipButtonTapped:
        return .run { send in
          await dismiss()
        }

      case .setOnboardingStep(let step):
        state.nextButton.variant = step.nextButtonVariant
        state.onboardingStep = step
        return .none

      case .finishOnboarding:
        return .none

      // Login
      case .login(.delegate(.didLogin(_))):
        return .send(.setOnboardingStep(.preferedLanguage))
      case .login(_):
        return .none

      // 01 Launch Screen
      case .launchScreen(.startWithoutAccountButtonTapped):
        print("without account button tapped")
        state.onboardingStepCount = .withoutLogin
        return .send(.setOnboardingStep(.preferedLanguage))
      case .launchScreen(.usePeerTubeAccountButtonTapped):
        print("with account button tapped")
        state.onboardingStepCount = .withLogin
        return .send(.setOnboardingStep(.login))
      case .launchScreen(.infoButtonTapped):
        print("info button tapped")
        return .none
      case .launchScreen(_):
        return .none

      //02
      case .preferedLanguage(_):
        return .none

      // 03
      case .topics(_):
        return .none

      // 04
      case .recommendedChannels(_):
        return .none
      case .collapseKeyboard:
        state.login.focusedField = nil
        return .none
      }
    }
  }
}

struct OnboardingView: View {
  @Bindable var store: StoreOf<OnboardingFeature>

  var body: some View {
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

        VStack {
          Text(OnboardingStep.preferedLanguage.headline ?? "")
            .font(CustomFont.fjallaOne.swiftUIFont(size: 28, relativeTo: .title))
            .lineLimit(2)
          OnboardingPreferedLanguageView(
            store: store.scope(\.preferedLanguage, action: \.preferedLanguage)
          )
        }
        .containerRelativeFrame(.horizontal)
        .padding(.top, TOP_PADDING)

        VStack {
          Text(OnboardingStep.topics.headline ?? "")
            .font(CustomFont.fjallaOne.swiftUIFont(size: 28, relativeTo: .title))
            .lineLimit(2)
          OnboardingTopicsView(
            store: store.scope(\.topics, action: \.topics)
          )
        }
        .containerRelativeFrame(.horizontal)
        .padding(.top, TOP_PADDING)

        VStack {
          Text(OnboardingStep.recommendedChannels.headline ?? "")
            .font(CustomFont.fjallaOne.swiftUIFont(size: 28, relativeTo: .title))
            .lineLimit(2)
          OnboardingRecommendedChannelsView(
            store: store.scope(\.recommendedChannels, action: \.recommendedChannels)
          )
        }
        .containerRelativeFrame(.horizontal)
        .padding(.top, TOP_PADDING)
      }
      .zIndex(1)
      .offset(
        x: CGFloat(store.state.onboardingStep.stepIndex(for: store.state.onboardingStepCount))
          * -geometry.size.width)
    }
    .contentMargins(.bottom, 92, for: .scrollContent)
    .overlay(alignment: .top) {
      if store.onboardingStep.onboardingHeaderVisible {
        onboardingHeader
      }
    }
    .overlay(alignment: .bottom) {
      bottomBar
    }
    .background(Color(uiColor: .secondarySystemBackground))
    .animation(.default, value: store.onboardingStep.onboardingHeaderVisible)
    .animation(.default, value: store.state.onboardingStep)
  }

  @ViewBuilder
  var bottomBar: some View {
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
        O_NextButtonView(store: store.scope(state: \.nextButton, action: \.nextButton))
      }
    }
    .animation(.default, value: store.state.topics.selectedCategories.count)
    .padding()
    .padding(.bottom, 0)
    .containerRelativeFrame(.horizontal)
    .zIndex(2)
    .animation(.default, value: store.state.onboardingStep.backButtonVisible)
    .animation(.default, value: store.state.onboardingStep.nextButtonVisible)
  }

  @ViewBuilder
  var onboardingHeader: some View {
    HStack(spacing: 4) {
      ForEach(0..<store.onboardingStepCount.rawValue) { index in
        Capsule()
          .stroke(Color(uiColor: .tertiarySystemFill), lineWidth: 1)
          .fill(Color(uiColor: .systemGray4))
          .overlay(
            Capsule()
              .fill(Color.Category.food)  // TODO: Replace with real semantic color
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
      .transition(.blurReplace)
    }
    .padding()
  }
}

#Preview("With Login") {
  OnboardingView(
    store: Store(
      initialState: OnboardingFeature.State(
        onboardingStep: .launchScreen,
        onboardingStepCount: .withLogin,
        nextButton: O_NextButtonFeature.State(),
        launchScreen: OnboardingLaunchScreenFeature.State(),
        login: LoginFeature.State(),
        preferedLanguage: OnboardingPreferedLanguageFeature.State(),
        topics: OnboardingTopicsFeature.State(),
        recommendedChannels: OnboardingRecommendedChannelsFeature.State()
      )
    ) {
      OnboardingFeature()
    }
  )
}

#Preview("Without Login") {
  OnboardingView(
    store: Store(
      initialState: OnboardingFeature.State(
        onboardingStep: .topics,
        onboardingStepCount: .withoutLogin,
        nextButton: O_NextButtonFeature.State(),
        launchScreen: OnboardingLaunchScreenFeature.State(),
        login: LoginFeature.State(),
        preferedLanguage: OnboardingPreferedLanguageFeature.State(),
        topics: OnboardingTopicsFeature.State(),
        recommendedChannels: OnboardingRecommendedChannelsFeature.State()
      )
    ) {
      OnboardingFeature()
    }
  )
}
