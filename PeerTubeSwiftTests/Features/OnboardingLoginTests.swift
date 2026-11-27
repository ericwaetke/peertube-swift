//
//  OnboardingLoginTests.swift
//  PeerTubeSwiftTests
//

import ComposableArchitecture
import Foundation
import Testing
import TubeSDK
import WebURL

@testable import PeerTubeSwift

// MARK: - Login (the "with an account" step)

extension BaseSuite {
  @MainActor
  @Suite struct OnboardingLoginTests {
    @Test func bindingClearsPreviousLoginError() async {
      var state = LoginFeature.State()
      state.errorMessage = "Old error"

      let store = TestStore(initialState: state) {
        LoginFeature()
      }

      await store.send(.binding(.set(\.username, "bob"))) {
        $0.username = "bob"
        $0.errorMessage = nil
      }
    }

    @Test func loginSuccessSavesSessionAndEmitsDelegate() async {
      installOnboardingStubProtocol()

      var savedSessions: [UserSession] = []
      var state = LoginFeature.State()
      state.username = "alice"
      state.password = "secret"

      let store = TestStore(initialState: state) {
        LoginFeature()
      } withDependencies: {
        $0.authClient = AuthClient(
          getSession: { nil },
          saveSession: { savedSessions.append($0) },
          deleteSession: {}
        )
      }

      await store.send(\.loginButtonTapped) {
        $0.isLoading = true
        $0.errorMessage = nil
      }

      await store.receive(
        { action in
          guard case .loginResponse(.success(let received)) = action else { return false }
          return received == stubbedSession()
        },
        assert: { $0.isLoading = false }
      )

      await store.receive(
        { action in
          guard case .delegate(.didLogin(let received)) = action else { return false }
          return received == stubbedSession()
        }
      )

      expectNoDifference(savedSessions, [stubbedSession()])
    }

    @Test func loginFailureShowsErrorAndKeepsLoginState() async {
      let store = TestStore(initialState: LoginFeature.State()) {
        LoginFeature()
      }

      await store.send(.loginResponse(.failure(TubeError.unauthorized))) {
        $0.errorMessage = TubeError.unauthorized.localizedDescription
      }

      await store.finish()
      expectNoDifference(store.state.errorMessage, TubeError.unauthorized.localizedDescription)
      #expect(!store.state.isLoading)
    }

    @Test func avatarFailureIsIgnoredOnLogin() async {
      let session = stubbedSession(avatarUrl: nil)
      let store = TestStore(initialState: LoginFeature.State()) {
        LoginFeature()
      }

      await store.send(.loginResponse(.success(session)))
      await store.receive(
        { action in
          guard case .delegate(.didLogin(let received)) = action else { return false }
          return received == session
        }
      )
      expectNoDifference(store.state.isLoading, false)
    }

    @Test func saveSessionFailureDoesNotEmitDelegate() async {
      let store = TestStore(initialState: LoginFeature.State()) {
        LoginFeature()
      } withDependencies: {
        $0.authClient = AuthClient(
          getSession: { nil },
          saveSession: { _ in throw URLError(.cannotWriteToFile) },
          deleteSession: {}
        )
      }

      await store.send(.loginResponse(.success(stubbedSession())))
      // No delegate is emitted when saving fails. An explicit `finish` makes
      // TestStore fail if an unhandled `.delegate` action had been emitted.
      await store.finish()
    }

    @Test func communityButtonTappedPresentsInstanceManager() async {
      let store = TestStore(initialState: LoginFeature.State()) {
        LoginFeature()
      }

      await store.send(\.communityButtonTapped) {
        $0.editInstance = InstanceManagerFeature.State(instanceUrlString: "")
      }
    }

    @Test func savingCommunityCopiesSelectedInstanceAndDismissesSheet() async throws {
      var manager = InstanceManagerFeature.State(instanceUrlString: "")
      manager.instances = [PeerTubeInstance(id: 7, host: onboardingTestHost)]
      manager.selectedInstanceId = 7
      manager.instanceHealth = [7: .healthy]

      var state = LoginFeature.State()
      state.editInstance = manager

      let expectedClient = try TubeSDKClient(scheme: "https", host: onboardingTestHost)
      let store = TestStore(initialState: state) {
        LoginFeature()
      }

      await store.send(.editInstance(.presented(.saveButtonTapped))) {
        $0.editInstance = nil
        $0.$client.withLock { $0 = expectedClient }
      }
      expectNoDifference(store.state.client.instance.host, onboardingTestHost)
    }

