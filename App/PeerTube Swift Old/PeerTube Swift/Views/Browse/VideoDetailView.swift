//
//  VideoDetailView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import PeerTubeSwift
import SwiftUI

struct VideoDetailView: View {
	// MARK: - Properties

	let videoId: String

	@EnvironmentObject private var appState: AppState
	@State private var video: VideoDetails?
	@State private var isLoading = true
	@State private var error: Error?

	// MARK: - Body

	var body: some View {
		Group {
			if isLoading {
				ProgressView("Loading video...")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else if let video = video {
				videoDetailContent(video)
			} else {
				ContentUnavailableView(
					"Video Not Found",
					systemImage: "exclamationmark.video",
					description: Text("This video could not be loaded.")
				)
			}
		}
		.navigationTitle("Video")
		.navigationBarTitleDisplayMode(.inline)
		.task {
			await loadVideo()
		}
		.alert("Error", isPresented: .constant(error != nil)) {
			Button("OK") {
				error = nil
			}
		} message: {
			if let error = error {
				Text(error.localizedDescription)
			}
		}
	}

	// MARK: - Video Detail Content

	@ViewBuilder
	private func videoDetailContent(_ video: VideoDetails) -> some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				// Video player section
				videoPlayerSection(video)

				// Video information
				videoInfoSection(video)

				// Actions
				actionsSection(video)

				// Description
				descriptionSection(video)

				// Channel info
				channelSection(video)
			}
			.padding()
		}
	}

	@ViewBuilder
	private func videoPlayerSection(_ video: VideoDetails) -> some View {
		VStack {
			AsyncImage(url: video.thumbnailURL) { image in
				image
					.resizable()
					.aspectRatio(16 / 9, contentMode: .fit)
			} placeholder: {
				Rectangle()
					.fill(Color.gray.opacity(0.3))
					.aspectRatio(16 / 9, contentMode: .fit)
					.overlay(
						ProgressView()
					)
			}
			.clipShape(RoundedRectangle(cornerRadius: 8))

			Button("Play Video") {
				playVideo(video)
			}
			.buttonStyle(.borderedProminent)
			.controlSize(.large)
		}
	}

	@ViewBuilder
	private func videoInfoSection(_ video: VideoDetails) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text(video.name)
				.font(.title2)
				.fontWeight(.semibold)

			HStack {
				Text("\(video.views) views")
					.font(.caption)
					.foregroundColor(.secondary)

				Spacer()

				Text(video.publishedAt ?? Date(), style: .date)
					.font(.caption)
					.foregroundColor(.secondary)
			}
		}
	}

	@ViewBuilder
	private func actionsSection(_: VideoDetails) -> some View {
		HStack(spacing: 20) {
			Button(action: {
				// TODO: Implement like functionality
			}) {
				Label("Like", systemImage: "hand.thumbsup")
			}
			.buttonStyle(.bordered)

			Button(action: {
				// TODO: Implement share functionality
			}) {
				Label("Share", systemImage: "square.and.arrow.up")
			}
			.buttonStyle(.bordered)

			Button(action: {
				// TODO: Implement save functionality
			}) {
				Label("Save", systemImage: "bookmark")
			}
			.buttonStyle(.bordered)

			Spacer()
		}
	}

	@ViewBuilder
	private func descriptionSection(_ video: VideoDetails) -> some View {
		if let description = video.description, !description.isEmpty {
			VStack(alignment: .leading, spacing: 8) {
				Text("Description")
					.font(.headline)

				Text(description)
					.font(.body)
					.fixedSize(horizontal: false, vertical: true)
			}
		}
	}

	@ViewBuilder
	private func channelSection(_ video: VideoDetails) -> some View {
		VStack(alignment: .leading, spacing: 8) {
			Text("Channel")
				.font(.headline)

			Button(action: {
				navigateToChannel(video.channel.name)
			}) {
				HStack {
					AsyncImage(url: video.channel.avatarURL) { image in
						image
							.resizable()
							.aspectRatio(contentMode: .fill)
					} placeholder: {
						Circle()
							.fill(Color.gray.opacity(0.3))
							.overlay(
								Image(systemName: "person.circle.fill")
									.foregroundColor(.gray)
							)
					}
					.frame(width: 44, height: 44)
					.clipShape(Circle())

					VStack(alignment: .leading, spacing: 2) {
						Text(video.channel.displayName)
							.font(.subheadline)
							.fontWeight(.medium)
							.foregroundColor(.primary)

						Text("@\(video.channel.name)")
							.font(.caption)
							.foregroundColor(.secondary)
					}

					Spacer()

					Button(action: {
						Task {
							if appState.subscriptionService.isSubscribed(to: video.channel.name) {
								await appState.subscriptionService.unsubscribe(
									from: video.channel.name)
							} else {
								await appState.subscriptionService.subscribe(to: video.channel)
							}
						}
					}) {
						HStack(spacing: 4) {
							if appState.subscriptionService.isLoading {
								ProgressView()
									.scaleEffect(0.7)
							} else {
								Image(
									systemName: appState.subscriptionService.isSubscribed(
										to: video.channel.name)
										? "bell.fill" : "bell")
							}
							Text(
								appState.subscriptionService.isSubscribed(to: video.channel.name)
									? "Subscribed" : "Subscribe"
							)
							.font(.caption)
						}
					}
					.buttonStyle(.bordered)
					.controlSize(.small)
					.disabled(appState.subscriptionService.isLoading)

					Image(systemName: "chevron.right")
						.foregroundColor(.secondary)
						.font(.caption)
				}
			}
			.buttonStyle(.plain)
		}
	}

	// MARK: - Actions

	private func loadVideo() async {
		guard let services = appState.services else {
			await MainActor.run {
				error = VideoError.servicesUnavailable
				isLoading = false
			}
			return
		}

		do {
			let videoDetails = try await services.videos.getVideo(id: videoId)
			await MainActor.run {
				self.video = videoDetails
				isLoading = false
			}
		} catch {
			await MainActor.run {
				self.error = error
				isLoading = false
			}
		}
	}

	private func playVideo(_ video: VideoDetails) {
		appState.navigateTo(.videoPlayer(video: video))
	}

	private func navigateToChannel(_ channelId: String) {
		appState.navigateTo(.channelDetail(channelId: channelId))
	}
}

// MARK: - Error Types

enum VideoError: LocalizedError {
	case servicesUnavailable

	var errorDescription: String? {
		switch self {
		case .servicesUnavailable:
			return "Video services are not available"
		}
	}

	var recoverySuggestion: String? {
		switch self {
		case .servicesUnavailable:
			return "Please select a PeerTube instance first"
		}
	}
}

// MARK: - Preview

#if DEBUG
	struct VideoDetailView_Previews: PreviewProvider {
		static var previews: some View {
			NavigationView {
				VideoDetailView(videoId: "sample-video-id")
					.environmentObject(AppState())
			}
		}
	}
#endif
