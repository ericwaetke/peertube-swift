//
//  SubscriptionRefreshTests.swift
//  PeerTubeSwiftTests
//

import ComposableArchitecture
import Foundation
import Testing
import TubeSDK

@testable import PeerTubeSwift

private let subscriptionHost = "peertube.example"

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

/// Records the calls made to the injected subscription client.
private final class TubeClientCallRecorder: @unchecked Sendable {
  private let lock = NSLock()
  private var videoCalls: [UserSession] = []
  private var subscriptionCalls: [UserSession] = []

  func recordVideos(_ session: UserSession) {
    lock.lock()
    defer { lock.unlock() }
    videoCalls.append(session)
  }

  func recordSubscriptions(_ session: UserSession) {
    lock.lock()
    defer { lock.unlock() }
    subscriptionCalls.append(session)
  }

  var videoCallCount: Int {
    lock.lock()
    defer { lock.unlock() }
    return videoCalls.count
  }

  var subscriptionCallCount: Int {
    lock.lock()
    defer { lock.unlock() }
    return subscriptionCalls.count
  }
}

private func mockTubeClient(
  recorder: TubeClientCallRecorder,
  subscriptionVideos: @escaping @Sendable (UserSession) -> [TubeSDK.Video] = { _ in [] },
  subscriptions: @escaping @Sendable (UserSession) -> [TubeSDK.VideoChannel] = { _ in [] }
) -> TubeClient {
  .mock(
    getMySubscriptionVideos: { session in
      recorder.recordVideos(session)
      return subscriptionVideos(session)
    },
    getMySubscriptions: { session in
      recorder.recordSubscriptions(session)
      return subscriptions(session)
    }
  )
}

private func subscribedChannel() -> TubeSDK.VideoChannel {
  TubeSDK.VideoChannel(
    id: 1, url: "https://peertube.example/c/alice", name: "alice",
    host: subscriptionHost, displayName: "Alice"
  )
}

private func newVideo() -> TubeSDK.Video {
  TubeSDK.Video(
    uuid: UUID(),
    publishedAt: Date(),
    duration: 600,
    name: "New video",
    views: 10,
    likes: 1,
    dislikes: 0,
    comments: 0,
    channel: VideoChannelSummary(
      id: 1, name: "alice", displayName: "Alice",
      url: "https://peertube.example/c/alice", host: subscriptionHost
    )
  )
}

private func appInitialState() -> AppFeature.State {
  let state = AppFeature.State()
  // Skip onboarding so the launch refresh is not mixed with presentation actions.
  state.$hadOnboarding.withLock { $0 = true }
  return state
}

extension BaseSuite {
  @MainActor
  @Suite struct SubscriptionRefreshTests {
    @Test func launchWithStoredSessionLoadsClient() async {
      let session = storedSession()
      let store = TestStore(initialState: appInitialState()) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.tubeClient = .mock()
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

    @Test func launchAutomaticallyRefreshesSubscriptions() async {
      let recorder = TubeClientCallRecorder()
      let session = storedSession()
      let store = TestStore(initialState: appInitialState()) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.tubeClient = mockTubeClient(recorder: recorder)
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

      #expect(recorder.videoCallCount >= 1)
      #expect(recorder.subscriptionCallCount >= 1)
    }

    @Test func launchShowsNewVideosWithoutManualRefresh() async {
      let recorder = TubeClientCallRecorder()
      let video = newVideo()
      let session = storedSession()
      let store = TestStore(initialState: appInitialState()) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.tubeClient = mockTubeClient(
          recorder: recorder,
          subscriptionVideos: { _ in [video] },
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

      await store.receive { action in
        guard case .feedTab(.subscriptionFeed(.finishLoading(let rows))) = action else {
          return false
        }
        return rows.contains { $0.video.name == "New video" }
      }
      await store.finish()

      #expect(recorder.videoCallCount >= 1)
      #expect(store.state.feedTab.subscriptionFeed.hasLoadedAtLeastOnce == true)
    }
  }
}
