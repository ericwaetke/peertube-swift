//
//  SubscriptionManagementView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import PeerTubeSwift
import SwiftUI

struct SubscriptionManagementView: View {

	// MARK: - Properties

	@EnvironmentObject private var appState: AppState
	@State private var showingImportExport = false
	@State private var showingChannelSearch = false
	@State private var showingDeleteConfirmation = false
	@State private var channelToDelete: ChannelSubscription?
	@State private var searchText = ""
	@State private var sortOrder: SortOrder = .dateSubscribed
	@State private var filterEnabled = true

	// MARK: - Body

	var body: some View {
		NavigationView {
			VStack {
				if filteredSubscriptions.isEmpty && !appState.subscriptionService.isLoading {
					emptyStateView
				} else {
					subscriptionsList
				}
			}
			.navigationTitle("Manage Subscriptions")
			.navigationBarTitleDisplayMode(.large)
			.searchable(text: $searchText, prompt: "Search channels")
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Menu {
						Picker("Sort by", selection: $sortOrder) {
							ForEach(SortOrder.allCases, id: \.self) { order in
								Label(order.displayName, systemImage: order.systemImage)
									.tag(order)
							}
						}

						Divider()

						Toggle("Show Enabled Only", isOn: $filterEnabled)
					} label: {
						Image(systemName: "line.3.horizontal.decrease.circle")
					}
				}

				ToolbarItem(placement: .navigationBarTrailing) {
					Menu {
						Button("Add Channel") {
							showingChannelSearch = true
						}

						Button("Import/Export") {
							showingImportExport = true
						}

						Divider()

						Button("Refresh All") {
							Task {
								await appState.subscriptionService.refreshAllSubscriptions()
							}
						}

						Button("Clear All", role: .destructive) {
							Task {
								await appState.subscriptionService.clearAllSubscriptions()
							}
						}
					} label: {
						Image(systemName: "ellipsis.circle")
					}
				}
			}
			.sheet(isPresented: $showingChannelSearch) {
				AddChannelView()
			}
			.sheet(isPresented: $showingImportExport) {
				ImportExportView()
			}
			.alert("Delete Subscription", isPresented: $showingDeleteConfirmation) {
				Button("Cancel", role: .cancel) {
					channelToDelete = nil
				}
				Button("Delete", role: .destructive) {
					if let channel = channelToDelete {
						Task {
							await appState.subscriptionService.unsubscribe(
								from: channel.channel.name)
						}
					}
					channelToDelete = nil
				}
			} message: {
				if let channel = channelToDelete {
					Text(
						"Are you sure you want to unsubscribe from \(channel.channel.effectiveDisplayName)?"
					)
				}
			}
		}
	}

	// MARK: - Computed Properties

	private var filteredSubscriptions: [ChannelSubscription] {
		var subscriptions = appState.subscriptionService.subscriptions

		// Filter by enabled status
		if filterEnabled {
			subscriptions = subscriptions.filter { $0.isNotificationEnabled }
		}

		// Filter by search text
		if !searchText.isEmpty {
			subscriptions = subscriptions.filter { subscription in
				subscription.channel.effectiveDisplayName.localizedCaseInsensitiveContains(
					searchText)
					|| subscription.channel.name.localizedCaseInsensitiveContains(searchText)
			}
		}

		// Sort
		switch sortOrder {
		case .dateSubscribed:
			subscriptions.sort { $0.subscribedAt > $1.subscribedAt }
		case .channelName:
			subscriptions.sort { $0.channel.effectiveDisplayName < $1.channel.effectiveDisplayName }
		case .followerCount:
			subscriptions.sort { $0.channel.followersCount > $1.channel.followersCount }
		}

		return subscriptions
	}

	// MARK: - Views

	private var emptyStateView: some View {
		VStack(spacing: 20) {
			Image(systemName: "bell.slash")
				.font(.system(size: 60))
				.foregroundColor(.secondary)

			VStack(spacing: 8) {
				Text("No Subscriptions")
					.font(.title2)
					.fontWeight(.semibold)

				Text("Subscribe to channels to see them here")
					.font(.subheadline)
					.foregroundColor(.secondary)
					.multilineTextAlignment(.center)
			}

			Button("Add Channel") {
				showingChannelSearch = true
			}
			.buttonStyle(.borderedProminent)
		}
		.padding()
	}

	private var subscriptionsList: some View {
		List {
			Section {
				Text(
					"\(filteredSubscriptions.count) of \(appState.subscriptionService.subscriptionCount) subscriptions"
				)
				.font(.caption)
				.foregroundColor(.secondary)
			}

			ForEach(filteredSubscriptions) { subscription in
				SubscriptionRowView(
					subscription: subscription,
					onToggle: {
						Task {
							await appState.subscriptionService.toggleSubscription(subscription)
						}
					},
					onDelete: {
						channelToDelete = subscription
						showingDeleteConfirmation = true
					}
				)
			}
		}
		.listStyle(.insetGrouped)
		.refreshable {
			await appState.subscriptionService.refreshAllSubscriptions()
		}
		.overlay {
			if appState.subscriptionService.isLoading {
				ProgressView("Loading...")
					.frame(maxWidth: .infinity, maxHeight: .infinity)
					.background(Color(UIColor.systemBackground).opacity(0.8))
			}
		}
	}
}

