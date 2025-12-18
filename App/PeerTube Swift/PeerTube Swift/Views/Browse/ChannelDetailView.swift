//
//  ChannelDetailView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import PeerTubeSwift
import SwiftUI

struct ChannelDetailView: View {
	// MARK: - Properties

	let channelId: String

	@EnvironmentObject private var appState: AppState
	@State private var channel: VideoChannel?
	@State private var videos: [Video] = []
	@State private var isLoading = true
	@State private var error: Error?

	// MARK: - Body

	var body: some View {
		Group {
			if isLoading {
				ProgressView("Loading channel...")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
			} else if let channel = channel {
				channelDetailContent(channel)
			} else {
				ContentUnavailableView(
					"Channel Not Found",
					systemImage: "person.crop.circle.badge.exclamationmark",
					description: Text("This channel could not be loaded.")
				)
			}
		}
		.navigationTitle("Channel")
		.navigationBarTitleDisplayMode(.inline)
		.task {
			await loadChannel()
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

	// MARK: - Channel Detail Content

	@ViewBuilder
	private func channelDetailContent(_ channel: VideoChannel) -> some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				// Channel header
				channelHeaderSection(channel)

				// Channel stats and actions
				channelActionsSection(channel)

				// Description
				channelDescriptionSection(channel)

				// Videos section
				videosSection()
			}
			.padding()
		}
	}

	@ViewBuilder
	private func channelHeaderSection(_ channel: VideoChannel) -> some View {
		VStack(spacing: 12) {
			// Banner image
			if let bannerURL = channel.bannerURL {
				AsyncImage(url: bannerURL) { image in
					image
						.resizable()
						.aspectRatio(3, contentMode: .fit)
				} placeholder: {
					Rectangle()
						.fill(Color.gray.opacity(0.3))
						.aspectRatio(3, contentMode: .fit)
				}
				.clipShape(RoundedRectangle(cornerRadius: 8))
			}

			HStack(alignment: .top, spacing: 16) {
				// Avatar
				AsyncImage(url: channel.avatarURL) { image in
					image
						.resizable()
						.aspectRatio(contentMode: .fill)
				} placeholder: {
					Circle()
						.fill(Color.gray.opacity(0.3))
						.overlay(
							Image(systemName: "person.circle.fill")
								.foregroundColor(.gray)
								.font(.largeTitle)
						)
				}
				.frame(width: 80, height: 80)
				.clipShape(Circle())

				// Channel info
				VStack(alignment: .leading, spacing: 4) {
					Text(channel.displayName)
						.font(.title2)
						.fontWeight(.semibold)

					Text("@\(channel.name)")
						.font(.subheadline)
						.foregroundColor(.secondary)

					Text(channel.host)
						.font(.caption)
						.foregroundColor(.secondary)
				}

				Spacer()
			}
		}
	}

	@ViewBuilder
	private func channelActionsSection(_ channel: VideoChannel) -> some View {
		VStack(spacing: 12) {
			// Stats
			HStack(spacing: 20) {
				VStack {
					Text("\(channel.followersCount)")
						.font(.headline)
						.fontWeight(.semibold)
					Text("Followers")
						.font(.caption)
						.foregroundColor(.secondary)
				}

				VStack {
					Text("\(videos.count)")
						.font(.headline)
						.fontWeight(.semibold)
					Text("Videos")
						.font(.caption)
						.foregroundColor(.secondary)
				}

				Spacer()
			}

			// Actions
			HStack(spacing: 12) {
				Button(action: {
					Task {
						if appState.subscriptionService.isSubscribed(to: channelId) {
							await appState.subscriptionService.unsubscribe(from: channelId)
						} else if let channel = self.channel {
							await appState.subscriptionService.subscribe(to: channel)
						}
					}
				}) {
					HStack {
						if appState.subscriptionService.isLoading {
							ProgressView()
								.scaleEffect(0.8)
						} else {
							Image(
								systemName: appState.subscriptionService.isSubscribed(to: channelId)
									? "bell.fill" : "bell")
						}
						Text(
							appState.subscriptionService.isSubscribed(to: channelId)
								? "Unsubscribe" : "Subscribe")
					}
					.frame(maxWidth: .infinity)
				}
				.buttonStyle(.borderedProminent)
				.disabled(appState.subscriptionService.isLoading)

				Button(action: {
					// TODO: Implement share functionality
				}) {
					Image(systemName: "square.and.arrow.up")
				}
				.buttonStyle(.bordered)
			}
		}
		.padding()
		.background(Color(UIColor.secondarySystemBackground))
		.clipShape(RoundedRectangle(cornerRadius: 12))
	}

	@ViewBuilder
	private func channelDescriptionSection(_ channel: VideoChannel) -> some View {
		if let description = channel.description, !description.isEmpty {
			VStack(alignment: .leading, spacing: 8) {
				Text("About")
					.font(.headline)

				Text(description)
					.font(.body)
					.fixedSize(horizontal: false, vertical: true)
			}
		}
	}

	@ViewBuilder
	private func videosSection() -> some View {
		VStack(alignment: .leading, spacing: 12) {
			Text("Videos")
				.font(.headline)

			if videos.isEmpty {
				ContentUnavailableView(
					"No Videos",
					systemImage: "video.slash",
					description: Text("This channel hasn't uploaded any videos yet.")
				)
				.frame(height: 200)
			} else {
				LazyVStack(spacing: 12) {
					ForEach(videos, id: \.id) { video in
						VideoRowView(video: video)
							.onTapGesture {
								navigateToVideo(video.uuid)
							}
					}
				}
			}
		}
	}

	// MARK: - Actions

	private func loadChannel() async {
		guard let services = appState.services else {
			await MainActor.run {
				error = ChannelError.servicesUnavailable
				isLoading = false
			}
			return
		}

		do {
			async let channelDetails = services.channels.getChannel(handle: channelId)
			async let channelVideos = services.videos.getChannelVideos(
				channelHandle: channelId
			)

			let (channel, videosResponse) = try await (channelDetails, channelVideos)

			await MainActor.run {
				self.channel = channel
				self.videos = videosResponse.data
				isLoading = false
			}
		} catch {
			await MainActor.run {
				self.error = error
				isLoading = false
			}
		}
	}

	private func navigateToVideo(_ videoId: String) {
		appState.navigateTo(.videoDetail(videoId: videoId))
	}
}

