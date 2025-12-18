//
//  VideoPlayerContainerView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import AVKit
import PeerTubeSwift
import SwiftUI

struct VideoPlayerContainerView: View {
	// MARK: - Properties

	let video: VideoDetails

	@EnvironmentObject private var appState: AppState
	@Environment(\.dismiss) private var dismiss

	@State private var player: AVPlayer?
	@State private var isLoading = true
	@State private var error: Error?
	@State private var showingControls = true
	@State private var isFullscreen = false
	@State private var showingQualitySelection = false
	@State private var availableQualities: [VideoQualityOption] = []
	@State private var currentQuality: VideoQualityOption?
	@StateObject private var qualityManager = VideoQualityManager()

	// MARK: - Body

	var body: some View {
		ZStack {
			Color.black.ignoresSafeArea()

			if isLoading {
				loadingView
			} else if let player = player {
				playerView(player)
			} else if error != nil {
				errorView
			}
		}
		.navigationBarHidden(isFullscreen)
		.statusBarHidden(isFullscreen)
		.onAppear {
			setupPlayer()
			qualityManager.startMonitoring()
		}
		.onDisappear {
			cleanup()
			qualityManager.stopMonitoring()
		}
		.sheet(isPresented: $showingQualitySelection) {
			VideoQualitySelectionView(
				appState: appState,
				availableQualities: availableQualities,
				currentQuality: currentQuality,
				isPresented: $showingQualitySelection
			) { selectedQuality in
				switchToQuality(selectedQuality)
			}
		}
	}

	// MARK: - Loading View

