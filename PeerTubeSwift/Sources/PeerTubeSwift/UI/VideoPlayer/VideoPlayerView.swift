//
//  VideoPlayerView.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import AVKit
import Foundation
import SwiftUI

/// SwiftUI wrapper for AVPlayerViewController with PeerTube integration
public struct VideoPlayerView: UIViewControllerRepresentable {

	// MARK: - Properties

	private let playerController: VideoPlayerController
	@Binding private var isPresented: Bool

	// MARK: - Initialization

	/// Initialize with video details
	/// - Parameters:
	///   - video: Video details containing streaming URLs
	///   - isPresented: Binding to control presentation
	public init(
		video: VideoDetails,
		isPresented: Binding<Bool>
	) {
		self.playerController = VideoPlayerController(video: video)
		self._isPresented = isPresented
	}

	/// Initialize with direct URL
	/// - Parameters:
	///   - url: Direct video URL
	///   - isPresented: Binding to control presentation
	public init(
		url: URL,
		isPresented: Binding<Bool>
	) {
		self.playerController = VideoPlayerController(url: url)
		self._isPresented = isPresented
	}

	// MARK: - UIViewControllerRepresentable

	public func makeUIViewController(context: Context) -> AVPlayerViewController {
		let controller = AVPlayerViewController()
		controller.player = playerController.player
		controller.delegate = context.coordinator

		// Configure player appearance
		controller.allowsPictureInPicturePlayback = true
		controller.canStartPictureInPictureAutomaticallyFromInline = true

		return controller
	}

	public func updateUIViewController(
		_ uiViewController: AVPlayerViewController,
		context: Context
	) {
		// Update player if needed
		if uiViewController.player !== playerController.player {
			uiViewController.player = playerController.player
		}
	}

	public func makeCoordinator() -> Coordinator {
		Coordinator(self)
	}

	// MARK: - Coordinator

	public class Coordinator: NSObject, AVPlayerViewControllerDelegate {
		private let parent: VideoPlayerView

		init(_ parent: VideoPlayerView) {
			self.parent = parent
		}

		public func playerViewControllerDidStopPictureInPicture(
			_ playerViewController: AVPlayerViewController
		) {
			// Handle PiP stop if needed
		}

		public func playerViewController(
			_ playerViewController: AVPlayerViewController,
			willBeginFullScreenPresentationWithAnimationCoordinator coordinator:
				UIViewControllerTransitionCoordinator
		) {
			// Handle full screen presentation
		}

		public func playerViewController(
			_ playerViewController: AVPlayerViewController,
			willEndFullScreenPresentationWithAnimationCoordinator coordinator:
				UIViewControllerTransitionCoordinator
		) {
			// Handle full screen dismissal
			coordinator.animate(alongsideTransition: nil) { _ in
				// Animation completion
			}
		}
	}
}

// MARK: - Fullscreen Video Player

/// Full-screen video player view
public struct FullscreenVideoPlayerView: View {

	// MARK: - Properties

	private let video: VideoDetails?
	private let url: URL?
	@Binding private var isPresented: Bool
	@StateObject private var playerController: VideoPlayerController

	// MARK: - Initialization

	/// Initialize with video details
	public init(
		video: VideoDetails,
		isPresented: Binding<Bool>
	) {
		self.video = video
		self.url = nil
		self._isPresented = isPresented
		self._playerController = StateObject(wrappedValue: VideoPlayerController(video: video))
	}

	/// Initialize with direct URL
	public init(
		url: URL,
		isPresented: Binding<Bool>
	) {
		self.video = nil
		self.url = url
		self._isPresented = isPresented
		self._playerController = StateObject(wrappedValue: VideoPlayerController(url: url))
	}

	// MARK: - Body

	public var body: some View {
		ZStack {
			Color.black
				.ignoresSafeArea()

			VideoPlayerView(
				video: video ?? createDummyVideo(),
				isPresented: $isPresented
			)
			.onAppear {
				playerController.play()
			}
			.onDisappear {
				playerController.pause()
			}
		}
		.statusBarHidden()
		.navigationBarHidden(true)
	}

	// MARK: - Helper Methods

	private func createDummyVideo() -> VideoDetails {
		// Create a minimal VideoDetails for URL-only initialization
		VideoDetails(
			id: 0,
			uuid: "temp",
			shortUUID: "temp",
			createdAt: Date(),
			updatedAt: Date(),
			privacy: .public,
			duration: 0,
			name: "Video",
			state: .published,
			channel: VideoChannel(
				id: 0,
				url: "",
				name: "temp",
				host: "",
				createdAt: Date(),
				updatedAt: Date(),
				displayName: "Temp",
				ownerAccount: AccountSummary(
					id: 0,
					name: "temp",
					host: "",
					displayName: "Temp"
				)
			),
			account: Account(
				id: 0,
				url: "",
				name: "temp",
				host: "",
				createdAt: Date(),
				updatedAt: Date(),
				displayName: "Temp"
			),
			streamingPlaylists: url.map { _ in
				[
					VideoStreamingPlaylist(
						id: 0,
						type: 1,
						playlistUrl: url?.absoluteString ?? "",
						segmentsSha256Url: ""
					)
				]
			} ?? []
		)
	}
}

// MARK: - Inline Video Player

/// Inline video player for use within other views
public struct InlineVideoPlayerView: View {

	// MARK: - Properties

	private let video: VideoDetails?
	private let url: URL?
	@StateObject private var playerController: VideoPlayerController
	@State private var showingFullscreen = false

