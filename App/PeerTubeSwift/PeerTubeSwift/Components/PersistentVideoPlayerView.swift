//
//  PersistentVideoPlayerView.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 06.01.26.
//

import AVKit
import ComposableArchitecture
import SwiftUI
import TubeSDK

/// A video player view that uses the shared VideoPlayerCoordinator to persist playback across view transitions
struct PersistentVideoPlayerView: UIViewControllerRepresentable {
    let videoFiles: [TubeSDK.VideoFile]
    let selectedVideoFile: TubeSDK.VideoFile?
    let videoInfo: VideoPlayerCoordinator.VideoInfo

    @Dependency(\.videoPlayerCoordinator) var coordinator

    init(
        videoFiles: [TubeSDK.VideoFile],
        selectedVideoFile: TubeSDK.VideoFile?,
        videoTitle: String,
        channelName: String,
        thumbnailURL: URL? = nil
    ) {
        self.videoFiles = videoFiles
        self.selectedVideoFile = selectedVideoFile
        self.videoInfo = VideoPlayerCoordinator.VideoInfo(
            title: videoTitle,
            channelName: channelName,
            thumbnailURL: thumbnailURL
        )
    }

    func makeUIViewController(context: Context) -> AVPlayerViewController {
        // Load video into coordinator if this is a new video or quality change
        coordinator.loadVideo(
            videoFiles: videoFiles,
            selectedFile: selectedVideoFile,
            videoInfo: videoInfo
        )

        // Return the coordinator's player view controller
        if let playerViewController = coordinator.getPlayerViewController() {
            return playerViewController
        }

        // Fallback: create a new one (shouldn't happen in normal operation)
        return AVPlayerViewController()
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context: Context) {
        print("🎬 PersistentVideoPlayer: updateUIViewController called")

        // Check if we need to update the quality
        guard let selectedFile = selectedVideoFile else { return }

        // If this is just a quality change for the same video, update quality
        if coordinator.currentVideoInfo?.title == videoInfo.title {
            coordinator.updateQuality(to: selectedFile)
        } else {
            // This is a new video, load it completely
            coordinator.loadVideo(
                videoFiles: videoFiles,
                selectedFile: selectedFile,
                videoInfo: videoInfo
            )
        }
    }
}

/// A minimal video player view for the mini player that shares the same AVPlayer
struct MiniPersistentVideoPlayerView: UIViewRepresentable {
    @Dependency(\.videoPlayerCoordinator) var coordinator

    func makeUIView(context: Context) -> UIView {
        let containerView = UIView()
        containerView.backgroundColor = UIColor.black
        containerView.layer.cornerRadius = 8
        containerView.clipsToBounds = true

        // Get the player layer from the coordinator on main thread
        DispatchQueue.main.async {
            if let player = coordinator.player {
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspectFill
                containerView.layer.addSublayer(playerLayer)

                // Store layer reference for frame updates
                containerView.layer.setValue(playerLayer, forKey: "playerLayer")
            }
        }

        return containerView
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            // Update the player layer frame to match the view bounds
            if let playerLayer = uiView.layer.value(forKey: "playerLayer") as? AVPlayerLayer {
                playerLayer.frame = uiView.bounds

                // Update player reference if it changed
                if playerLayer.player !== coordinator.player {
                    playerLayer.player = coordinator.player
                }
            } else if let player = coordinator.player {
                // Add player layer if it doesn't exist
                let playerLayer = AVPlayerLayer(player: player)
                playerLayer.videoGravity = .resizeAspectFill
                playerLayer.frame = uiView.bounds
                uiView.layer.addSublayer(playerLayer)
                uiView.layer.setValue(playerLayer, forKey: "playerLayer")
            }
        }
    }
}

// MARK: - SwiftUI Preview Support

#if DEBUG
    extension PersistentVideoPlayerView {
        static var preview: PersistentVideoPlayerView {
            let sampleVideoFile = TubeSDK.VideoFile(
                id: 1,
                resolution: TubeSDK.VideoResolutionConstant(id: 1, label: "720p"),
                fileUrl: "https://sample-videos.com/zip/10/mp4/720/mp4/SampleVideo_720x480_1mb.mp4",
                playlistUrl:
                    "https://sample-videos.com/zip/10/mp4/720/mp4/SampleVideo_720x480_1mb.mp4",
                hasAudio: true,
                hasVideo: true
            )

            return PersistentVideoPlayerView(
                videoFiles: [sampleVideoFile],
                selectedVideoFile: sampleVideoFile,
                videoTitle: "Sample Video",
                channelName: "Sample Channel"
            )
        }
    }
#endif