// MARK: - Supporting Views

struct SubscriptionRowView: View {
	let subscription: ChannelSubscription
	let onToggle: () -> Void
	let onDelete: () -> Void

	var body: some View {
		HStack(spacing: 12) {
			// Channel avatar
			AsyncImage(url: subscription.channel.avatarURL) { image in
				image
					.resizable()
					.aspectRatio(contentMode: .fill)
			} placeholder: {
				Circle()
					.fill(Color.gray.opacity(0.3))
			}
			.frame(width: 44, height: 44)
			.clipShape(Circle())

			// Channel info
			VStack(alignment: .leading, spacing: 4) {
				Text(subscription.channel.effectiveDisplayName)
					.font(.subheadline)
					.fontWeight(.medium)
					.lineLimit(1)

				Text("@\(subscription.channel.name)")
					.font(.caption)
					.foregroundColor(.secondary)

				HStack {
					Text("\(subscription.channel.followersCount) followers")
						.font(.caption2)
						.foregroundColor(.secondary)

					Text("•")
						.font(.caption2)
						.foregroundColor(.secondary)

					Text("Subscribed \(subscription.subscribedAt, style: .relative)")
						.font(.caption2)
						.foregroundColor(.secondary)
				}
			}

			Spacer()

			// Notification toggle
			Toggle("", isOn: .constant(subscription.isNotificationEnabled))
				.labelsHidden()
				.onChange(of: subscription.isNotificationEnabled) { _ in
					onToggle()
				}
		}
		.swipeActions(edge: .trailing, allowsFullSwipe: false) {
			Button("Delete", role: .destructive) {
				onDelete()
			}
		}
		.contextMenu {
			Button("Toggle Notifications") {
				onToggle()
			}

			Button("View Channel") {
				// Navigate to channel detail
			}

			Divider()

			Button("Unsubscribe", role: .destructive) {
				onDelete()
			}
		}
	}
}

struct AddChannelView: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var appState: AppState
	@State private var channelName = ""
	@State private var isLoading = false
	@State private var error: Error?

	var body: some View {
		NavigationView {
			VStack(alignment: .leading, spacing: 20) {
				VStack(alignment: .leading, spacing: 8) {
					Text("Channel Name or Handle")
						.font(.subheadline)
						.fontWeight(.medium)

					TextField("channel@instance.com", text: $channelName)
						.textFieldStyle(.roundedBorder)
						.keyboardType(.emailAddress)
						.autocapitalization(.none)
						.disableAutocorrection(true)

					Text(
						"Enter the full channel handle (e.g., blender@framatube.org) or just the channel name if it's on the current instance."
					)
					.font(.caption)
					.foregroundColor(.secondary)
				}

				if isLoading {
					HStack {
						ProgressView()
							.scaleEffect(0.8)
						Text("Adding subscription...")
					}
				}

				Spacer()
			}
			.padding()
			.navigationTitle("Add Channel")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarLeading) {
					Button("Cancel") {
						dismiss()
					}
				}

				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Add") {
						addChannel()
					}
					.disabled(channelName.isEmpty || isLoading)
				}
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
	}

	private func addChannel() {
		Task {
			isLoading = true
			error = nil

			do {
				await appState.subscriptionService.subscribe(to: channelName)
				dismiss()
			} catch {
				self.error = error
			}

			isLoading = false
		}
	}
}

