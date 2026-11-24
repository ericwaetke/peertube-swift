//
//  MiniPlayerTests.swift
//  PeerTubeSwiftTests
//

import ComposableArchitecture
import Foundation
import Testing

@testable import PeerTubeSwift

private let testVideoInfo = PlayerManager.VideoInfo(
  host: "peertube.example",
  videoId: "video-123",
  title: "A test video",
  channelName: "A test channel",
  thumbnailUrl: nil
)

private let secondVideoInfo = PlayerManager.VideoInfo(
  host: "other.example",
  videoId: "video-456",
  title: "A second test video",
  channelName: "Another test channel",
  thumbnailUrl: nil
)

/// Records the PiP side effects requested through `MiniPlayerClient`.
private final class MiniPlayerClientSpy: @unchecked Sendable {
  private let lock = NSLock()
  private var starts = 0
  private var stops = 0

  var startPiPCalls: Int {
    lock.lock()
    defer { lock.unlock() }
    return starts
  }

  var stopPiPCalls: Int {
    lock.lock()
    defer { lock.unlock() }
    return stops
  }

  func startPiP() {
    lock.lock()
    defer { lock.unlock() }
    starts += 1
  }

  func stopPiP() {
    lock.lock()
    defer { lock.unlock() }
    stops += 1
  }
}

private func spyClient(_ spy: MiniPlayerClientSpy) -> MiniPlayerClient {
  MiniPlayerClient(
    startPiP: { spy.startPiP() },
    stopPiP: { spy.stopPiP() }
  )
}

extension BaseSuite {
  @MainActor
  @Suite struct MiniPlayerTests {
    /// Arm 1: dismissing the sheet while the video is running promotes it to PiP.
    @Test func dismissingVideoDetailsWhilePlayingStartsMiniPlayer() async {
      let spy = MiniPlayerClientSpy()
      let store = TestStore(
        initialState: MiniPlayerFeature.State(
          activeVideo: testVideoInfo,
          isPlaying: true
        )
      ) {
        MiniPlayerFeature()
      } withDependencies: {
        $0.miniPlayerClient = spyClient(spy)
      }

      await store.send(\.videoDetailSheetDismissed) {
        $0.isMiniPlayerActive = true
      }
      #expect(spy.startPiPCalls == 1)
      #expect(spy.stopPiPCalls == 0)
    }

    /// Arm 2: dismissing the sheet while paused must not start PiP.
    @Test func dismissingVideoDetailsWhilePausedDoesNotStartMiniPlayer() async {
      let spy = MiniPlayerClientSpy()
      let store = TestStore(
        initialState: MiniPlayerFeature.State(
          activeVideo: testVideoInfo,
          isPlaying: false
        )
      ) {
        MiniPlayerFeature()
      } withDependencies: {
        $0.miniPlayerClient = spyClient(spy)
      }

      await store.send(\.videoDetailSheetDismissed)
      #expect(store.state.isMiniPlayerActive == false)
      #expect(spy.startPiPCalls == 0)
    }

    /// Arm 3a: the maximize button asks to restore the video in the mini player.
    @Test func maximizeButtonRestoresCorrectVideo() async {
      let spy = MiniPlayerClientSpy()
      let store = TestStore(
        initialState: MiniPlayerFeature.State(
          activeVideo: testVideoInfo,
          isMiniPlayerActive: true,
          isPlaying: true
        )
      ) {
        MiniPlayerFeature()
      } withDependencies: {
        $0.miniPlayerClient = spyClient(spy)
      }

      await store.send(\.maximizeButtonTapped) {
        $0.isMiniPlayerActive = false
      }
      await store.receive(\.delegate, .restoreVideo(testVideoInfo))
    }

    /// Arm 3b: restoring that video reopens the sheet with the correct video.
    @Test func restoredVideoReopensSheetWithCorrectVideo() async {
      let store = TestStore(
        initialState: AppFeature.State(
          miniPlayer: MiniPlayerFeature.State(
            activeVideo: testVideoInfo,
            isMiniPlayerActive: true
          )
        )
      ) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
      }

      await store.send(.miniPlayer(.delegate(.restoreVideo(testVideoInfo))))
      await store.receive(\.restoreVideoFromPiP, testVideoInfo) {
        $0.videoDetail = VideoDetailsFeature.State(
          host: testVideoInfo.host,
          videoId: testVideoInfo.videoId,
          channelId: nil
        )
      }
      expectNoDifference(store.state.videoDetail?.host, testVideoInfo.host)
      expectNoDifference(store.state.videoDetail?.videoId, testVideoInfo.videoId)
    }

