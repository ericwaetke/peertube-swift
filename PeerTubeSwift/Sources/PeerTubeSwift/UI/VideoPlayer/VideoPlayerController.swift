//
//  VideoPlayerController.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import AVFoundation
import Combine
import Foundation

/// Controller for managing AVPlayer with PeerTube video playback
@MainActor
public final class VideoPlayerController: ObservableObject {
	// MARK: - Published Properties

	/// The underlying AVPlayer instance
	@Published public private(set) var player: AVPlayer?

	/// Current playback state
	@Published public private(set) var isPlaying = false

	/// Whether the player is currently loading content
	@Published public private(set) var isLoading = false

	/// Current playback error, if any
	@Published public private(set) var error: VideoPlayerError?

	/// Whether controls should be visible
	@Published public private(set) var showControls = true

	/// Current playback time
	@Published public private(set) var currentTime: TimeInterval = 0

	/// Total duration of the video
	@Published public private(set) var duration: TimeInterval = 0

	/// Current playback rate
	@Published public private(set) var playbackRate: Float = 1.0

	/// Whether the video has finished playing
	@Published public private(set) var hasFinished = false

	// MARK: - Private Properties

	private let video: VideoDetails?
	private let directURL: URL?
	private var timeObserver: Any?
	private var cancellables = Set<AnyCancellable>()
	private var controlsHideTimer: Timer?

	// MARK: - Initialization

	/// Initialize with video details
	/// - Parameter video: VideoDetails containing streaming information
	public init(video: VideoDetails) {
		self.video = video
		self.directURL = nil
		Task {
			await setupPlayer()
		}
	}

	/// Initialize with direct URL
	/// - Parameter url: Direct video URL
	public init(url: URL) {
		self.video = nil
		self.directURL = url
		Task {
			await setupPlayer()
		}
	}

	deinit {
		cleanupPlayer()
	}

	// MARK: - Public Methods

	/// Prepare the player for playback without starting
	public func prepareToPlay() {
		guard player == nil else { return }
		Task {
			await setupPlayer()
		}
	}

	/// Start or resume playback
	public func play() {
		player?.play()
		isPlaying = true
		hideControlsAfterDelay()
	}

	/// Pause playback
	public func pause() {
		player?.pause()
		isPlaying = false
		showControls = true
		cancelControlsHideTimer()
	}

	/// Stop playback and reset
	public func stop() {
		player?.pause()
		player?.seek(to: .zero)
		isPlaying = false
		currentTime = 0
		hasFinished = false
		showControls = true
		cancelControlsHideTimer()
	}

	/// Seek to specific time
	/// - Parameter time: Target time in seconds
	public func seek(to time: TimeInterval) {
		let cmTime = CMTime(seconds: time, preferredTimescale: 600)
		player?.seek(to: cmTime) { [weak self] _ in
			Task { @MainActor in
				self?.currentTime = time
			}
		}
	}

	/// Seek forward by 15 seconds
	public func seekForward() {
		let newTime = min(currentTime + 15, duration)
		seek(to: newTime)
	}

	/// Seek backward by 15 seconds
	public func seekBackward() {
		let newTime = max(currentTime - 15, 0)
		seek(to: newTime)
	}

	/// Toggle play/pause
	public func togglePlayback() {
		if isPlaying {
			pause()
		} else {
			play()
		}
	}

	/// Set playback rate
	/// - Parameter rate: Playback rate (0.5x, 1x, 1.25x, 1.5x, 2x, etc.)
	public func setPlaybackRate(_ rate: Float) {
		player?.rate = rate
		playbackRate = rate
		if rate > 0 {
			isPlaying = true
		}
	}

	/// Toggle controls visibility
	public func toggleControlsVisibility() {
		showControls.toggle()
		if showControls && isPlaying {
			hideControlsAfterDelay()
		} else {
			cancelControlsHideTimer()
		}
	}

	/// Retry playback after an error
	public func retry() async {
		error = nil
		await setupPlayer()
	}

	/// Get the best quality streaming URL from video details
	public func getBestStreamingURL() -> URL? {
		guard let video = video else {
			return directURL
		}

		// Priority: HLS playlist > best quality file > any file
		if let hlsPlaylist = video.streamingPlaylists.first(where: { $0.type == 1 }),
			let url = URL(string: hlsPlaylist.playlistUrl)
		{
			return url
		}

		// Fallback to best quality file
		if let bestFile = video.bestQualityFile,
			let downloadUrl = bestFile.fileDownloadUrl,
			let url = URL(string: downloadUrl)
		{
			return url
		}

		return directURL
	}

	/// Get available quality options
	public func getQualityOptions() -> [VideoQualityOption] {
		guard let video = video else { return [] }

		var options: [VideoQualityOption] = []

		// Add HLS options
		for playlist in video.streamingPlaylists where playlist.type == 1 {
			for file in playlist.files {
				options.append(
					VideoQualityOption(
						label: file.resolution.label,
						resolution: file.resolution.id,
						url: URL(string: playlist.playlistUrl),
						isHLS: true
					)
				)
			}
		}

		// Add direct file options
		for file in video.files {
			if let downloadUrl = file.fileDownloadUrl,
				let url = URL(string: downloadUrl)
			{
				options.append(
					VideoQualityOption(
						label: file.resolution.label,
						resolution: file.resolution.id,
						url: url,
						isHLS: false
					)
				)
			}
		}

		return options.sorted { $0.resolution > $1.resolution }
	}

	// MARK: - Private Methods

