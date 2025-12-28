//
//  VideoPlayer.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import AVKit
import SwiftUI

struct VideoPlayerView: UIViewControllerRepresentable {
    let videoURL: URL
    let sidecarAudioUrl: URL?
    
    init(videoURL: URL, sidecarAudioUrl: URL?) {
        if (sidecarAudioUrl != nil) {
            print("Sidecar Audio Provided")
        } else {
            print("no sidecar audio provided")
        }
        self.videoURL = videoURL
        self.sidecarAudioUrl = sidecarAudioUrl
    }
    
    let coordinationMedium = AVPlaybackCoordinationMedium()

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback)
        try? session.setActive(true)

        let player = AVPlayer(url: videoURL)
        
        do {
            if #available(iOS 26.0, *) {
                try player.playbackCoordinator.coordinate(using: coordinationMedium)
            } else {
                print("cant coordinate audio and video")
            }
        } catch let error {
            print("Error attaching main video plater to coordination medium")
            print(error)
        }
        
        if let sidecarAudioUrl = sidecarAudioUrl {
            print("creating sidecar audio av player")
            let audioPlayer = AVPlayer(url: sidecarAudioUrl)
            
            do {
                if #available(iOS 26.0, *) {
                    print("coordinating video playback")
                    try audioPlayer.playbackCoordinator.coordinate(using: coordinationMedium)
                } else {
                    print("cant coordinate audio and video")
                }
            } catch let error {
                print("Error attaching main video plater to coordination medium")
                print(error)
            }
        }
        
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        #if targetEnvironment(preview)
        #else
            //        playerViewController.player?.play()
        #endif
        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Update the player's URL if it has changed
        if let currentItem = uiViewController.player?.currentItem,
            let currentURL = (currentItem.asset as? AVURLAsset)?.url,
            currentURL != videoURL
        {

            // Store current playback state
            let currentTime = uiViewController.player?.currentTime()
            let wasPlaying = uiViewController.player?.rate != 0

            // Replace the player item with new URL
            let newPlayerItem = AVPlayerItem(url: videoURL)
            uiViewController.player?.replaceCurrentItem(with: newPlayerItem)

            // Restore playback state if it was playing
            if wasPlaying {
                uiViewController.player?.play()
            }
        }
    }
}