	private var loadingView: some View {
		VStack(spacing: 16) {
			ProgressView()
				.scaleEffect(1.5)

			Text("Loading video...")
				.foregroundColor(.white)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	// MARK: - Player View

	private func playerView(_ player: AVPlayer) -> some View {
		GeometryReader { geometry in
			VideoPlayer(player: player)
				.aspectRatio(16 / 9, contentMode: .fit)
				.frame(maxWidth: .infinity, maxHeight: .infinity)
				.onTapGesture {
					withAnimation(.easeInOut(duration: 0.3)) {
						showingControls.toggle()
					}
				}
				.overlay(
					playerOverlay(geometry: geometry),
					alignment: .topLeading
				)
		}
	}

	// MARK: - Player Overlay

	private func playerOverlay(geometry: GeometryProxy) -> some View {
		VStack {
			// Top controls
			if showingControls {
				topControlsView
					.transition(.move(edge: .top).combined(with: .opacity))
			}

			Spacer()

			// Bottom controls
			if showingControls {
				bottomControlsView
					.transition(.move(edge: .bottom).combined(with: .opacity))
			}
		}
		.frame(width: geometry.size.width, height: geometry.size.height)
	}

	// MARK: - Top Controls

	private var topControlsView: some View {
		HStack {
			Button(action: {
				dismiss()
			}) {
				Image(systemName: "chevron.left")
					.font(.title2)
					.foregroundColor(.white)
					.padding(8)
					.background(Color.black.opacity(0.5))
					.clipShape(Circle())
			}

			Spacer()

			VStack(alignment: .trailing, spacing: 4) {
				Text(video.name)
					.font(.headline)
					.foregroundColor(.white)
					.lineLimit(1)

				Text(video.channel.displayName)
					.font(.subheadline)
					.foregroundColor(.white.opacity(0.8))
					.lineLimit(1)
			}

			Spacer()

			Button(action: {
				toggleFullscreen()
			}) {
				Image(
					systemName: isFullscreen
						? "arrow.down.right.and.arrow.up.left"
						: "arrow.up.left.and.arrow.down.right"
				)
				.font(.title2)
				.foregroundColor(.white)
				.padding(8)
				.background(Color.black.opacity(0.5))
				.clipShape(Circle())
			}
		}
		.padding(.horizontal)
		.padding(.top, isFullscreen ? 0 : 8)
	}

	// MARK: - Bottom Controls

	private var bottomControlsView: some View {
		VStack(spacing: 12) {
			// Video progress and time
			videoProgressView

			// Control buttons
			controlButtonsView
		}
		.padding(.horizontal)
		.padding(.bottom, isFullscreen ? 0 : 8)
	}

	// MARK: - Video Progress

	private var videoProgressView: some View {
		HStack(spacing: 8) {
			Text("00:00")
				.font(.caption)
				.foregroundColor(.white)
				.monospacedDigit()

			ProgressView(value: 0.3)
				.progressViewStyle(LinearProgressViewStyle(tint: .white))

			Text("10:30")
				.font(.caption)
				.foregroundColor(.white)
				.monospacedDigit()
		}
	}

	// MARK: - Control Buttons

	private var controlButtonsView: some View {
		HStack(spacing: 24) {
			Button(action: {
				// TODO: Implement previous video
			}) {
				Image(systemName: "backward.end.fill")
					.font(.title2)
					.foregroundColor(.white)
			}

			Button(action: {
				seekBackward()
			}) {
				Image(systemName: "gobackward.15")
					.font(.title2)
					.foregroundColor(.white)
			}

			Button(action: {
				togglePlayPause()
			}) {
				Image(systemName: "play.fill")  // TODO: Update based on play state
					.font(.largeTitle)
					.foregroundColor(.white)
			}

			Button(action: {
				seekForward()
			}) {
				Image(systemName: "goforward.15")
					.font(.title2)
					.foregroundColor(.white)
			}

			Button(action: {
				// TODO: Implement next video
			}) {
				Image(systemName: "forward.end.fill")
					.font(.title2)
					.foregroundColor(.white)
			}

			Spacer()

			Button(action: {
				showingQualitySelection = true
			}) {
				Text(currentQualityLabel)
					.font(.caption)
					.fontWeight(.semibold)
					.foregroundColor(.white)
					.padding(.horizontal, 8)
					.padding(.vertical, 4)
					.background(Color.white.opacity(0.2))
					.clipShape(RoundedRectangle(cornerRadius: 4))
			}

			Button(action: {
				// TODO: Implement more options
			}) {
				Image(systemName: "ellipsis")
					.font(.title2)
					.foregroundColor(.white)
			}
		}
	}

	// MARK: - Error View

	private var errorView: some View {
		VStack(spacing: 16) {
			Image(systemName: "exclamationmark.triangle")
				.font(.largeTitle)
				.foregroundColor(.white)

			Text("Failed to load video")
				.font(.headline)
				.foregroundColor(.white)

			if let error = error {
				Text(error.localizedDescription)
					.font(.subheadline)
					.foregroundColor(.white.opacity(0.8))
					.multilineTextAlignment(.center)
			}

			Button("Retry") {
				setupPlayer()
			}
			.buttonStyle(.borderedProminent)
		}
		.padding()
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	// MARK: - Player Setup

	private func setupPlayer() {
		isLoading = true
		error = nil

		Task {
			do {
				guard let services = appState.services else {
					throw PlayerError.servicesUnavailable
				}

				// Extract available qualities and select optimal one
				extractAvailableQualities()
				guard let selectedQuality = selectOptimalQuality(),
					let streamURL = selectedQuality.url
				else {
					throw PlayerError.noStreamAvailable
				}

				currentQuality = selectedQuality

				await MainActor.run {
					let newPlayer = AVPlayer(url: streamURL)
					self.player = newPlayer
					isLoading = false

					// Auto-hide controls after 3 seconds
					scheduleControlsHiding()
				}
			} catch {
				await MainActor.run {
					self.error = error
					isLoading = false
				}
			}
		}
	}

	// MARK: - Stream Selection

	private func selectBestStream(from video: VideoDetails) -> URL? {
		// First try HLS streaming playlists (preferred for streaming)
		if let hlsPlaylist = video.streamingPlaylists.first(where: { $0.type == 1 }) {
			return URL(string: hlsPlaylist.playlistUrl)
		}

		// Fallback to direct video files, select highest quality available
		let sortedFiles = video.files.sorted { $0.resolution.id > $1.resolution.id }
		if let bestFile = sortedFiles.first,
			let downloadURL = bestFile.fileDownloadUrl
		{
			return URL(string: downloadURL)
		}

		return nil
	}

	// MARK: - Quality Selection

	private var currentQualityLabel: String {
		if let currentQuality = currentQuality {
			return currentQuality.label
		} else {
			return "Auto"
		}
	}

	private func extractAvailableQualities() {
		availableQualities = VideoPlayerUtils.extractQualityOptions(from: video)
	}

	private func selectOptimalQuality() -> VideoQualityOption? {
		return qualityManager.selectOptimalQuality(
			from: availableQualities,
			userPreference: appState.defaultVideoQuality,
			useWiFiOnly: appState.useWiFiOnly
		) ?? availableQualities.first
	}

	private func switchToQuality(_ quality: VideoQualityOption) {
		guard let url = quality.url,
			let player = player
		else { return }

		// Store current time
		let currentTime = player.currentTime()

		// Create new player item with selected quality
		let newPlayerItem = AVPlayerItem(url: url)
		player.replaceCurrentItem(with: newPlayerItem)

		// Seek to previous position
		player.seek(to: currentTime)

		// Update current quality
		currentQuality = quality

		// Resume playback if it was playing
		if player.timeControlStatus == .playing {
			player.play()
		}
	}

	// MARK: - Player Controls

	private func togglePlayPause() {
		guard let player = player else { return }

		if player.rate > 0 {
			player.pause()
		} else {
			player.play()
		}
	}

	private func seekBackward() {
		guard let player = player else { return }
		let currentTime = player.currentTime()
		let newTime = CMTimeSubtract(currentTime, CMTimeMakeWithSeconds(15, 1))
		player.seek(to: newTime)
	}

	private func seekForward() {
		guard let player = player else { return }
		let currentTime = player.currentTime()
		let newTime = CMTimeAdd(currentTime, CMTimeMakeWithSeconds(15, 1))
		player.seek(to: newTime)
	}

	private func toggleFullscreen() {
		withAnimation(.easeInOut(duration: 0.3)) {
			isFullscreen.toggle()
		}
	}

	// MARK: - Controls Management

	private func scheduleControlsHiding() {
		DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
			if showingControls {
				withAnimation(.easeInOut(duration: 0.3)) {
					showingControls = false
				}
			}
		}
	}

	// MARK: - Cleanup

	private func cleanup() {
		player?.pause()
		player = nil
	}
}

// MARK: - Error Types

enum PlayerError: LocalizedError {
	case servicesUnavailable
	case noStreamAvailable

	var errorDescription: String? {
		switch self {
		case .servicesUnavailable:
			return "Video services are not available"
		case .noStreamAvailable:
			return "No video stream is available"
		}
	}

	var recoverySuggestion: String? {
		switch self {
		case .servicesUnavailable:
			return "Please select a PeerTube instance first"
		case .noStreamAvailable:
			return "This video may not be available or may have streaming issues"
		}
	}
}

// MARK: - Preview

#if DEBUG
	struct VideoPlayerContainerView_Previews: PreviewProvider {
		static var previews: some View {
			let sampleVideo = VideoDetails(
				id: "sample-id",
				uuid: "sample-uuid",
				name: "Sample Video",
				description: "A sample video for preview",
				isLive: false,
				duration: 630,
				views: 1234,
				likes: 56,
				dislikes: 2,
				publishedAt: Date(),
				originallyPublishedAt: nil,
				category: VideoCategory(id: 1, label: "Music"),
				licence: VideoLicence(id: 1, label: "Attribution"),
				language: VideoLanguage(id: "en", label: "English"),
				privacy: VideoPrivacy(id: 1, label: "Public"),
				thumbnailURL: URL(string: "https://example.com/thumbnail.jpg"),
				previewURL: URL(string: "https://example.com/preview.jpg"),
				embedURL: URL(string: "https://example.com/embed"),
				channel: VideoChannel(
					id: "channel-id",
					name: "sample-channel",
					displayName: "Sample Channel",
					description: nil,
					avatarURL: nil,
					bannerURL: nil,
					followersCount: 100,
					host: "example.com"
				),
				account: Account(
					id: 1,
					url: "https://example.com/accounts/sample-account",
					name: "sample-account",
					host: "example.com",
					followingCount: 0,
					followersCount: 0,
					createdAt: Date(),
					updatedAt: Date(),
					displayName: "Sample Account",
					description: nil
				),
				tags: ["sample", "video"],
				support: nil,
				nsfw: false,
				waitTranscoding: false,
				state: VideoState(id: 1, label: "Published"),
				scheduledUpdate: nil,
				blacklisted: false,
				blacklistedReason: nil,
				downloadEnabled: true,
				commentsEnabled: true,
				files: []
			)

			VideoPlayerContainerView(video: sampleVideo)
				.environmentObject(AppState())
		}
	}
#endif
