//
//  VideoPlayerCoordinator.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 06.01.26.
//

import AVKit
import ComposableArchitecture
import Foundation
import ObjectiveC
import SwiftUI
import TubeSDK

/// A coordinator that manages a single AVPlayer instance that persists across view transitions
@Observable
final class VideoPlayerCoordinator: @unchecked Sendable {
    private let queue = DispatchQueue(label: "VideoPlayerCoordinator", qos: .userInitiated)

    private var _player: AVPlayer?
    private var _playerViewController: AVPlayerViewController?
    private var _currentVideoFiles: [TubeSDK.VideoFile] = []
    private var _currentSelectedFile: TubeSDK.VideoFile?
    private var _currentVideoInfo: VideoInfo?

    var player: AVPlayer? {
        queue.sync { _player }
    }

    var playerViewController: AVPlayerViewController? {
        queue.sync { _playerViewController }
    }

    var currentVideoInfo: VideoInfo? {
        queue.sync { _currentVideoInfo }
    }

    struct VideoInfo {
        let title: String
        let channelName: String
        let thumbnailURL: URL?
    }

    init() {
        setupAudioSession()
    }

    private func setupAudioSession() {
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .moviePlayback)
        try? session.setActive(true)
    }

    /// Load a new video or update quality for current video
    func loadVideo(
        videoFiles: [TubeSDK.VideoFile],
        selectedFile: TubeSDK.VideoFile?,
        videoInfo: VideoInfo
    ) {
        queue.async { [weak self] in
            guard let self = self else { return }

            self._currentVideoFiles = videoFiles
            self._currentSelectedFile = selectedFile
            self._currentVideoInfo = videoInfo

            // Store current playback state if switching quality
            let currentTime = self._player?.currentTime()
            let wasPlaying = self._player?.rate != 0

            // Clean up existing player if needed
            self._cleanupCurrentPlayer()

            // Create new player
            if let newPlayer = self._createPlayer(for: selectedFile, from: videoFiles) {
                DispatchQueue.main.async {
                    self._player = newPlayer

                    // Create player view controller if needed
                    if self._playerViewController == nil {
                        self._playerViewController = AVPlayerViewController()
                    }

                    self._playerViewController?.player = newPlayer

                    // Restore playback state if this was a quality change
                    if let currentTime = currentTime, currentTime.seconds > 0 {
                        newPlayer.seek(to: currentTime)
                        if wasPlaying {
                            newPlayer.play()
                        }
                    }
                }
            }
        }
    }

    /// Update video quality without losing playback state
    func updateQuality(to selectedFile: TubeSDK.VideoFile) {
        queue.async { [weak self] in
            guard let self = self, !self._currentVideoFiles.isEmpty else { return }

            let currentTime = self._player?.currentTime()
            let wasPlaying = self._player?.rate != 0

            self._currentSelectedFile = selectedFile

            // Clean up current player
            self._cleanupCurrentPlayer()

            // Create new player with selected quality
            if let newPlayer = self._createPlayer(for: selectedFile, from: self._currentVideoFiles)
            {
                DispatchQueue.main.async {
                    self._player = newPlayer
                    self._playerViewController?.player = newPlayer

                    // Restore playback state
                    if let currentTime = currentTime {
                        newPlayer.seek(to: currentTime)
                        if wasPlaying {
                            newPlayer.play()
                        }
                    }
                }
            }
        }
    }

    /// Get a PlayerViewController for full-screen presentation
    func getPlayerViewController() -> AVPlayerViewController? {
        return queue.sync { _playerViewController }
    }

    /// Get current playback time for mini player display
    func getCurrentTime() -> CMTime? {
        return queue.sync { _player?.currentTime() }
    }

    /// Check if video is currently playing
    var isPlaying: Bool {
        queue.sync { _player?.rate != 0 }
    }

    /// Play/pause toggle
    func togglePlayback() {
        queue.async { [weak self] in
            guard let self = self, let player = self._player else { return }

            DispatchQueue.main.async {
                if player.rate == 0 {
                    player.play()
                } else {
                    player.pause()
                }
            }
        }
    }

    /// Clean up resources when video is completely dismissed
    func cleanup() {
        queue.async { [weak self] in
            guard let self = self else { return }
            self._cleanupCurrentPlayer()
            DispatchQueue.main.async {
                self._playerViewController = nil
            }
            self._currentVideoInfo = nil
            self._currentVideoFiles = []
            self._currentSelectedFile = nil
        }
    }

    private func _cleanupCurrentPlayer() {
        if let currentPlayer = _player {
            DispatchQueue.main.async {
                currentPlayer.pause()
                currentPlayer.replaceCurrentItem(with: nil)

                // Clean up resource loader delegates
                if let currentItem = currentPlayer.currentItem,
                    let currentAsset = currentItem.asset as? AVURLAsset
                {
                    currentAsset.resourceLoader.setDelegate(nil, queue: nil)
                }
            }
        }
        _player = nil
    }

    private func _createPlayer(
        for selectedFile: TubeSDK.VideoFile?,
        from videoFiles: [TubeSDK.VideoFile]
    ) -> AVPlayer? {
        guard let selectedFile = selectedFile else { return nil }

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
        return _createPlayerWithResourceLoader(
            videoURL: playbackURL,
            videoFile: primary,
            audioFile: audioFile
        )
    }

    private func _createPlayerWithResourceLoader(
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

// MARK: - TCA Dependency
extension VideoPlayerCoordinator: DependencyKey {
    nonisolated(unsafe) static let liveValue: VideoPlayerCoordinator = VideoPlayerCoordinator()
}

extension DependencyValues {
    var videoPlayerCoordinator: VideoPlayerCoordinator {
        get { self[VideoPlayerCoordinator.self] }
        set { self[VideoPlayerCoordinator.self] = newValue }
    }
}