	// MARK: - Initialization

	public init(video: VideoDetails) {
		self.video = video
		self.url = nil
		self._playerController = StateObject(wrappedValue: VideoPlayerController(video: video))
	}

	public init(url: URL) {
		self.video = nil
		self.url = url
		self._playerController = StateObject(wrappedValue: VideoPlayerController(url: url))
	}

	// MARK: - Body

	public var body: some View {
		VStack(spacing: 0) {
			// Video player area
			ZStack {
				Color.black

				if playerController.isLoading {
					ProgressView()
						.progressViewStyle(CircularProgressViewStyle(tint: .white))
						.scaleEffect(1.5)
				} else if let error = playerController.error {
					VStack(spacing: 16) {
						Image(systemName: "exclamationmark.triangle")
							.font(.largeTitle)
							.foregroundColor(.white)

						Text("Playback Error")
							.font(.headline)
							.foregroundColor(.white)

						Text(error.localizedDescription)
							.font(.caption)
							.foregroundColor(.gray)
							.multilineTextAlignment(.center)
							.padding(.horizontal)

						Button("Retry") {
							Task {
								await playerController.retry()
							}
						}
						.buttonStyle(.bordered)
						.tint(.white)
					}
				} else {
					VideoPlayerView(
						video: video ?? createDummyVideo(),
						isPresented: .constant(true)
					)
				}

				// Overlay controls
				VStack {
					HStack {
						Spacer()

						Button(action: {
							showingFullscreen = true
						}) {
							Image(systemName: "arrow.up.left.and.arrow.down.right")
								.font(.title2)
								.foregroundColor(.white)
								.padding(8)
								.background(Color.black.opacity(0.6))
								.clipShape(Circle())
						}
						.padding()
					}

					Spacer()

					// Basic controls
					HStack(spacing: 24) {
						Button(action: {
							playerController.seekBackward()
						}) {
							Image(systemName: "gobackward.15")
								.font(.title)
								.foregroundColor(.white)
						}

						Button(action: {
							if playerController.isPlaying {
								playerController.pause()
							} else {
								playerController.play()
							}
						}) {
							Image(
								systemName: playerController.isPlaying ? "pause.fill" : "play.fill"
							)
							.font(.title)
							.foregroundColor(.white)
						}

						Button(action: {
							playerController.seekForward()
						}) {
							Image(systemName: "goforward.15")
								.font(.title)
								.foregroundColor(.white)
						}
					}
					.padding(.bottom)
					.opacity(playerController.showControls ? 1 : 0)
					.animation(.easeInOut(duration: 0.3), value: playerController.showControls)
				}
			}
			.aspectRatio(16 / 9, contentMode: .fit)
			.onTapGesture {
				playerController.toggleControlsVisibility()
			}

			// Video info (if available)
			if let video = video {
				VStack(alignment: .leading, spacing: 8) {
					Text(video.name)
						.font(.headline)
						.lineLimit(2)

					HStack {
						Text("\(video.views) views")
						Text("•")
						Text(video.createdAt, style: .relative)
					}
					.font(.caption)
					.foregroundColor(.secondary)
				}
				.padding()
				.frame(maxWidth: .infinity, alignment: .leading)
			}
		}
		.fullScreenCover(isPresented: $showingFullscreen) {
			if let video = video {
				FullscreenVideoPlayerView(video: video, isPresented: $showingFullscreen)
			} else if let url = url {
				FullscreenVideoPlayerView(url: url, isPresented: $showingFullscreen)
			}
		}
		.onAppear {
			playerController.prepareToPlay()
		}
		.onDisappear {
			playerController.pause()
		}
	}

	// MARK: - Helper Methods

	private func createDummyVideo() -> VideoDetails {
		// Create a minimal VideoDetails for URL-only initialization
		VideoDetails(
			id: 0,
			uuid: "temp",
			shortUUID: "temp",
			createdAt: Date(),
			updatedAt: Date(),
			privacy: .public,
			duration: 0,
			name: "Video",
			state: .published,
			channel: VideoChannel(
				id: 0,
				url: "",
				name: "temp",
				host: "",
				createdAt: Date(),
				updatedAt: Date(),
				displayName: "Temp",
				ownerAccount: AccountSummary(
					id: 0,
					name: "temp",
					host: "",
					displayName: "Temp"
				)
			),
			account: Account(
				id: 0,
				url: "",
				name: "temp",
				host: "",
				createdAt: Date(),
				updatedAt: Date(),
				displayName: "Temp"
			),
			streamingPlaylists: url.map { _ in
				[
					VideoStreamingPlaylist(
						id: 0,
						type: 1,
						playlistUrl: url?.absoluteString ?? "",
						segmentsSha256Url: ""
					)
				]
			} ?? []
		)
	}
}

// MARK: - Preview

#if DEBUG
	struct VideoPlayerView_Previews: PreviewProvider {
		static var previews: some View {
			Group {
				// Inline player preview
				InlineVideoPlayerView(
					url: URL(string: "https://sample-videos.com/zip/10/mp4/mp4-15s.mp4")!
				)
				.previewDisplayName("Inline Player")

				// Fullscreen player preview
				FullscreenVideoPlayerView(
					url: URL(string: "https://sample-videos.com/zip/10/mp4/mp4-15s.mp4")!,
					isPresented: .constant(true)
				)
				.previewDisplayName("Fullscreen Player")
			}
		}
	}
#endif