struct ImportExportView: View {
	@Environment(\.dismiss) private var dismiss
	@EnvironmentObject private var appState: AppState
	@State private var showingFilePicker = false
	@State private var exportFormat: ExportFormat = .json
	@State private var exportedData: String = ""

	var body: some View {
		NavigationView {
			List {
				Section("Export Subscriptions") {
					Picker("Format", selection: $exportFormat) {
						ForEach(ExportFormat.allCases, id: \.self) { format in
							Text(format.displayName).tag(format)
						}
					}

					Button("Export to Files") {
						exportSubscriptions()
					}

					if !exportedData.isEmpty {
						VStack(alignment: .leading) {
							Text("Exported Data:")
								.font(.caption)
								.foregroundColor(.secondary)

							Text(exportedData)
								.font(.caption)
								.padding(8)
								.background(Color(UIColor.secondarySystemBackground))
								.cornerRadius(4)
						}
					}
				}

				Section("Import Subscriptions") {
					Button("Import from Files") {
						showingFilePicker = true
					}

					Text("Import subscription lists in JSON or OPML format")
						.font(.caption)
						.foregroundColor(.secondary)
				}
			}
			.navigationTitle("Import/Export")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					Button("Done") {
						dismiss()
					}
				}
			}
		}
		.fileImporter(
			isPresented: $showingFilePicker,
			allowedContentTypes: [.json, .xml],
			allowsMultipleSelection: false
		) { result in
			// Handle file import
		}
	}

	private func exportSubscriptions() {
		let subscriptions = appState.subscriptionService.exportSubscriptions()

		switch exportFormat {
		case .json:
			exportedData = generateJSONExport(subscriptions)
		case .opml:
			exportedData = generateOPMLExport(subscriptions)
		}
	}

	private func generateJSONExport(_ channels: [VideoChannel]) -> String {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted

		do {
			let data = try encoder.encode(channels)
			return String(data: data, encoding: .utf8) ?? "Error encoding JSON"
		} catch {
			return "Error: \(error.localizedDescription)"
		}
	}

	private func generateOPMLExport(_ channels: [VideoChannel]) -> String {
		var opml = """
			<?xml version="1.0" encoding="UTF-8"?>
			<opml version="1.0">
			<head>
			<title>PeerTube Subscriptions</title>
			</head>
			<body>
			"""

		for channel in channels {
			opml += """
				<outline text="\(channel.effectiveDisplayName)" title="\(channel.effectiveDisplayName)" type="rss" xmlUrl="https://\(channel.host)/feeds/videos.xml?videoChannelId=\(channel.id)" htmlUrl="https://\(channel.host)/video-channels/\(channel.name)" />
				"""
		}

		opml += """
			</body>
			</opml>
			"""

		return opml
	}
}

// MARK: - Supporting Types

enum SortOrder: CaseIterable {
	case dateSubscribed
	case channelName
	case followerCount

	var displayName: String {
		switch self {
		case .dateSubscribed:
			return "Date Subscribed"
		case .channelName:
			return "Channel Name"
		case .followerCount:
			return "Follower Count"
		}
	}

	var systemImage: String {
		switch self {
		case .dateSubscribed:
			return "calendar"
		case .channelName:
			return "textformat.abc"
		case .followerCount:
			return "person.3"
		}
	}
}

enum ExportFormat: CaseIterable {
	case json
	case opml

	var displayName: String {
		switch self {
		case .json:
			return "JSON"
		case .opml:
			return "OPML"
		}
	}
}

// MARK: - Preview

#if DEBUG
	struct SubscriptionManagementView_Previews: PreviewProvider {
		static var previews: some View {
			SubscriptionManagementView()
				.environmentObject(AppState())
		}
	}
#endif
