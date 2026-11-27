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

/// Records the endpoints the app touches through the SDK's transport.
private actor TubeTransportRecorder {
  private var paths: [String] = []

  func record(_ path: String) {
    paths.append(path)
  }

  func count(of path: String) -> Int {
    paths.filter { $0 == path }.count
  }
}

/// Holds subscription-video requests until the test releases them, so two
/// competing load effects are guaranteed to overlap.
private actor LoadGate {
  private var isOpen = false

  func open() {
    isOpen = true
  }

  func wait() async throws {
    while !isOpen {
      try await Task.sleep(nanoseconds: 1_000_000)
    }
  }
}

private struct ChannelList: Encodable {
  let total: Int
  let data: [TubeSDK.VideoChannel]
}

private func mockTubeSDK(
  recorder: TubeTransportRecorder,
  subscriptionVideosJSON: String = #"{"total":0,"data":[]}"#,
  subscriptions: @escaping @Sendable () -> [TubeSDK.VideoChannel] = { [] },
  gate: LoadGate? = nil
) -> TubeSDKClientFactory {
  let encoder = JSONEncoder()
  encoder.dateEncodingStrategy = .iso8601

  return TubeSDKClientFactory { scheme, host, token in
    try TubeSDKClient(
      scheme: scheme,
      host: host,
      token: token,
      transport: TubeTransport { request in
        let path = request.url?.path ?? ""
        await recorder.record(path)

        let data: Data
        switch path {
        case subscriptionVideosPath:
          if let gate { try await gate.wait() }
          data = Data(subscriptionVideosJSON.utf8)
        case subscriptionsPath:
          let channels = subscriptions()
          data = try encoder.encode(ChannelList(total: channels.count, data: channels))
        default:
          data = Data(#"{"total":0,"data":[]}"#.utf8)
        }

        let response = HTTPURLResponse(
          url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil
        )!
        return (data, response)
      }
    )
  }
}

private func subscribedChannel() -> TubeSDK.VideoChannel {
  TubeSDK.VideoChannel(
    id: 1, url: "https://peertube.example/c/alice", name: "alice",
    host: subscriptionHost, displayName: "Alice"
  )
}

private let newVideoJSON = """
  {
    "total": 1,
    "data": [
      {
        "uuid": "E2A0C9F4-6B7D-4B8E-9A21-123456789ABC",
        "name": "New video",
        "views": 10,
        "likes": 1,
        "dislikes": 0,
        "comments": 0,
        "duration": 600,
        "publishedAt": "2026-01-01T00:00:00.000Z",
        "channel": {
          "id": 1,
          "name": "alice",
          "displayName": "Alice",
          "host": "peertube.example",
          "url": "https://peertube.example/c/alice"
        }
      }
    ]
  }
  """

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
    @Test func launchWithStoredSessionLoadsClient() async {
      let session = storedSession()
      let store = TestStore(initialState: appInitialState()) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.tubeSDK = mockTubeSDK(recorder: TubeTransportRecorder())
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

    /// Opening the app queues the same refresh the user otherwise gets only
    /// after pulling to refresh, and it uses the session's client.
    @Test func launchAutomaticallyRefreshesSubscriptions() async {
      let recorder = TubeTransportRecorder()
      let session = storedSession()
      let store = TestStore(initialState: appInitialState()) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.tubeSDK = mockTubeSDK(recorder: recorder)
        $0.authClient = AuthClient(
          getSession: { session },
          saveSession: { _ in },
          deleteSession: {}
        )
      }
      store.exhaustivity = .off

      await store.send(.task)
      await store.receive(\.sessionLoaded, session)

      await store.receive { action in
        guard case .feedTab(.subscriptionFeed(.pulledToRefresh)) = action else { return false }
        return true
      }
      await store.finish()

      #expect(await recorder.count(of: subscriptionVideosPath) >= 1)
      #expect(await recorder.count(of: subscriptionsPath) >= 1)
    }

    /// Reproduces the observed behaviour: the feed view's own `.task` fires as
    /// soon as the app is loaded. A new video returned on that first request
    /// must reach the feed without the user pulling to refresh.
    @Test func launchShowsNewVideosWithoutManualRefresh() async {
      let recorder = TubeTransportRecorder()
      let session = storedSession()
      let store = TestStore(initialState: appInitialState()) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.tubeSDK = mockTubeSDK(
          recorder: recorder,
          subscriptionVideosJSON: newVideoJSON,
          subscriptions: { [subscribedChannel()] }
        )
        $0.authClient = AuthClient(
          getSession: { session },
          saveSession: { _ in },
          deleteSession: {}
        )
      }
      store.exhaustivity = .off

      await store.send(.task)
      await store.receive(\.sessionLoaded, session)
      // The Feed view runs this when the tab view appears after launch.
      await store.send(.feedTab(.subscriptionFeed(.initialScreenLoad)))

      await store.receive { action in
        guard case .feedTab(.subscriptionFeed(.finishLoading(let rows))) = action else {
          return false
        }
        return rows.contains { $0.video.name == "New video" }
      }
      await store.finish()

      #expect(await recorder.count(of: subscriptionVideosPath) >= 1)
      #expect(store.state.feedTab.subscriptionFeed.hasLoadedAtLeastOnce == true)
    }

    /// Both launch triggers fire, but only one load may commit its result.
    /// Holding the requests at a gate guarantees the two effects overlap so
    /// `cancelInFlight` has a chance to cancel the older one.
    @Test func launchDoesNotDoubleLoadSubscriptionFeed() async {
      let recorder = TubeTransportRecorder()
      let gate = LoadGate()
      let session = storedSession()
      let store = TestStore(initialState: appInitialState()) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.tubeSDK = mockTubeSDK(
          recorder: recorder,
          subscriptionVideosJSON: newVideoJSON,
          subscriptions: { [subscribedChannel()] },
          gate: gate
        )
        $0.authClient = AuthClient(
          getSession: { session },
          saveSession: { _ in },
          deleteSession: {}
        )
      }
      store.exhaustivity = .off

      await store.send(.task)
      await store.receive(\.sessionLoaded, session)
      await store.send(.feedTab(.subscriptionFeed(.initialScreenLoad)))
      // Both loads are now parked at the gate.
      await gate.open()
      await store.finish()
      // Apply every action produced by the effects so `currentOffset` reflects
      // all commits, not just the first one we explicitly receive.
      await store.skipReceivedActions(strict: false)

      #expect(await recorder.count(of: subscriptionVideosPath) == 2)
      #expect(store.state.feedTab.subscriptionFeed.currentOffset == 1)
      #expect(store.state.feedTab.subscriptionFeed.errorMessage == nil)
    }
  }
}