    @Test func savingWithoutSelectionOnlyDismissesSheet() async {
      var state = LoginFeature.State()
      state.editInstance = InstanceManagerFeature.State(instanceUrlString: "")

      let store = TestStore(initialState: state) {
        LoginFeature()
      }

      await store.send(.editInstance(.presented(.saveButtonTapped))) {
        $0.editInstance = nil
      }
      expectNoDifference(store.state.client.instance.host, onboardingTestHost)
    }

    @Test func dismissEditInstanceClosesSheet() async {
      var state = LoginFeature.State()
      state.editInstance = InstanceManagerFeature.State(instanceUrlString: "")

      let store = TestStore(initialState: state) {
        LoginFeature()
      }

      await store.send(\.dismissEditInstance) {
        $0.editInstance = nil
      }
    }

    @Test func setClientUpdatesSharedClient() async throws {
      let store = TestStore(initialState: LoginFeature.State()) {
        LoginFeature()
      }

      let newClient = try TubeSDKClient(
        scheme: "https", host: onboardingTestHost, token: stubbedToken()
      )
      await store.send(.setClient(newClient)) {
        $0.$client.withLock { $0 = newClient }
      }
      expectNoDifference(store.state.client.currentToken, stubbedToken())
    }
  }
}

// MARK: - Community selection within the login step

extension BaseSuite {
  @MainActor
  @Suite struct OnboardingCommunityTests {
    @Test func loadInstancesAddsRecommendedCommunitiesAndSelectsCurrentOne() async {
      installOnboardingStubProtocol()

      var state = InstanceManagerFeature.State()
      state.$client.withLock { $0 = onboardingClient() }
      let store = TestStore(initialState: state) {
        InstanceManagerFeature()
      }

      let recommended = [
        PeerTubeInstance(id: 1, host: onboardingTestHost),
        PeerTubeInstance(id: 2, host: "other.example"),
      ]

      await store.send(\.loadInstances)
      await store.receive(\.addInstancesToList, recommended) {
        $0.instances = recommended
        $0.selectedInstanceId = 1
      }
      await store.finish()

      #expect(store.state.readyToSaveInstance == false)
    }

    @Test func onAppearAndPullToRefreshLoadInstances() async {
      installOnboardingStubProtocol()

      var state = InstanceManagerFeature.State()
      state.$client.withLock { $0 = onboardingClient() }
      let store = TestStore(initialState: state) {
        InstanceManagerFeature()
      }

      let recommended = [
        PeerTubeInstance(id: 1, host: onboardingTestHost),
        PeerTubeInstance(id: 2, host: "other.example"),
      ]

      await store.send(\.onAppear)
      await store.receive(\.loadInstances)
      await store.receive(\.addInstancesToList, recommended) {
        $0.instances = recommended
        $0.selectedInstanceId = 1
      }

      await store.send(\.refreshPull)
      await store.receive(\.loadInstances)
      await store.receive(\.addInstancesToList, recommended) {
        $0.instances.append(contentsOf: recommended)
      }
    }

    @Test func selectingRecommendedCommunityMarksItHealthyAndReadyToSave() async {
      installOnboardingStubProtocol()

      var state = InstanceManagerFeature.State()
      state.instances = [PeerTubeInstance(id: 7, host: onboardingTestHost)]
      let store = TestStore(initialState: state) {
        InstanceManagerFeature()
      }

      await store.send(\.selectInstance, 7) {
        $0.selectedInstanceId = 7
        $0.instanceHealth[7] = .checking
      }
      await store.receive(
        { action in
          guard case .connectionResponse(.success) = action else { return false }
          return true
        },
        assert: {
          $0.instanceConfig = stubbedServerConfig()
          $0.connectionError = "Successfully connected to Test Community (v7.0.0)"
        }
      )
      await store.receive(
        { action in
          guard case .instanceHealthResult(let id, let healthy) = action else { return false }
          return id == 7 && healthy
        },
        assert: { $0.instanceHealth[7] = .healthy }
      )

      #expect(store.state.readyToSaveInstance)
      #expect(store.state.selectedInstance?.instance.host == onboardingTestHost)
    }

    @Test func unhealthyRecommendedCommunityCannotBeSaved() async {
      var state = InstanceManagerFeature.State()
      state.instances = [PeerTubeInstance(id: 7, host: onboardingTestHost)]
      state.selectedInstanceId = 7
      state.instanceHealth = [7: .checking]

      let store = TestStore(initialState: state) {
        InstanceManagerFeature()
      }

      await store.send(.instanceHealthResult(7, false)) {
        $0.instanceHealth[7] = .unhealthy
      }
      #expect(!store.state.readyToSaveInstance)
    }

