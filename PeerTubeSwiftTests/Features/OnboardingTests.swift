//
//  OnboardingTests.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 08.10.26.
//

import ComposableArchitecture
import Foundation
import Testing

@testable import PeerTubeSwift

// MARK: - Helpers

private func onboardingState(
  step: OnboardingStep = .launchScreen,
  stepCount: OnboardingStepCount = .withoutLogin
) -> OnboardingFeature.State {
  OnboardingFeature.State(
    onboardingStep: step,
    onboardingStepCount: stepCount,
    launchScreen: .init(),
    login: .init(),
    preferedLanguage: .init(),
    topics: .init(),
    recommendedChannels: .init()
  )
}

/// Builds `AppFeature.State` with a controlled `hadOnboarding` flag.
///
/// Must be called from inside `TestStore(initialState:)`'s autoclosure so that
/// constructing the state (its tab features hold `@FetchAll` properties) runs with
/// the store's prepared `defaultDatabase` dependency. Building it beforehand reads
/// the blank test-value database and records an issue.
private func appInitialState(
  hadOnboarding: Bool = false,
  onboarding: OnboardingFeature.State? = nil
) -> AppFeature.State {
  var state = AppFeature.State()
  state.$hadOnboarding.withLock { $0 = hadOnboarding }
  state.onboarding = onboarding
  return state
}

/// Records invocations of the `@Dependency(\.dismiss)` effect so tests can
/// assert that a feature asked to be dismissed.
private final class DismissRecorder: @unchecked Sendable {
  private let lock = NSLock()
  private var count = 0

  func record() {
    lock.lock()
    defer { lock.unlock() }
    count += 1
  }

  var invocations: Int {
    lock.lock()
    defer { lock.unlock() }
    return count
  }
}

// MARK: - OnboardingFeature (parent flow & navigation)

@MainActor
struct OnboardingTests {
  @Test func startWithoutAccountWalksThroughFlow() async {
    let store = TestStore(
      initialState: OnboardingFeature.State(
        onboardingStep: .launchScreen,
        onboardingStepCount: .withoutLogin,
        launchScreen: .init(),
        login: .init(),
        preferedLanguage: .init(),
        topics: .init(),
        recommendedChannels: .init()
      )
    ) {
      OnboardingFeature()
    }

    // Child action via chained case key path (the @Reducer macro makes these @CasePathable)
    await store.send(\.launchScreen.startWithoutAccountButtonTapped)

    // Parent returned .send(.setOnboardingStep(...)) from an effect → must be received
    await store.receive(\.setOnboardingStep, .preferedLanguage) {
      $0.onboardingStep = .preferedLanguage
    }

    await store.send(\.nextButtonTapped)
    await store.receive(\.setOnboardingStep, .topics) { $0.onboardingStep = .topics }

    await store.send(\.nextButtonTapped)
    await store.receive(\.setOnboardingStep, .recommendedChannels) {
      $0.onboardingStep = .recommendedChannels
    }

    await store.send(\.nextButtonTapped)
    await store.receive(\.finishOnboarding)  // only emitted when stepCount == .withoutLogin
  }

  @Test func launchScreenWithAccountGoesToCorrectScreen() async {
    let store = TestStore(initialState: onboardingState()) {
      OnboardingFeature()
    }

    // This action *does* change state: stepCount flips .withoutLogin → .withLogin.
    await store.send(\.launchScreen.usePeerTubeAccountButtonTapped) {
      $0.onboardingStepCount = .withLogin
    }
    await store.receive(\.setOnboardingStep, .login) { $0.onboardingStep = .login }
  }

  @Test func launchScreenWithoutAccountGoesToCorrectScreen() async {
    let store = TestStore(initialState: onboardingState()) {
      OnboardingFeature()
    }

    // No trailing closure: stepCount is already .withoutLogin, so the send itself
    // makes no observable change. The step transition arrives via the effect below.
    await store.send(\.launchScreen.startWithoutAccountButtonTapped)
    await store.receive(\.setOnboardingStep, .preferedLanguage) {
      $0.onboardingStep = .preferedLanguage
    }
  }

