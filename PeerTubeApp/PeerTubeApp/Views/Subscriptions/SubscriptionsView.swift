//
//  SubscriptionsView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import PeerTubeSwift
import SwiftUI

struct SubscriptionsView: View {

	// MARK: - Properties

	@EnvironmentObject private var appState: AppState
	@State private var feedVideos: [Video] = []
	@State private var isLoadingFeed = false

	// MARK: - Body

	var body: some View {
		NavigationView {
			Group {
				if appState.subscriptionService.subscriptions.isEmpty
					&& !appState.subscriptionService.isLoading
				{
					emptyStateView
				} else {
					subscriptionsList
				}
			}
			.navigationTitle("Subscriptions")
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						Button("Refresh All") {
							Task {
								await appState.subscriptionService.refreshAllSubscriptions()
							}
						}

						Button("Refresh Feed") {
							Task {
								await loadSubscriptionFeed()
							}
						}

						Button("Manage Subscriptions") {
							// Navigate to subscription management
						}
					} label: {
						Image(systemName: "ellipsis.circle")
					}
				}
			}
			.refreshable {
				Task {
					await appState.subscriptionService.refreshAllSubscriptions()
					await loadSubscriptionFeed()
				}
			}
		}
		.task {
			await loadSubscriptionFeed()
		}
		.overlay {
			if appState.subscriptionService.isLoading
				&& appState.subscriptionService.subscriptions.isEmpty
			{
				ProgressView("Loading subscriptions...")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(Color(UIColor.systemBackground).opacity(0.8))
			}
		}
		.alert("Error", isPresented: .constant(appState.subscriptionService.error != nil)) {
			Button("OK") {
				appState.subscriptionService.clearError()
			}
		} message: {
			if let error = appState.subscriptionService.error {
				Text(error.localizedDescription)
			}
		}
	}

	// MARK: - Empty State

	private var emptyStateView: some View {
		VStack(spacing: 20) {
			Image(systemName: "heart.circle")
				.font(.system(size: 60))
				.foregroundColor(.secondary)

			VStack(spacing: 8) {
				Text("No Subscriptions Yet")
					.font(.title2)
					.fontWeight(.semibold)

				Text("Subscribe to channels to see their latest videos here")
					.font(.body)
					.foregroundColor(.secondary)
					.multilineTextAlignment(.center)
					.padding(.horizontal, 40)
			}

			Button("Browse Channels") {
				appState.selectedTab = .browse
			}
			.buttonStyle(.borderedProminent)
		}
		.frame(maxWidth: .infinity, maxHeight: .infinity)
	}

	// MARK: - Subscriptions List

	private var subscriptionsList: some View {
		ScrollView {
			LazyVStack(spacing: 0) {
				// Recent videos from subscriptions
				if !viewModel.recentVideos.isEmpty {
					recentVideosSection

					Divider()
						.padding(.vertical, 16)
				}

				// Subscribed channels
				subscriptionsSection
			}
			.padding(.horizontal)
		}
	}

	// MARK: - Recent Videos Section

	private var recentVideosSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text("Latest Videos")
					.font(.title2)
					.fontWeight(.semibold)

				Spacer()

				Button("View All") {
					// Navigate to all recent videos
				}
				.font(.subheadline)
				.foregroundColor(.blue)
			}

			ScrollView(.horizontal, showsIndicators: false) {
				LazyHStack(spacing: 12) {
					ForEach(feedVideos.prefix(10)) { video in
						SubscriptionVideoCardView(video: video)
							.frame(width: 280)
							.onTapGesture {
								appState.navigateTo(.videoDetail(videoId: video.uuid))
							}
					}
				}
				.padding(.horizontal, 1)
			}
		}

		// MARK: - Methods

		private func loadSubscriptionFeed() async {
			isLoadingFeed = true
			feedVideos = await appState.subscriptionService.getSubscriptionFeed()
			isLoadingFeed = false
		}
	}

	// MARK: - Subscriptions Section

	private var subscriptionsSection: some View {
		VStack(alignment: .leading, spacing: 12) {
			HStack {
				Text("Channels (\(appState.subscriptionService.subscriptions.count))")
					.font(.title2)
					.fontWeight(.semibold)

				Spacer()

				Button("Sort") {
					// Show sorting options
				}
				.font(.subheadline)
				.foregroundColor(.blue)
			}

			LazyVGrid(
				columns: [
					GridItem(.flexible()),
					GridItem(.flexible()),
				], spacing: 16
			) {
				ForEach(appState.subscriptionService.subscriptions) { subscription in
					SubscriptionChannelCardView(subscription: subscription)
						.onTapGesture {
							appState.navigateTo(
								.channelDetail(channelId: subscription.channel.name))
						}
				}
			}
		}
	}
}

// MARK: - Subscription Video Card

struct SubscriptionVideoCardView: View {
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
			.frame(height: 157)
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
			.overlay(alignment: .topLeading) {
				// New video indicator
				if isRecentVideo {
					Text("NEW")
						.font(.caption2)
						.fontWeight(.bold)
						.foregroundColor(.white)
						.padding(.horizontal, 6)
						.padding(.vertical, 3)
						.background(Color.red)
						.cornerRadius(4)
						.padding(8)
				}
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
					Text(video.publishedAt ?? video.createdAt, style: .relative)
				}
				.font(.caption2)
				.foregroundColor(.secondary)
			}
		}
	}

	private var thumbnailURL: URL? {
		// In a real implementation, build from instance URL and thumbnail path
		return nil
	}

	private var isRecentVideo: Bool {
		let dayAgo = Date().addingTimeInterval(-24 * 60 * 60)
		return (video.publishedAt ?? video.createdAt) > dayAgo
	}
}

// MARK: - Subscription Channel Card

struct SubscriptionChannelCardView: View {
	let subscription: ChannelSubscription

	var body: some View {
		VStack(spacing: 12) {
			// Channel avatar
			AsyncImage(url: avatarURL) { image in
				image
					.resizable()
					.aspectRatio(contentMode: .fill)
			} placeholder: {
				Circle()
					.fill(Color.gray.opacity(0.3))
			}
			.frame(width: 60, height: 60)
			.clipShape(Circle())
			.overlay(alignment: .topTrailing) {
				if subscription.isNotificationEnabled {
					Image(systemName: "bell.fill")
						.font(.caption2)
						.foregroundColor(.blue)
						.background(Color.white)
						.clipShape(Circle())
				}
			}

			// Channel info
			VStack(spacing: 4) {
				Text(subscription.channel.effectiveDisplayName)
					.font(.subheadline)
					.fontWeight(.medium)
					.lineLimit(2)
					.multilineTextAlignment(.center)

				Text("\(subscription.channel.followersCount) followers")
					.font(.caption2)
					.foregroundColor(.secondary)

				Text("Subscribed \(subscription.subscribedAt, style: .relative)")
					.font(.caption2)
					.foregroundColor(.secondary)
			}
		}
		.padding()
		.background(Color(UIColor.secondarySystemBackground))
		.cornerRadius(12)
	}

	private var avatarURL: URL? {
		// In a real implementation, build from instance URL and avatar path
		return nil
	}
}

// MARK: - Preview

#if DEBUG
	struct SubscriptionsView_Previews: PreviewProvider {
		static var previews: some View {
			Group {
				// With subscriptions
				SubscriptionsView()
					.environmentObject(AppState())
					.previewDisplayName("With Subscriptions")

				// Empty state
				SubscriptionsView()
					.environmentObject(AppState())
					.previewDisplayName("Empty State")
			}
		}
	}
#endif