    @Test func customCommunityConnectionIsSavedAsSelection() async {
      installOnboardingStubProtocol()

      var state = InstanceManagerFeature.State()
      state.searchText = "custom.example"
      let store = TestStore(initialState: state) {
        InstanceManagerFeature()
      }

      let url = WebURL("https://custom.example")!

      await store.send(\.selectNewInstance) {
        $0.instanceUrlString = "custom.example"
      }
      await store.receive(\.testConnection) {
        $0.tryingInstanceConnection = true
      }
      await store.receive(\.setInstanceUrl, url) {
        $0.instanceUrl = url
      }
      await store.receive(
        { action in
          guard case .connectionResponse(.success) = action else { return false }
          return true
        },
        assert: {
          $0.tryingInstanceConnection = false
          $0.instanceConfig = stubbedServerConfig()
          $0.connectionError = "Successfully connected to Test Community (v7.0.0)"
          $0.selectedCustomInstance = CustomInstanceEntry(url: url)
        }
      )

      #expect(store.state.selectedInstance?.instance.host == "custom.example")
    }

    @Test func invalidCustomCommunityURLShowsValidationError() async {
      var state = InstanceManagerFeature.State()
      state.instanceUrlString = ""
      let store = TestStore(initialState: state) {
        InstanceManagerFeature()
      }

      await store.send(\.testConnection) {
        $0.tryingInstanceConnection = true
      }
      await store.receive(
        { action in
          guard case .connectionResponse(.failure(.badURL)) = action else { return false }
          return true
        },
        assert: {
          $0.tryingInstanceConnection = false
          $0.instanceConfig = nil
          $0.connectionError = NetworkError.badURL.localizedDescription
        }
      )

      expectNoDifference(store.state.selectedCustomInstance, nil)
    }

    @Test func failedCustomCommunityConnectionShowsError() async {
      var state = InstanceManagerFeature.State()
      state.tryingInstanceConnection = true
      let store = TestStore(initialState: state) {
        InstanceManagerFeature()
      }

      let error = NetworkError.connectionFailed("boom")
      await store.send(.connectionResponse(.failure(error))) {
        $0.tryingInstanceConnection = false
        $0.instanceConfig = nil
        $0.connectionError = error.localizedDescription
      }

      expectNoDifference(store.state.selectedCustomInstance, nil)
    }

    @Test func deselectRemovesBothRecommendedAndCustomCommunity() async {
      var state = InstanceManagerFeature.State()
      state.instances = [PeerTubeInstance(id: 1, host: onboardingTestHost)]
      state.selectedInstanceId = 1
      state.instanceHealth = [1: .healthy]
      state.selectedCustomInstance = CustomInstanceEntry(url: WebURL("https://custom.example")!)
      state.instanceConfig = stubbedServerConfig()

      let store = TestStore(initialState: state) {
        InstanceManagerFeature()
      }

      #expect(store.state.readyToSaveInstance)

      await store.send(\.deselectButtonTapped) {
        $0.selectedCustomInstance = nil
        $0.selectedInstanceId = nil
        $0.instanceConfig = nil
      }

      expectNoDifference(store.state.selectedInstanceId, nil)
      expectNoDifference(store.state.selectedCustomInstance, nil)
      expectNoDifference(store.state.instanceHealth, [1: .healthy])
      #expect(!store.state.readyToSaveInstance)
    }

    @Test func newPageDoesNotReplaceAnExistingSelection() async {
      var state = InstanceManagerFeature.State()
      state.selectedInstanceId = 2

      let store = TestStore(initialState: state) {
        InstanceManagerFeature()
      }

      await store.send(.addInstancesToList([PeerTubeInstance(id: 1, host: onboardingTestHost)])) {
        $0.instances = [PeerTubeInstance(id: 1, host: onboardingTestHost)]
      }
      expectNoDifference(store.state.selectedInstanceId, 2)
    }

    @Test func changingSearchClearsConnectionErrorAndCancelsConnection() async {
      var state = InstanceManagerFeature.State()
      state.connectionError = "Old error"
      state.tryingInstanceConnection = true

      let store = TestStore(initialState: state) {
        InstanceManagerFeature()
      }

      await store.send(\.searchTextChanged, "new.example") {
        $0.searchText = "new.example"
        $0.connectionError = nil
        $0.tryingInstanceConnection = false
      }
    }
  }
}