	private func setupPlayer() async {
		isLoading = true
		error = nil

		guard let url = getBestStreamingURL() else {
			error = .invalidURL
			isLoading = false
			return
		}

		do {
			// Create player item
			let playerItem = AVPlayerItem(url: url)

			// Create player
			let newPlayer = AVPlayer(playerItem: playerItem)

			// Configure audio session
			try AVAudioSession.sharedInstance().setCategory(
				.playback,
				mode: .moviePlayback,
				options: []
			)

			// Set up observations
			setupPlayerObservations(player: newPlayer, item: playerItem)

			// Update UI
			player = newPlayer
			isLoading = false

		} catch {
			self.error = .audioSessionError(error)
			isLoading = false
		}
	}

	private func setupPlayerObservations(player: AVPlayer, item: AVPlayerItem) {
		// Time observation
		let timeScale = CMTimeScale(NSEC_PER_SEC)
		let time = CMTime(seconds: 0.5, preferredTimescale: timeScale)

		timeObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main) {
			[weak self] time in
			Task { @MainActor in
				self?.currentTime = time.seconds
			}
		}

		// Player item status observation
		item.publisher(for: \.status)
			.sink { [weak self] status in
				Task { @MainActor in
					await self?.handlePlayerItemStatusChange(status)
				}
			}
			.store(in: &cancellables)

		// Duration observation
		item.publisher(for: \.duration)
			.sink { [weak self] duration in
				Task { @MainActor in
					if duration.isValid && !duration.isIndefinite {
						self?.duration = duration.seconds
					}
				}
			}
			.store(in: &cancellables)

		// Playback finished notification
		NotificationCenter.default.publisher(for: .AVPlayerItemDidPlayToEndTime, object: item)
			.sink { [weak self] _ in
				Task { @MainActor in
					self?.handlePlaybackFinished()
				}
			}
			.store(in: &cancellables)

		// Playback stalled notification
		NotificationCenter.default.publisher(for: .AVPlayerItemPlaybackStalled, object: item)
			.sink { [weak self] _ in
				Task { @MainActor in
					self?.handlePlaybackStalled()
				}
			}
			.store(in: &cancellables)

		// Failed to play to end time notification
		NotificationCenter.default.publisher(for: .AVPlayerItemFailedToPlayToEndTime, object: item)
			.sink { [weak self] notification in
				Task { @MainActor in
					if let error = notification.userInfo?[AVPlayerItemFailedToPlayToEndTimeErrorKey]
						as? Error
					{
						self?.error = .playbackError(error)
					}
				}
			}
			.store(in: &cancellables)
	}

	private func handlePlayerItemStatusChange(_ status: AVPlayerItem.Status) async {
		switch status {
		case .readyToPlay:
			isLoading = false
			error = nil
		case .failed:
			isLoading = false
			if let playerError = player?.currentItem?.error {
				error = .playbackError(playerError)
			} else {
				error = .unknown
			}
		case .unknown:
			isLoading = true
		@unknown default:
			break
		}
	}

	private func handlePlaybackFinished() {
		isPlaying = false
		hasFinished = true
		showControls = true
		cancelControlsHideTimer()
	}

	private func handlePlaybackStalled() {
		// Handle stalled playback - could show buffering indicator
		isLoading = true
	}

	private func hideControlsAfterDelay() {
		cancelControlsHideTimer()
		controlsHideTimer = Timer.scheduledTimer(withTimeInterval: 3.0, repeats: false) {
			[weak self] _ in
			Task { @MainActor in
				if self?.isPlaying == true {
					self?.showControls = false
				}
			}
		}
	}

	private func cancelControlsHideTimer() {
		controlsHideTimer?.invalidate()
		controlsHideTimer = nil
	}

	private func cleanupPlayer() {
		// Remove time observer
		if let timeObserver = timeObserver {
			player?.removeTimeObserver(timeObserver)
			self.timeObserver = nil
		}

		// Cancel all subscriptions
		cancellables.removeAll()

		// Cancel timer
		cancelControlsHideTimer()

		// Clean up player
		player?.pause()
		player = nil
	}
}

// MARK: - Supporting Types

/// Video quality option for quality selection
public struct VideoQualityOption: Sendable, Identifiable, Hashable {
	public let id = UUID()
	public let label: String
	public let resolution: Int
	public let url: URL?
	public let isHLS: Bool

	public init(label: String, resolution: Int, url: URL?, isHLS: Bool) {
		self.label = label
		self.resolution = resolution
		self.url = url
		self.isHLS = isHLS
	}

	/// Display name for UI
	public var displayName: String {
		"\(label)\(isHLS ? " (HLS)" : "")"
	}
}

/// Video player specific errors
public enum VideoPlayerError: LocalizedError, Sendable {
	case invalidURL
	case audioSessionError(Error)
	case playbackError(Error)
	case networkError
	case unsupportedFormat
	case unknown

	public var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "Invalid video URL"
		case .audioSessionError(let error):
			return "Audio session error: \(error.localizedDescription)"
		case .playbackError(let error):
			return "Playback error: \(error.localizedDescription)"
		case .networkError:
			return "Network connection error"
		case .unsupportedFormat:
			return "Unsupported video format"
		case .unknown:
			return "Unknown playback error"
		}
	}

	public var recoverySuggestion: String? {
		switch self {
		case .invalidURL:
			return "Please check the video URL and try again"
		case .audioSessionError:
			return "Please check your audio settings and try again"
		case .playbackError:
			return "Please try playing the video again"
		case .networkError:
			return "Please check your internet connection and try again"
		case .unsupportedFormat:
			return "This video format is not supported on this device"
		case .unknown:
			return "Please try again or contact support"
		}
	}
}

// MARK: - Extensions

extension CMTime {
	/// Convert CMTime to seconds as TimeInterval
	var seconds: TimeInterval {
		return isValid && !isIndefinite ? CMTimeGetSeconds(self) : 0
	}
}