    /// Regression: minimize video 1, open and minimize video 2, then maximize.
    /// The stale programmatic-stop flag from the first PiP session must not
    /// suppress the restore of the second one.
    @Test func maximizeAfterSecondVideoRestoresSecondVideo() async {
      let spy = MiniPlayerClientSpy()
      let store = TestStore(initialState: MiniPlayerFeature.State()) {
        MiniPlayerFeature()
      } withDependencies: {
        $0.miniPlayerClient = spyClient(spy)
      }

      // Video 1 plays and is minimized.
      await store.send(.videoRegistered(testVideoInfo)) {
        $0.activeVideo = testVideoInfo
      }
      await store.send(.playbackStateChanged(isPlaying: true)) {
        $0.isPlaying = true
      }
      await store.send(\.videoDetailSheetDismissed) {
        $0.isMiniPlayerActive = true
      }
      await store.send(\.pipDidStart) {
        $0.isPiPActive = true
      }

      // Video 2 opens while PiP is running: a programmatic stop. No pipDidStop
      // follows, matching the runtime logs from the failing repro.
      await store.send(\.videoDetailSheetPresented) {
        $0.isMiniPlayerActive = false
        $0.isProgrammaticStop = true
      }

      // Video 2 plays and is minimized, starting a second PiP session.
      await store.send(.videoRegistered(secondVideoInfo)) {
        $0.activeVideo = secondVideoInfo
      }
      await store.send(\.videoDetailSheetDismissed) {
        $0.isMiniPlayerActive = true
      }
      // PiP never reported a stop, so it is already active — no state change here.
      await store.send(\.pipDidStart)

      await store.send(\.maximizeButtonTapped)
      await store.receive(\.delegate, .restoreVideo(secondVideoInfo))
    }

    /// App-level version of the two-video repro: the reopened sheet must carry
    /// video 2, not the video that was minimized first.
    @Test func restoringSecondVideoReopensSheetWithSecondVideo() async {
      let spy = MiniPlayerClientSpy()
      let store = TestStore(initialState: AppFeature.State()) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.miniPlayerClient = spyClient(spy)
      }

      await store.send(.miniPlayer(.videoRegistered(testVideoInfo))) {
        $0.miniPlayer.activeVideo = testVideoInfo
      }
      await store.send(.miniPlayer(.playbackStateChanged(isPlaying: true))) {
        $0.miniPlayer.isPlaying = true
      }
      await store.send(.miniPlayer(.videoDetailSheetDismissed)) {
        $0.miniPlayer.isMiniPlayerActive = true
      }
      await store.send(.miniPlayer(.pipDidStart)) {
        $0.miniPlayer.isPiPActive = true
      }
      await store.send(.miniPlayer(.videoDetailSheetPresented)) {
        $0.miniPlayer.isMiniPlayerActive = false
        $0.miniPlayer.isProgrammaticStop = true
      }
      await store.send(.miniPlayer(.videoRegistered(secondVideoInfo))) {
        $0.miniPlayer.activeVideo = secondVideoInfo
      }
      await store.send(.miniPlayer(.videoDetailSheetDismissed)) {
        $0.miniPlayer.isMiniPlayerActive = true
      }
      // PiP never reported a stop, so it is already active — no state change here.
      await store.send(.miniPlayer(.pipDidStart))

      await store.send(.miniPlayer(.maximizeButtonTapped))
      await store.receive(\.restoreVideoFromPiP, secondVideoInfo) {
        $0.videoDetail = VideoDetailsFeature.State(
          host: secondVideoInfo.host,
          videoId: secondVideoInfo.videoId,
          channelId: nil
        )
      }
      expectNoDifference(store.state.videoDetail?.host, secondVideoInfo.host)
      expectNoDifference(store.state.videoDetail?.videoId, secondVideoInfo.videoId)
    }

    /// A late time update from a dismissed sheet must not be treated as a
    /// presentation action for absent state, nor block a later restore.
    @Test func lateTimeUpdateAfterDismissIsIgnored() async {
      let spy = MiniPlayerClientSpy()
      let store = TestStore(
        initialState: AppFeature.State(
          miniPlayer: MiniPlayerFeature.State(
            activeVideo: testVideoInfo,
            isMiniPlayerActive: true
          )
        )
      ) {
        AppFeature()
      } withDependencies: {
        try! $0.bootstrapDatabase()
        $0.miniPlayerClient = spyClient(spy)
      }

      await store.send(.videoDetail(.presented(.timeUpdate(12))))
      await store.send(.miniPlayer(.maximizeButtonTapped)) {
        $0.miniPlayer.isMiniPlayerActive = false
      }
      await store.receive { action in
        guard case .miniPlayer(.delegate(.restoreVideo(let info))) = action else { return false }
        return info == testVideoInfo
      }
      await store.receive(\.restoreVideoFromPiP, testVideoInfo) {
        $0.videoDetail = VideoDetailsFeature.State(
          host: testVideoInfo.host,
          videoId: testVideoInfo.videoId,
          channelId: nil
        )
      }
    }
  }
}
