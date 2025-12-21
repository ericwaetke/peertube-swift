//
//  BrowseView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import Combine
import PeerTubeSwift
import SwiftUI

struct BrowseView: View {
	// MARK: - Properties

	@EnvironmentObject private var appState: AppState
	@StateObject private var viewModel = BrowseViewModel()

	// MARK: - Body

	var body: some View {
		NavigationView {
			ScrollView {
				LazyVStack(spacing: 20) {
					// Search bar
					searchSection

					// Featured/Trending videos
					if !viewModel.trendingVideos.isEmpty {
						videoSection(
							title: "Trending",
							videos: viewModel.trendingVideos,
							showViewAll: true
						)
					}

					// Recent videos
					if !viewModel.recentVideos.isEmpty {
						videoSection(
							title: "Recent",
							videos: viewModel.recentVideos,
							showViewAll: true
						)
					}

					// Popular channels
					if !viewModel.popularChannels.isEmpty {
						channelsSection
					}

					// Local videos (if available)
					if !viewModel.localVideos.isEmpty {
						videoSection(
							title: "Local Videos",
							videos: viewModel.localVideos,
							showViewAll: false
						)
					}
				}
				.padding(.horizontal)
			}
			.navigationTitle("Browse")
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						Button("Change Instance") {
							appState.navigateTo(.instanceSelection)
						}

						if let instance = appState.currentInstance {
							Button("About \(instance.name)") {
								// Navigate to instance info
							}
						}

						Button("Refresh") {
							Task {
								await viewModel.loadContent(services: appState.services)
							}
						}
					} label: {
						Image(systemName: "ellipsis.circle")
					}
				}
			}
			.refreshable {
				await viewModel.loadContent(services: appState.services)
			}
		}
		.task {
			await viewModel.loadContent(services: appState.services)
		}
		.overlay {
			if viewModel.isLoading && viewModel.trendingVideos.isEmpty {
				ProgressView("Loading content...")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(Color(UIColor.systemBackground).opacity(0.8))
			}
		}
		.alert("Error", isPresented: .constant(viewModel.error != nil)) {
			Button("OK") {
				viewModel.error = nil
			}
			Button("Retry") {
				Task {
					await viewModel.loadContent(services: appState.services)
				}
			}
		} message: {
			if let error = viewModel.error {
				Text(error.localizedDescription)
			}
		}
	}

	// MARK: - Search Section

	private var searchSection: some View {
		NavigationLink(destination: SearchView()) {
			HStack {
				Image(systemName: "magnifyingglass")
					.foregroundColor(.secondary)

				Text("Search videos and channels...")
					.foregroundColor(.secondary)
					.frame(maxWidth: .infinity, alignment: .leading)

				Spacer()
			}
			.padding()
			.background(Color(UIColor.secondarySystemBackground))
			.cornerRadius(10)
		}
		.buttonStyle(.plain)
	}

	// MARK: - Video Section

	private func videoSection(title: String, videos: [Video], showViewAll: Bool) -> some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text(title)
					.font(.title2)
					.fontWeight(.semibold)

				Spacer()

				if showViewAll {
					Button("View All") {
						// Navigate to full list
					}
					.font(.subheadline)
					.foregroundColor(.blue)
				}
			}

			ScrollView(.horizontal, showsIndicators: false) {
				LazyHStack(spacing: 12) {
					ForEach(videos) { video in
						VideoCardView(video: video)
							.frame(width: 280)
							.onTapGesture {
								appState.navigateTo(.videoDetail(videoId: video.uuid))
							}
					}
				}
				.padding(.horizontal, 1)
			}
		}
	}

	// MARK: - Channels Section

	private var channelsSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text("Popular Channels")
					.font(.title2)
					.fontWeight(.semibold)

				Spacer()

				Button("View All") {
					// Navigate to channels list
				}
				.font(.subheadline)
				.foregroundColor(.blue)
			}

			ScrollView(.horizontal, showsIndicators: false) {
				LazyHStack(spacing: 12) {
					ForEach(viewModel.popularChannels) { channel in
						ChannelCardView(channel: channel)
							.frame(width: 160)
							.onTapGesture {
								appState.navigateTo(.channelDetail(channelId: channel.name))
							}
					}
				}
				.padding(.horizontal, 1)
			}
		}
	}
}

// MARK: - Browse View Model

