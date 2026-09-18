//
//  PlayerManager.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.09.26.
//

import AVKit
import SwiftUI

@MainActor
@Observable
class PlayerManager: NSObject {
  var avPlayer: AVPlayer?
  var pipController: AVPictureInPictureController?
  var isPiPActive = false
  var currentVideoInfo: VideoInfo?
  var onPiPRestore: (() -> Void)?

  private(set) var currentVideoId: String?

  struct VideoInfo: Equatable {
    let host: String
    let videoId: String
    let title: String?
    let channelName: String?
    let thumbnailUrl: String?
  }

  private let pipLayer = AVPlayerLayer()
  private var pipHostView: UIView?
  private var isProgrammaticStop = false

  private func ensurePipLayerInHierarchy() {
    guard pipHostView == nil else { return }

    let hostView = UIView()
    hostView.isHidden = false
    hostView.isUserInteractionEnabled = false
    hostView.backgroundColor = .clear

    pipLayer.frame = CGRect(x: 0, y: 0, width: 1, height: 1)
    pipLayer.videoGravity = .resizeAspect
    hostView.layer.addSublayer(pipLayer)

    if let window = UIApplication.shared.connectedScenes
      .compactMap({ $0 as? UIWindowScene })
      .first?.windows.first
    {
      hostView.center = CGPoint(x: 0.5, y: 0.5)
      window.addSubview(hostView)
      pipHostView = hostView
    }
  }

  /// Returns the existing player if it matches the given video ID, otherwise nil.
  func existingPlayer(for videoId: String) -> AVPlayer? {
    guard videoId == currentVideoId, let player = avPlayer else { return nil }
    return player
  }

  func register(player: AVPlayer, videoId: String) {
    // Same video — keep existing player, just re-bind to PiP layer if needed
    if videoId == currentVideoId, let existing = avPlayer, existing === player {
      return
    }

    stopPiP()
    avPlayer = player
    currentVideoId = videoId

    ensurePipLayerInHierarchy()
    pipLayer.player = player

    pipController = AVPictureInPictureController(playerLayer: pipLayer)
    pipController?.delegate = self
  }

  func startPiP() {
    guard let pipController, AVPictureInPictureController.isPictureInPictureSupported() else {
      print("❌ PlayerManager: PiP not supported or controller nil")
      return
    }
    positionPipLayer(.bottomCenter)
    pipController.startPictureInPicture()
  }

  func stopPiP() {
    isProgrammaticStop = true
    pipController?.stopPictureInPicture()
  }

  // MARK: - PiP layer positioning

  enum PipPosition {
    case bottomCenter
    case topCenter
  }

  func positionPipLayer(_ position: PipPosition) {
    guard let window = pipHostView?.window else { return }
    let safeArea = window.safeAreaInsets

    switch position {
    case .bottomCenter:
      pipHostView?.center = CGPoint(
        x: window.bounds.midX,
        y: window.bounds.maxY - safeArea.bottom - 80
      )
    case .topCenter:
      pipHostView?.center = CGPoint(
        x: window.bounds.midX,
        y: safeArea.top + 80
      )
    }
  }
}

extension PlayerManager: AVPictureInPictureControllerDelegate {
  func pictureInPictureControllerWillStartPictureInPicture(
    _ pictureInPictureController: AVPictureInPictureController
  ) {
    isPiPActive = true
  }

  func pictureInPictureControllerDidStopPictureInPicture(
    _ pictureInPictureController: AVPictureInPictureController
  ) {
    isPiPActive = false
  }

  func pictureInPictureController(
    _ pictureInPictureController: AVPictureInPictureController,
    restoreUserInterfaceForPictureInPictureStopWithCompletionHandler completionHandler:
      @escaping (Bool) -> Void
  ) {
    if isProgrammaticStop {
      isProgrammaticStop = false
      completionHandler(false)
    } else {
      positionPipLayer(.topCenter)
      onPiPRestore?()
      completionHandler(true)
    }
  }
}
