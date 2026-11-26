//
//  SubscriptionRefreshTests.swift
//  PeerTubeSwiftTests
//

import ComposableArchitecture
import Foundation
import Testing
import TubeSDK

@testable import PeerTubeSwift

// MARK: - Helpers

private let subscriptionHost = "peertube.example"
private let subscriptionsPath = "/api/v1/users/me/subscriptions"
private let subscriptionVideosPath = "/api/v1/users/me/subscriptions/videos"

private func storedSession() -> UserSession {
  UserSession(
    username: "alice",
    host: subscriptionHost,
    token: OAuthToken(
      accessToken: "access-token",
      refreshToken: "refresh-token",
      tokenType: "Bearer",
      expiresIn: 3600
    )
  )
}

/// Records which endpoints the app touches and answers every request with an
/// empty PeerTube list, so effects finish without reaching the network.
private final class RequestRecorder: @unchecked Sendable {
  private let lock = NSLock()
  private var paths: [String] = []

  func record(_ path: String) {
    lock.lock()
    defer { lock.unlock() }
    paths.append(path)
  }

  func count(of path: String) -> Int {
    lock.lock()
    defer { lock.unlock() }
    return paths.filter { $0 == path }.count
  }
}

private final class StubURLProtocol: URLProtocol {
  nonisolated(unsafe) static var recorder: RequestRecorder?

  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    Self.recorder?.record(request.url?.path ?? "")
    guard let url = request.url else {
      client?.urlProtocol(self, didFailWithError: URLError(.badURL))
      return
    }
    let response = HTTPURLResponse(
      url: url, statusCode: 200, httpVersion: nil, headerFields: nil
    )!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: Data(#"{"total":0,"data":[]}"#.utf8))
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

private func stubSession() -> URLSession {
  let configuration = URLSessionConfiguration.ephemeral
  configuration.protocolClasses = [StubURLProtocol.self]
  return URLSession(configuration: configuration)
}

/// Builds app state inside `TestStore`'s dependency scope: the tab features
/// hold `@FetchAll` properties and need the prepared database at construction.
private func appInitialState() -> AppFeature.State {
  let state = AppFeature.State()
  // Skip onboarding so the launch refresh is not mixed with presentation actions.
  state.$hadOnboarding.withLock { $0 = true }
  return state
}

extension BaseSuite {
  @MainActor
  @Suite struct SubscriptionRefreshTests {
    /// Guard: a stored session still loads on launch and makes the UI ready.
    /// This part already works and must keep working when the refresh is added.
    @Test func launchWithStoredSessionLoadsClient() async {
      let session = storedSession()
      let store = TestStore(initialState: appInitialState()) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.urlSession = stubSession()
        $0.authClient = AuthClient(
          getSession: { session },
          saveSession: { _ in },
          deleteSession: {}
        )
      }
      store.exhaustivity = .off

      await store.send(.task)
      await store.receive(\.sessionLoaded, session)

      #expect(store.state.isLoaded)
      expectNoDifference(store.state.session, session)
      #expect(store.state.client != nil)
    }

    /// User story: opening the app refreshes the subscriptions feed on its own.
    /// The test sends only `.task` — no pull-to-refresh — and asserts that the
    /// refresh action and its network requests follow from launch alone.
    /// The refresh must be queued while `.task` is still loading the session,
    /// because at that point there is no client to refresh with yet.
    @Test func launchAutomaticallyRefreshesSubscriptions() async {
      let recorder = RequestRecorder()
      StubURLProtocol.recorder = recorder
      defer { StubURLProtocol.recorder = nil }

      let session = storedSession()
      let store = TestStore(initialState: appInitialState()) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.urlSession = stubSession()
        $0.authClient = AuthClient(
          getSession: { session },
          saveSession: { _ in },
          deleteSession: {}
        )
      }
      store.exhaustivity = .off

      await store.send(.task)
      #expect(recorder.count(of: subscriptionVideosPath) == 0)
      #expect(recorder.count(of: subscriptionsPath) == 0)

      await store.receive(\.sessionLoaded, session)

      // Launch must queue the same refresh the user currently gets only after
      // pulling to refresh. This is the action that invalidates and refetches.
      await store.receive { action in
        guard case .feedTab(.subscriptionFeed(.pulledToRefresh)) = action else { return false }
        return true
      }
      await store.finish()

      // Once the client from the session is available, the queued refresh runs.
      #expect(recorder.count(of: subscriptionVideosPath) >= 1)
      #expect(recorder.count(of: subscriptionsPath) >= 1)
    }
  }
}
