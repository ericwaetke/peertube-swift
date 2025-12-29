//
//  VideoPlayer.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import AVKit
import ObjectiveC
import SwiftUI
import TubeSDK

struct VideoPlayerView: UIViewControllerRepresentable {
    let videoFiles: [TubeSDK.VideoFile]
    let selectedVideoFile: TubeSDK.VideoFile?

    // Legacy initializer for single URL (backwards compatibility)
    init(videoURL: URL) {
        // Create a temporary VideoFile from URL for backwards compatibility
        let tempVideoFile = TubeSDK.VideoFile(
            playlistUrl: videoURL.absoluteString,
            hasAudio: true,
            hasVideo: true
        )
        self.videoFiles = [tempVideoFile]
        self.selectedVideoFile = tempVideoFile
    }

    // New initializer for VideoFile arrays with quality selection
    init(videoFiles: [TubeSDK.VideoFile], selectedVideoFile: TubeSDK.VideoFile?) {
        self.videoFiles = videoFiles
        self.selectedVideoFile = selectedVideoFile
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback)
        try? session.setActive(true)

        let playerViewController = AVPlayerViewController()

        // Create player with combined streams if needed
        if let player = createPlayerWithCombinedStreams() {
            playerViewController.player = player
        }

        #if targetEnvironment(preview)
        #else
            // Auto-play can be enabled here if desired
            // playerViewController.player?.play()
        #endif

        return playerViewController
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        // Check if we need to update the player
        guard let selectedFile = selectedVideoFile,
            let selectedURL = selectedFile.bestPlaybackURL
        else {
            return
        }

        // Compare current URL with selected URL
        if let currentItem = uiViewController.player?.currentItem,
            let currentURL = (currentItem.asset as? AVURLAsset)?.url,
            currentURL.absoluteString == selectedURL.absoluteString
        {
            return  // No change needed
        }

        // Store current playback state
        let currentTime = uiViewController.player?.currentTime()
        let wasPlaying = uiViewController.player?.rate != 0

        // Create new player
        if let newPlayer = createPlayerWithCombinedStreams() {
            uiViewController.player = newPlayer

            // Restore playback state
            if let currentTime = currentTime {
                newPlayer.seek(to: currentTime)
            }
            if wasPlaying {
                newPlayer.play()
            }
        }
    }

    private func createPlayerWithCombinedStreams() -> AVPlayer? {
        guard let selectedFile = selectedVideoFile else {
            return nil
        }

        // Find the best video/audio combination
        let (primaryFile, audioFile) = VideoFileHelper.findBestVideoAudioCombination(
            from: videoFiles,
            targetVideoFile: selectedFile
        )

        guard let primary = primaryFile,
            let playbackURL = primary.bestPlaybackURL
        else {
            return nil
        }

        // If the primary file has complete streams (both audio and video), use it directly
        if primary.hasCompleteStreams || audioFile == nil {
            return AVPlayer(url: playbackURL)
        }

        // If we have separate video and audio streams, use our custom loader
        return createPlayerWithResourceLoader(
            videoURL: playbackURL,
            videoFile: primary,
            audioFile: audioFile
        )
    }

    private func createPlayerWithResourceLoader(
        videoURL: URL,
        videoFile: TubeSDK.VideoFile,
        audioFile: TubeSDK.VideoFile?
    ) -> AVPlayer? {

        // Create the resource loader delegate
        let delegate = PlaylistLoaderDelegate(
            videoURL,
            videoFile: videoFile,
            audioFile: audioFile
        )

        // Create asset with custom scheme to trigger our delegate
        let playerAsset = AVURLAsset(url: delegate.customSchemeURL)
        playerAsset.resourceLoader.setDelegate(delegate, queue: .main)

        // Store delegate reference to prevent deallocation
        // We'll use the asset's associated object to keep it alive
        objc_setAssociatedObject(
            playerAsset,
            "PlaylistLoaderDelegate",
            delegate,
            .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )

        let playerItem = AVPlayerItem(asset: playerAsset)
        return AVPlayer(playerItem: playerItem)
    }
}

// MARK: - SwiftUI Preview Support

#if DEBUG
    extension VideoPlayerView {
        static var preview: VideoPlayerView {
            let sampleVideoFile = TubeSDK.VideoFile(
                id: 1,
                resolution: TubeSDK.VideoResolutionConstant(id: 1, label: "720p"),
                fileUrl: "https://sample-videos.com/zip/10/mp4/720/mp4/SampleVideo_720x480_1mb.mp4",
                playlistUrl:
                    "https://sample-videos.com/zip/10/mp4/720/mp4/SampleVideo_720x480_1mb.mp4",
                hasAudio: true,
                hasVideo: true
            )

            return VideoPlayerView(
                videoFiles: [sampleVideoFile],
                selectedVideoFile: sampleVideoFile
            )
        }
    }
#endif