  @Test func launchScreenPeertubeInfoGoesToCorrectScreen() async {
    let store = TestStore(initialState: onboardingState()) {
      OnboardingFeature()
    }

    // CURRENT behavior: the info button is a no-op (it only prints).
    // TDD: once OnboardingLaunchScreenFeature.State gains an `infoSheet`
    // presentation (OnboardingInfoFeature), replace the send below with:
    //
    //   await store.send(\.launchScreen.infoButtonTapped) {
    //     $0.launchScreen.infoSheet = OnboardingInfoFeature.State()
    //   }
    //   await store.send(.launchScreen(.presented(.closeButtonTapped))) {
    //     $0.launchScreen.infoSheet = nil
    //   }
    await store.send(\.launchScreen.infoButtonTapped)
  }

  @Test func loginBackButtonGoesBack() async {
    let store = TestStore(initialState: onboardingState(step: .login, stepCount: .withLogin)) {
      OnboardingFeature()
    }

    // No closure: the reducer only spawns an effect, state changes on receive.
    await store.send(\.backButtonTapped)
    await store.receive(\.setOnboardingStep, .launchScreen) { $0.onboardingStep = .launchScreen }
  }

  @Test func loginNextButtonGoesNext() async {
    let store = TestStore(initialState: onboardingState(step: .login, stepCount: .withLogin)) {
      OnboardingFeature()
    }

    await store.send(\.nextButtonTapped)
    await store.receive(\.setOnboardingStep, .preferedLanguage) {
      $0.onboardingStep = .preferedLanguage
    }
  }

  @Test func backButtonWalksBackwardsWithoutAccount() async {
    let store = TestStore(
      initialState: onboardingState(step: .recommendedChannels, stepCount: .withoutLogin)
    ) {
      OnboardingFeature()
    }

    await store.send(\.backButtonTapped)
    await store.receive(\.setOnboardingStep, .topics) { $0.onboardingStep = .topics }

    await store.send(\.backButtonTapped)
    await store.receive(\.setOnboardingStep, .preferedLanguage) {
      $0.onboardingStep = .preferedLanguage
    }

    await store.send(\.backButtonTapped)
    await store.receive(\.setOnboardingStep, .launchScreen) { $0.onboardingStep = .launchScreen }

    // From the launch screen back is a no-op: the effect returns early.
    await store.send(\.backButtonTapped)
  }

  @Test func backFromPreferedLanguageGoesToLoginWhenWithLogin() async {
    let store = TestStore(
      initialState: onboardingState(step: .preferedLanguage, stepCount: .withLogin)
    ) {
      OnboardingFeature()
    }

    await store.send(\.backButtonTapped)
    await store.receive(\.setOnboardingStep, .login) { $0.onboardingStep = .login }
  }

  @Test func skipButtonTappedInvokesDismiss() async {
    let recorder = DismissRecorder()
    let store = TestStore(initialState: onboardingState()) {
      OnboardingFeature()
    } withDependencies: {
      $0.dismiss = DismissEffect { recorder.record() }
    }

    // Skip only runs dismiss() — no state change, so no trailing closure.
    let task = await store.send(\.skipButtonTapped)
    await task.finish()
    #expect(recorder.invocations == 1)
  }

  // MARK: TDD (red)

  /// RED: the with-login flow should advance past the recommended-channels step
  /// (towards the not-yet-implemented rules step). The reducer currently returns
  /// `.none` for `.recommendedChannels + .withLogin`, so this assertion fails on
  /// purpose.
  ///
  /// When `OnboardingStep.rules` is added, strengthen to:
  ///
  ///   await store.receive(\.setOnboardingStep, .rules) { $0.onboardingStep = .rules }
  @Test func nextFromRecommendedChannelsShouldAdvanceWhenWithLogin() async {
    let store = TestStore(
      initialState: onboardingState(step: .recommendedChannels, stepCount: .withLogin)
    ) {
      OnboardingFeature()
    }

    await store.send(\.nextButtonTapped)
    #expect(store.state.onboardingStep != .recommendedChannels)
  }

  // TDD (blocked on OnboardingStep.rules — does not compile yet):
  //
  // @Test func backFromRulesGoesToRecommendedChannels() async {
  //   let store = TestStore(
  //     initialState: onboardingState(step: .rules, stepCount: .withLogin)
  //   ) {
  //     OnboardingFeature()
  //   }
  //   await store.send(\.backButtonTapped)
  //   await store.receive(\.setOnboardingStep, .recommendedChannels) {
  //     $0.onboardingStep = .recommendedChannels
  //   }
  // }
}

// MARK: - Child features

