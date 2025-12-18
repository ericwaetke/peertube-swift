//
//  VideoPlayerView.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import AVFoundation
import SwiftUI

#if canImport(UIKit) && canImport(AVKit)
	import UIKit
	import AVKit

	/// SwiftUI wrapper for AVPlayerViewController with PeerTube integration
	public struct VideoPlayerView: UIViewControllerRepresentable {
		// MARK: - Properties

		private let video: VideoDetails?
		private let url: URL?
		@Binding private var isPresented: Bool

		// MARK: - Initialization

		/// Initialize with video details
		public init(video: VideoDetails, isPresented: Binding<Bool>) {
			self.video = video
			self.url = nil
			self._isPresented = isPresented
		}

		/// Initialize with direct URL
		public init(url: URL, isPresented: Binding<Bool>) {
			self.video = nil
			self.url = url
			self._isPresented = isPresented
		}

		// MARK: - UIViewControllerRepresentable

		public func makeUIViewController(context: Context) -> AVPlayerViewController {
			let controller = AVPlayerViewController()

			// Set up player with URL
			if let streamingURL = getStreamingURL() {
				let player = AVPlayer(url: streamingURL)
				controller.player = player
			}

			// Configure player
			controller.showsPlaybackControls = true
			controller.allowsPictureInPicturePlayback = true

			return controller
		}

		public func updateUIViewController(
			_ uiViewController: AVPlayerViewController, context: Context
		) {
			// Update if needed
		}

		// MARK: - Helper Methods

		private func getStreamingURL() -> URL? {
			if let url = url {
				return url
			}

			guard let video = video else { return nil }

			// Try HLS first
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

			return nil
		}
	}

#elseif canImport(AppKit)

	import AppKit

	/// macOS fallback - basic view
	public struct VideoPlayerView: NSViewRepresentable {
		@Binding private var isPresented: Bool

		public init(video: VideoDetails, isPresented: Binding<Bool>) {
			self._isPresented = isPresented
		}

		public init(url: URL, isPresented: Binding<Bool>) {
			self._isPresented = isPresented
		}

		public func makeNSView(context: Context) -> NSView {
			let view = NSView()
			view.wantsLayer = true
			view.layer?.backgroundColor = NSColor.black.cgColor
			return view
		}

		public func updateNSView(_ nsView: NSView, context: Context) {
			// Update if needed
		}
	}

#else

	/// Fallback for unsupported platforms
	public struct VideoPlayerView: View {
		@Binding private var isPresented: Bool

		public init(video: VideoDetails, isPresented: Binding<Bool>) {
			self._isPresented = isPresented
		}

		public init(url: URL, isPresented: Binding<Bool>) {
			self._isPresented = isPresented
		}

		public var body: some View {
			Rectangle()
				.fill(Color.black)
				.overlay(
					Text("Video playback not supported")
						.foregroundColor(.white)
				)
		}
	}

#endif
