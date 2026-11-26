//
//  ChannelPreviewAvatarTests.swift
//  PeerTubeSwiftTests
//

import ComposableArchitecture
import Foundation
import Testing
import TubeSDK

@testable import PeerTubeSwift

private final class AvatarLoaderSpy: @unchecked Sendable {
  private let lock = NSLock()
  private var recorded: [(String, String)] = []
  let result: String?

  init(result: String? = nil) {
    self.result = result
  }

  func record(handle: String, instance: String) {
    lock.lock()
    defer { lock.unlock() }
    recorded.append((handle, instance))
  }

  var callCount: Int {
    lock.lock()
    defer { lock.unlock() }
    return recorded.count
  }

  var firstCall: (String, String)? {
    lock.lock()
    defer { lock.unlock() }
    return recorded.first
  }
}

private func previewState(avatarURL: String? = nil) -> ChannelPreviewFeature.State {
  ChannelPreviewFeature.State(
    host: "peertube.wtf",
    notificationBell: NotificationBellFeature.State(channelId: "gronkh@peertube.wtf"),
    videoChannel: TubeSDK.VideoChannel(
      name: "gronkh",
      avatars: avatarURL.map { [ActorImage(fileUrl: $0)] },
      host: "peertube.wtf",
      displayName: "Gronkh"
    ),
    instance: Instance(host: "peertube.wtf", scheme: "https")
  )
}

extension BaseSuite {
  @MainActor
  @Suite struct ChannelPreviewAvatarTests {
    /// A visible row with no avatar asks the dependency once and installs the URL
    /// in both the channel and the badge (whose fields are all `let`).
    @Test func loadAvatarIfNeededResolvesAndInstallsAvatar() async {
      let avatarURL = "https://peertube.wtf/lazy-static/avatars/gronkh.jpg"
      let spy = AvatarLoaderSpy(result: avatarURL)
      let store = TestStore(initialState: previewState()) {
        ChannelPreviewFeature()
      } withDependencies: {
        $0.channelRecommendations.loadAvatar = { handle, instance in
          spy.record(handle: handle, instance: instance)
          return spy.result
        }
      }

      await store.send(.loadAvatarIfNeeded) { $0.isLoadingAvatar = true }
      await store.receive({ action in
        guard case .avatarLoaded(let url) = action else { return false }
        return url == avatarURL
      }) { state in
        state.isLoadingAvatar = false
        state.videoChannel?.avatars = [ActorImage(fileUrl: avatarURL)]
        state.userBadge = UserBadgeFeature.State(
          variant: .medium,
          avatarUrl: avatarURL,
          channelDisplayName: "Gronkh",
          instanceDisplayName: "peertube.wtf",
          instanceIconUrl: nil
        )
      }

      #expect(spy.callCount == 1)
      #expect(spy.firstCall?.0 == "gronkh")
      #expect(spy.firstCall?.1 == "peertube.wtf")

      // Scrolling back must not trigger another instance lookup.
      await store.send(.loadAvatarIfNeeded)
      #expect(spy.callCount == 1)
    }

    /// A channel that already has an avatar must not hit the network at all.
    @Test func loadAvatarIfNeededSkipsChannelsWithAnAvatar() async {
      let avatarURL = "https://peertube.wtf/lazy-static/avatars/gronkh.jpg"
      let spy = AvatarLoaderSpy(result: avatarURL)
      let store = TestStore(initialState: previewState(avatarURL: avatarURL)) {
        ChannelPreviewFeature()
      } withDependencies: {
        $0.channelRecommendations.loadAvatar = { handle, instance in
          spy.record(handle: handle, instance: instance)
          return spy.result
        }
      }

      await store.send(.loadAvatarIfNeeded)
      #expect(spy.callCount == 0)
    }

    /// A failed lookup leaves the avatar nil so AvatarView keeps its initials fallback.
    @Test func failedAvatarLookupKeepsInitialsFallback() async {
      let spy = AvatarLoaderSpy(result: nil)
      let store = TestStore(initialState: previewState()) {
        ChannelPreviewFeature()
      } withDependencies: {
        $0.channelRecommendations.loadAvatar = { _, _ in
          spy.record(handle: "", instance: "")
          return nil
        }
      }

      await store.send(.loadAvatarIfNeeded) { $0.isLoadingAvatar = true }
      await store.receive({ action in
        guard case .avatarLoaded(let url) = action else { return false }
        return url == nil
      }) { $0.isLoadingAvatar = false }

      #expect(store.state.videoChannel?.avatars?.first?.fileUrl == nil)
      #expect(store.state.userBadge.avatarUrl == nil)
    }
  }
}