@MainActor
struct OnboardingLanguageTests {
  // MARK: OnboardingPreferedLanguageFeature

  @Test func addLanguageButtonTappedPresentsSheet() async throws {
    let initialState = OnboardingPreferedLanguageFeature.State()
    let languages = initialState.languages
    let store = TestStore(initialState: initialState) {
      OnboardingPreferedLanguageFeature()
    }

    await store.send(\.addLanguageButtonTapped) {
      $0.addLanguageSheet = OnboardingLanguageListFeature.State(
        alreadySelectedLanguages: languages)
    }
  }

  @Test func languageTappedAddsLanguageAndDismissesSheet() async throws {
    var initialState = OnboardingPreferedLanguageFeature.State()
    guard
      let newLanguage = Locale.Language.systemLanguages.first(where: {
        !initialState.languages.contains($0)
      })
    else {
      Issue.record("Expected at least one system language not yet selected")
      return
    }
    initialState.addLanguageSheet = OnboardingLanguageListFeature.State(
      alreadySelectedLanguages: initialState.languages)
    let store = TestStore(initialState: initialState) {
      OnboardingPreferedLanguageFeature()
    }

    await store.send(.addLanguageSheet(.presented(.languageTapped(newLanguage)))) {
      $0.$languages.withLock { languages in languages.append(newLanguage) }
    }
    await store.receive(\.dismissSheet) { $0.addLanguageSheet = nil }
  }

  @Test func languageTappedForAlreadySelectedLanguageOnlyDismissesSheet() async throws {
    var initialState = OnboardingPreferedLanguageFeature.State()
    guard let existingLanguage = initialState.languages.first else {
      Issue.record("Expected at least one preferred language in the initial state")
      return
    }
    initialState.addLanguageSheet = OnboardingLanguageListFeature.State(
      alreadySelectedLanguages: initialState.languages)
    let store = TestStore(initialState: initialState) {
      OnboardingPreferedLanguageFeature()
    }

    // Duplicate tap: languages must not change (no closure on send), but the
    // sheet is still dismissed.
    await store.send(.addLanguageSheet(.presented(.languageTapped(existingLanguage))))
    await store.receive(\.dismissSheet) { $0.addLanguageSheet = nil }
  }

  @Test func sheetDismissButtonDismissesSheet() async throws {
    var initialState = OnboardingPreferedLanguageFeature.State()
    initialState.addLanguageSheet = OnboardingLanguageListFeature.State(
      alreadySelectedLanguages: initialState.languages)
    let store = TestStore(initialState: initialState) {
      OnboardingPreferedLanguageFeature()
    }

    // The sheet stays presented while the child action is processed; dismissal
    // happens when the parent's `.dismissSheet` effect is received.
    await store.send(.addLanguageSheet(.presented(.dismissButtonTapped)))
    await store.receive(\.dismissSheet) { $0.addLanguageSheet = nil }
  }

  @Test func removeLanguageTappedRemovesLanguage() async throws {
    guard let language = Locale.Language.systemLanguages.first else {
      Issue.record("Expected at least one system language")
      return
    }
    var initialState = OnboardingPreferedLanguageFeature.State()
    initialState.$languages.withLock { $0 = [language] }
    let store = TestStore(initialState: initialState) {
      OnboardingPreferedLanguageFeature()
    }

    await store.send(\.removeLanguageTapped, language) {
      $0.$languages.withLock { $0 = [] }
    }
  }

  // MARK: OnboardingLanguageListFeature

  @Test func languageListStateExcludesAlreadySelectedLanguages() async throws {
    guard let language = Locale.Language.systemLanguages.first else {
      Issue.record("Expected at least one system language")
      return
    }
    let state = OnboardingLanguageListFeature.State(alreadySelectedLanguages: [language])

    #expect(!state.availableLanguages.contains(language))
    #expect(!state.preferedLanguages.contains(language))
  }

  // MARK: OnboardingTopicsFeature

  @Test func tappingCategoryAddsItToSelection() async throws {
    guard let category = shownCategories.keys.first else {
      Issue.record("Expected at least one shown category")
      return
    }
    var initialState = OnboardingTopicsFeature.State()
    initialState.$selectedCategories.withLock { $0 = [] }
    let store = TestStore(initialState: initialState) {
      OnboardingTopicsFeature()
    }

    await store.send(\.tappedOnCategoryCard, category) {
      $0.$selectedCategories.withLock { $0 = [category] }
    }
  }

