//
//  ContentView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import PeerTubeSwift
import SwiftUI

struct ContentView: View {

	// MARK: - Properties

	@EnvironmentObject private var appState: AppState
	@State private var showingInstanceSelection = false

	// MARK: - Body

	var body: some View {
		Group {
			if appState.currentInstance == nil || appState.services == nil {
				InstanceSelectionView()
			} else {
				mainTabView
			}
		}
		.alert("Error", isPresented: .constant(appState.error != nil)) {
			Button("OK") {
				appState.error = nil
			}
		} message: {
			if let error = appState.error {
				Text(error.localizedDescription)
			}
		}
		.sheet(isPresented: $showingInstanceSelection) {
			InstanceSelectionView()
		}
	}

	// MARK: - Main Tab View

	private var mainTabView: some View {
		TabView(selection: $appState.selectedTab) {
			NavigationStack(path: $appState.navigationPath) {
				BrowseView()
					.navigationDestination(for: NavigationDestination.self) { destination in
						destinationView(for: destination)
					}
			}
			.tabItem {
				Label(MainTab.browse.title, systemImage: MainTab.browse.systemImage)
			}
			.tag(MainTab.browse)

			NavigationStack(path: $appState.navigationPath) {
				SubscriptionsView()
					.navigationDestination(for: NavigationDestination.self) { destination in
						destinationView(for: destination)
					}
			}
			.tabItem {
				Label(MainTab.subscriptions.title, systemImage: MainTab.subscriptions.systemImage)
			}
			.tag(MainTab.subscriptions)

			NavigationStack(path: $appState.navigationPath) {
				SettingsView()
					.navigationDestination(for: NavigationDestination.self) { destination in
						destinationView(for: destination)
					}
			}
			.tabItem {
				Label(MainTab.settings.title, systemImage: MainTab.settings.systemImage)
			}
			.tag(MainTab.settings)
		}
		.accentColor(.primary)
	}

	// MARK: - Navigation Destinations

	@ViewBuilder
	private func destinationView(for destination: NavigationDestination) -> some View {
		switch destination {
		case .videoDetail(let videoId):
			VideoDetailView(videoId: videoId)

		case .channelDetail(let channelId):
			ChannelDetailView(channelId: channelId)

		case .instanceSelection:
			InstanceSelectionView()

		case .about:
			AboutView()

		case .videoPlayer(let video):
			VideoPlayerContainerView(video: video)
		}
	}
}

// MARK: - Instance Selection View

struct InstanceSelectionView: View {

	@EnvironmentObject private var appState: AppState
	@Environment(\.dismiss) private var dismiss

	@State private var customInstanceURL = ""
	@State private var isLoading = false
	@State private var error: Error?

	// Popular PeerTube instances
	private let popularInstances = [
		("framatube.org", "Framatube"),
		("peertube.cpy.re", "Peertube CPY"),
		("tube.tchncs.de", "TCHNCS Tube"),
		("peertube.social", "PeerTube Social"),
		("video.blender.org", "Blender Video"),
	]

	var body: some View {
		NavigationView {
			List {
				Section {
					ForEach(popularInstances, id: \.0) { host, name in
						Button(action: {
							selectInstance(host: host, name: name)
						}) {
							VStack(alignment: .leading, spacing: 4) {
								Text(name)
									.font(.headline)
									.foregroundColor(.primary)

								Text(host)
									.font(.caption)
									.foregroundColor(.secondary)
							}
							.frame(maxWidth: .infinity, alignment: .leading)
						}
						.buttonStyle(.plain)
					}
				} header: {
					Text("Popular Instances")
				} footer: {
					Text(
						"Select a PeerTube instance to connect to. Each instance has its own community and content."
					)
				}

				Section {
					VStack(spacing: 12) {
						TextField("Enter instance URL", text: $customInstanceURL)
							.textFieldStyle(.roundedBorder)
							.autocapitalization(.none)
							.disableAutocorrection(true)
							.keyboardType(.URL)

						Button("Connect") {
							connectToCustomInstance()
						}
						.buttonStyle(.borderedProminent)
						.disabled(customInstanceURL.isEmpty || isLoading)
					}
					.padding(.vertical, 8)
				} header: {
					Text("Custom Instance")
				} footer: {
					Text("Enter the URL of any PeerTube instance you'd like to connect to.")
				}
			}
			.navigationTitle("Select Instance")
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				if appState.currentInstance != nil {
					ToolbarItem(placement: .cancellationAction) {
						Button("Cancel") {
							dismiss()
						}
					}
				}
			}
			.overlay {
				if isLoading {
					ProgressView("Connecting...")
						.frame(maxWidth: .infinity, maxHeight: .infinity)
						.background(Color(UIColor.systemBackground).opacity(0.8))
				}
			}
		}
		.alert("Connection Error", isPresented: .constant(error != nil)) {
			Button("OK") {
				error = nil
			}
		} message: {
			if let error = error {
				Text(error.localizedDescription)
			}
		}
	}

	// MARK: - Actions

	private func selectInstance(host: String, name: String) {
		let instance = InstanceSummary(
			id: UUID(),
			host: host,
			name: name
		)

		connectToInstance(instance)
	}

	private func connectToCustomInstance() {
		guard !customInstanceURL.isEmpty else { return }

		// Clean up URL
		var urlString = customInstanceURL.trimmingCharacters(in: .whitespacesAndNewlines)
		if !urlString.hasPrefix("http") {
			urlString = "https://" + urlString
		}

		guard let url = URL(string: urlString) else {
			error = InstanceError.invalidURL
			return
		}

		let instance = InstanceSummary(
			id: UUID(),
			host: url.host ?? urlString,
			name: url.host ?? urlString
		)

		connectToInstance(instance)
	}

	private func connectToInstance(_ instance: InstanceSummary) {
		isLoading = true
		error = nil

		Task {
			do {
				await appState.setCurrentInstance(instance)

				// Test connection
				if let services = appState.services {
					let isHealthy = await services.checkHealth()
					if !isHealthy {
						throw InstanceError.connectionFailed
					}
				}

				await MainActor.run {
					isLoading = false
					dismiss()
				}
			} catch {
				await MainActor.run {
					self.error = error
					isLoading = false
				}
			}
		}
	}
}

// MARK: - Error Types

enum InstanceError: LocalizedError {
	case invalidURL
	case connectionFailed

	var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "Invalid instance URL"
		case .connectionFailed:
			return "Failed to connect to instance"
		}
	}

	var recoverySuggestion: String? {
		switch self {
		case .invalidURL:
			return "Please enter a valid PeerTube instance URL"
		case .connectionFailed:
			return "Please check your internet connection and try again"
		}
	}
}

// MARK: - Preview

#if DEBUG
	struct ContentView_Previews: PreviewProvider {
		static var previews: some View {
			Group {
				// Main app view
				ContentView()
					.environmentObject(AppState())
					.previewDisplayName("Main App")

				// Instance selection
				InstanceSelectionView()
					.environmentObject(AppState())
					.previewDisplayName("Instance Selection")
			}
		}
	}
#endif