// MARK: - Video Row View

struct VideoRowView: View {
	let video: Video

	var body: some View {
		HStack(spacing: 12) {
			// Thumbnail
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
			.frame(width: 120, height: 68)
			.clipShape(RoundedRectangle(cornerRadius: 8))

			// Video info
			VStack(alignment: .leading, spacing: 4) {
				Text(video.name)
					.font(.subheadline)
					.fontWeight(.medium)
					.lineLimit(2)

				HStack {
					Text("\(video.views) views")
						.font(.caption)
						.foregroundColor(.secondary)

					Text("•")
						.font(.caption)
						.foregroundColor(.secondary)

					Text(video.publishedAt ?? Date(), style: .relative)
						.font(.caption)
						.foregroundColor(.secondary)
				}

				if video.duration > 0 {
					Text(formatDuration(video.duration))
						.font(.caption2)
						.padding(.horizontal, 6)
						.padding(.vertical, 2)
						.background(Color.black.opacity(0.8))
						.foregroundColor(.white)
						.clipShape(RoundedRectangle(cornerRadius: 4))
				}
			}

			Spacer()
		}
		.background(Color.clear)
	}

	private func formatDuration(_ seconds: Int) -> String {
		let hours = seconds / 3600
		let minutes = (seconds % 3600) / 60
		let remainingSeconds = seconds % 60

		if hours > 0 {
			return String(format: "%d:%02d:%02d", hours, minutes, remainingSeconds)
		} else {
			return String(format: "%d:%02d", minutes, remainingSeconds)
		}
	}
}

// MARK: - Error Types

enum ChannelError: LocalizedError {
	case servicesUnavailable

	var errorDescription: String? {
		switch self {
		case .servicesUnavailable:
			return "Channel services are not available"
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
	struct ChannelDetailView_Previews: PreviewProvider {
		static var previews: some View {
			NavigationView {
				ChannelDetailView(channelId: "sample-channel-id")
					.environmentObject(AppState())
			}
		}
	}
#endif
