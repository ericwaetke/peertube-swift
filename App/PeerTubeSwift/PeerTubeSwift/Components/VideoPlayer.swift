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

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback)
        try? session.setActive(true)

        let player = AVPlayer(url: videoURL)
        
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
