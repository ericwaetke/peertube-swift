//
//  MiniPlayerFeature.swift
//  PeerTubeSwift
//
//  The mini player (Picture in Picture) decision logic. PiP itself is driven by
//  `PlayerManager`; this feature owns the state and decisions so they can be tested.
//

import ComposableArchitecture
import Dependencies

/// The PiP side effects the mini player needs, abstracted so tests can observe them.
struct MiniPlayerClient: Sendable {
  var startPiP: @Sendable () -> Void
  var stopPiP: @Sendable () -> Void
}

enum MiniPlayerClientKey: TestDependencyKey {
  static var testValue: MiniPlayerClient {
    MiniPlayerClient(startPiP: {}, stopPiP: {})
  }
}

extension MiniPlayerClientKey: DependencyKey {
  static var liveValue: MiniPlayerClient {
    MiniPlayerClient(
      startPiP: {
        Task { @MainActor in PlayerManager.shared.startPiP() }
      },
      stopPiP: {
        Task { @MainActor in PlayerManager.shared.stopPiP() }
      }
    )
  }
}

extension DependencyValues {
  var miniPlayerClient: MiniPlayerClient {
    get { self[MiniPlayerClientKey.self] }
    set { self[MiniPlayerClientKey.self] = newValue }
  }
}

@Reducer
struct MiniPlayerFeature {
  @ObservableState
  struct State: Equatable {
    var activeVideo: PlayerManager.VideoInfo?
    var isMiniPlayerActive = false
    var isPiPActive = false
    var isPlaying = false
    var isProgrammaticStop = false
  }

  enum Action {
    case delegate(Delegate)
    case maximizeButtonTapped
    case playbackStateChanged(isPlaying: Bool)
    case pipDidStart
    case pipDidStop
    case videoDetailSheetDismissed
    case videoDetailSheetPresented
    case videoRegistered(PlayerManager.VideoInfo)
  }

  enum Delegate: Equatable {
    case restoreVideo(PlayerManager.VideoInfo)
  }

  @Dependency(\.miniPlayerClient) var miniPlayerClient

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .delegate:
        return .none

      case .maximizeButtonTapped:
        guard let info = state.activeVideo, !state.isProgrammaticStop else { return .none }
        state.isMiniPlayerActive = false
        return .send(.delegate(.restoreVideo(info)))

      case .playbackStateChanged(let isPlaying):
        state.isPlaying = isPlaying
        return .none

      case .pipDidStart:
        state.isPiPActive = true
        return .none

      case .pipDidStop:
        state.isPiPActive = false
        state.isProgrammaticStop = false
        return .none

      case .videoDetailSheetDismissed:
        // A paused video must not be promoted to the mini player.
        guard state.activeVideo != nil, state.isPlaying else { return .none }
        state.isMiniPlayerActive = true
        // A previous programmatic stop must not leak into this PiP session.
        state.isProgrammaticStop = false
        return .run { [miniPlayerClient] _ in miniPlayerClient.startPiP() }

      case .videoDetailSheetPresented:
        guard state.isMiniPlayerActive else { return .none }
        state.isMiniPlayerActive = false
        state.isProgrammaticStop = true
        return .run { [miniPlayerClient] _ in miniPlayerClient.stopPiP() }

      case .videoRegistered(let info):
        state.activeVideo = info
        return .none
      }
    }
  }
}
