//
//  PlayerManager.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.09.26.
//

import AVKit
import SwiftUI

@Observable
class PlayerManager: NSObject {
  var avPlayer: AVPlayer?
  var avPlayerLayer: AVPlayerLayer?
  var pipController: AVPictureInPictureController?
  var isPiPActive = false
  var currentVideoInfo: VideoInfo?
  var onPiPRestore: (() -> Void)?

  struct VideoInfo: Equatable {
    let host: String
    let videoId: String
    let title: String?
    let channelName: String?
    let thumbnailUrl: String?
  }

  // Called by VideoPlayerView after creating the player
  // registers pip controller

  func register(player: AVPlayer) {
    guard avPlayer !== player else { return }
    avPlayer = player

    let layer = AVPlayerLayer(player: player)
    self.avPlayerLayer = layer
    pipController = AVPictureInPictureController(playerLayer: layer)
    pipController?.delegate = self
  }

  func startPiP() {
    pipController?.startPictureInPicture()
  }

  func stopPiP() {
    pipController?.stopPictureInPicture()
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
    onPiPRestore?()
    completionHandler(true)
  }
}