@MainActor
final class BrowseViewModel: ObservableObject {
	// MARK: - Published Properties

	@Published var trendingVideos: [Video] = []
	@Published var recentVideos: [Video] = []
	@Published var localVideos: [Video] = []
	@Published var popularChannels: [VideoChannel] = []
	@Published var isLoading = false
	@Published var error: Error?

	// MARK: - Methods

	func loadContent(services: PeerTubeServices?) async {
		guard let services = services else { return }

		isLoading = true
		error = nil

		do {
			// Load content concurrently
			async let trending = services.videos.getTrendingVideos(count: 10)
			async let recent = services.videos.getRecentVideos(count: 10)
			async let channels = services.channels.getPopularChannels(count: 8)

			// Try to load local videos (may fail if instance doesn't allow it)
			async let local = services.videos.getLocalVideos(count: 6)

			// Await results
			let (trendingResult, recentResult, channelsResult) = try await (
				trending, recent, channels
			)

			trendingVideos = trendingResult.data
			recentVideos = recentResult.data
			popularChannels = channelsResult.data

			// Local videos might fail, so handle separately
			do {
				let localResult = try await local
				localVideos = localResult.data
			} catch {
				// Local videos not available, ignore error
				localVideos = []
			}

		} catch {
			self.error = error
		}

		isLoading = false
	}
}

// MARK: - Video Card View

struct VideoCardView: View {
	let video: Video

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			// Video thumbnail
			AsyncImage(url: thumbnailURL) { image in
				image
					.resizable()
					.aspectRatio(16 / 9, contentMode: .fill)
			} placeholder: {
				Rectangle()
					.fill(Color.gray.opacity(0.3))
					.aspectRatio(16 / 9, contentMode: .fill)
			}
			.frame(height: 157)  // 280 * 9/16
			.clipped()
			.cornerRadius(12)
			.overlay(alignment: .bottomTrailing) {
				Text(video.formattedDuration)
					.font(.caption2)
					.fontWeight(.medium)
					.foregroundColor(.white)
					.padding(.horizontal, 6)
					.padding(.vertical, 3)
					.background(Color.black.opacity(0.8))
					.cornerRadius(4)
					.padding(8)
			}

			// Video info
			VStack(alignment: .leading, spacing: 4) {
				Text(video.name)
					.font(.subheadline)
					.fontWeight(.medium)
					.lineLimit(2)
					.multilineTextAlignment(.leading)

				Text(video.channel.effectiveDisplayName)
					.font(.caption)
					.foregroundColor(.secondary)
					.lineLimit(1)

				HStack {
					Text("\(video.views) views")
					Text("•")
					Text(video.createdAt, style: .relative)
				}
				.font(.caption2)
				.foregroundColor(.secondary)
			}
		}
	}

	private var thumbnailURL: URL? {
		// In a real implementation, you'd build this from the instance URL and thumbnail path
		// For now, return nil to show placeholder
		return nil
	}
}

// MARK: - Channel Card View

struct ChannelCardView: View {
	let channel: VideoChannel

	var body: some View {
		VStack(spacing: 8) {
			// Channel avatar
			AsyncImage(url: avatarURL) { image in
				image
					.resizable()
					.aspectRatio(contentMode: .fill)
			} placeholder: {
				Circle()
					.fill(Color.gray.opacity(0.3))
			}
			.frame(width: 80, height: 80)
			.clipShape(Circle())

			// Channel info
			VStack(spacing: 4) {
				Text(channel.effectiveDisplayName)
					.font(.subheadline)
					.fontWeight(.medium)
					.lineLimit(1)

				Text("\(channel.followersCount) followers")
					.font(.caption2)
					.foregroundColor(.secondary)
			}
		}
		.frame(maxWidth: .infinity)
	}

	private var avatarURL: URL? {
		// In a real implementation, you'd build this from the instance URL and avatar path
		// For now, return nil to show placeholder
		return nil
	}
}

// MARK: - Placeholder Views

struct SearchView: View {
	var body: some View {
		Text("Search View")
			.navigationTitle("Search")
			.navigationBarTitleDisplayMode(.large)
	}
}

// MARK: - Preview

#if DEBUG
	struct BrowseView_Previews: PreviewProvider {
		static var previews: some View {
			BrowseView()
				.environmentObject(AppState())
		}
	}
#endif