  @Test func tappingSelectedCategoryRemovesIt() async throws {
    guard let category = shownCategories.keys.first else {
      Issue.record("Expected at least one shown category")
      return
    }
    var initialState = OnboardingTopicsFeature.State()
    initialState.$selectedCategories.withLock { $0 = [category] }
    let store = TestStore(initialState: initialState) {
      OnboardingTopicsFeature()
    }

    await store.send(\.tappedOnCategoryCard, category) {
      $0.$selectedCategories.withLock { $0 = [] }
    }
  }
}

// MARK: - OnboardingRulesFeature

@MainActor
struct OnboardingRulesTests {
  @Test func acceptGuidelinesToggleUpdatesSharedState() async {
    var initialState = OnboardingRulesFeature.State()
    initialState.$acceptedGuidelines.withLock { $0 = false }
    let store = TestStore(initialState: initialState) {
      OnboardingRulesFeature()
    }

    await store.send(.acceptGuidelinesToggleTapped(true)) {
      $0.$acceptedGuidelines.withLock { $0 = true }
    }
    await store.send(.acceptGuidelinesToggleTapped(false)) {
      $0.$acceptedGuidelines.withLock { $0 = false }
    }
  }

  @Test func acceptPrivacyPolicyToggleUpdatesSharedState() async {
    var initialState = OnboardingRulesFeature.State()
    initialState.$acceptedPrivacyPolicy.withLock { $0 = false }
    let store = TestStore(initialState: initialState) {
      OnboardingRulesFeature()
    }

    await store.send(.acceptPrivacyPolicyToggleTapped(true)) {
      $0.$acceptedPrivacyPolicy.withLock { $0 = true }
    }
    await store.send(.acceptPrivacyPolicyToggleTapped(false)) {
      $0.$acceptedPrivacyPolicy.withLock { $0 = false }
    }
  }
}

// MARK: - AppFeature ↔ onboarding wiring

@MainActor
struct AppOnboardingTests {
  /// Every App-level test must prepare `defaultDatabase`: `AppFeature.State`
  /// construction and the feature reducers touch `@Dependency(\.defaultDatabase)`.
  /// `bootstrapDatabase()` (the same call the app makes at launch) provisions a
  /// fresh, migrated temporary database in test context. Build the initial state
  /// inline so it is produced inside `TestStore`'s prepared dependency scope.
  @Test func taskOpensOnboardingWhenNotSeenBefore() async {
    let store = TestStore(initialState: appInitialState(hadOnboarding: false)) {
      AppFeature()
    } withDependencies: {
      try! $0.bootstrapDatabase()
    }

    await store.send(\.task)
    // authClient's testValue returns nil, so sessionLoaded(nil) follows.
    await store.receive(\.openOnboarding) { $0.onboarding = onboardingState() }
    await store.receive(\.sessionLoaded, .none) { $0.isLoaded = true }
  }

  @Test func finishOnboardingDismissesOnboardingAndMarksDone() async {
    let store = TestStore(
      initialState: appInitialState(
        hadOnboarding: false,
        onboarding: onboardingState(step: .recommendedChannels, stepCount: .withoutLogin)
      )
    ) {
      AppFeature()
    } withDependencies: {
      try! $0.bootstrapDatabase()
    }

    // Diagnostic: the presented child must be present when the action is sent.
    #expect(store.state.onboarding != nil)

    await store.send(.onboarding(.presented(.finishOnboarding))) {
      $0.onboarding = nil
      $0.$hadOnboarding.withLock { $0 = true }
    }
  }

  @Test func skipButtonDismissesOnboardingAndMarksDone() async {
    let recorder = DismissRecorder()
    let store = TestStore(
      initialState: appInitialState(hadOnboarding: false, onboarding: onboardingState())
    ) {
      AppFeature()
    } withDependencies: {
      try! $0.bootstrapDatabase()
      $0.dismiss = DismissEffect { recorder.record() }
    }

    #expect(store.state.onboarding != nil)

    // The AppFeature reducer nils the presented onboarding first, so the child's
    // dismiss effect may never run here — the observable contract is the state
    // change, which is what we assert.
    await store.send(.onboarding(.presented(.skipButtonTapped))) {
      $0.onboarding = nil
      $0.$hadOnboarding.withLock { $0 = true }
    }
  }
}
