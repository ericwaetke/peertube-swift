//
//  VideoQualitySelectionView.swift
//  PeerTubeApp
//
//  Created on 2024-12-18.
//

import PeerTubeSwift
import SwiftUI

/// View for selecting video quality options
struct VideoQualitySelectionView: View {
	// MARK: - Properties

	@ObservedObject private var appState: AppState
	@State private var selectedQuality: VideoQuality
	@State private var showingAdvanced = false
	@Binding private var isPresented: Bool

	private let availableQualities: [VideoQualityOption]
	private let currentQuality: VideoQualityOption?
	private let onQualitySelected: (VideoQualityOption) -> Void

	// MARK: - Initialization

	init(
		appState: AppState,
		availableQualities: [VideoQualityOption],
		currentQuality: VideoQualityOption? = nil,
		isPresented: Binding<Bool>,
		onQualitySelected: @escaping (VideoQualityOption) -> Void
	) {
		self.appState = appState
		self.availableQualities = availableQualities
		self.currentQuality = currentQuality
		self._isPresented = isPresented
		self.onQualitySelected = onQualitySelected
		self._selectedQuality = State(initialValue: appState.defaultVideoQuality)
	}

	// MARK: - Body

	var body: some View {
		NavigationView {
			List {
				// Current quality section
				if let currentQuality = currentQuality {
					Section("Currently Playing") {
						QualityOptionRow(
							option: currentQuality,
							isSelected: true,
							isCurrent: true
						)
					}
				}

				// Auto quality section
				Section(header: Text("Automatic Quality"), footer: autoQualityFooter) {
					ForEach(VideoQuality.allCases, id: \.rawValue) { quality in
						QualityPreferenceRow(
							quality: quality,
							isSelected: selectedQuality == quality,
							networkCondition: getNetworkCondition()
						) {
							selectedQuality = quality
							appState.defaultVideoQuality = quality
							appState.saveSettings()

							// Apply auto quality selection
							if let autoQuality = selectAutoQuality(preference: quality) {
								onQualitySelected(autoQuality)
								isPresented = false
							}
						}
					}
				}

				// Manual quality selection
				if !availableQualities.isEmpty {
					Section(header: Text("Manual Selection"), footer: manualQualityFooter) {
						ForEach(sortedQualities, id: \.id) { quality in
							QualityOptionRow(
								option: quality,
								isSelected: currentQuality?.id == quality.id,
								isCurrent: false
							) {
								onQualitySelected(quality)
								isPresented = false
							}
						}
					}
				}

				// Advanced settings
				Section("Advanced") {
					NavigationLink(destination: AdvancedQualitySettingsView(appState: appState)) {
						Label("Advanced Settings", systemImage: "gear")
					}

					Button(action: { showingAdvanced.toggle() }) {
						HStack {
							Label("Network Diagnostics", systemImage: "wifi.circle")
							Spacer()
							Image(systemName: showingAdvanced ? "chevron.up" : "chevron.down")
						}
					}
					.foregroundColor(.primary)

					if showingAdvanced {
						NetworkDiagnosticsView()
					}
				}
			}
			.navigationTitle("Video Quality")
			.navigationBarTitleDisplayMode(.inline)
			.toolbar {
				ToolbarItem(placement: .cancellationAction) {
					Button("Cancel") {
						isPresented = false
					}
				}
			}
		}
	}

	// MARK: - Computed Properties

	private var sortedQualities: [VideoQualityOption] {
		availableQualities.sorted { $0.resolution > $1.resolution }
	}

	private var autoQualityFooter: some View {
		VStack(alignment: .leading, spacing: 4) {
			Text(
				"Automatically adjusts quality based on your network connection and device capabilities."
			)
			if appState.useWiFiOnly {
				Text("WiFi-only mode is enabled - cellular streaming limited to low quality.")
					.foregroundColor(.orange)
			}
		}
		.font(.caption)
	}

	private var manualQualityFooter: some View {
		Text(
			"Manual selection overrides automatic quality adjustment. Higher quality uses more data."
		)
		.font(.caption)
	}

	// MARK: - Helper Methods

	private func getNetworkCondition() -> NetworkCondition {
		// This would integrate with actual network monitoring
		// For now, return a mock condition based on settings
		if appState.useWiFiOnly {
			return .wifi
		} else {
			return .cellular
		}
	}

	private func selectAutoQuality(preference: VideoQuality) -> VideoQualityOption? {
		let condition = getNetworkCondition()
		let sortedQualities = availableQualities.sorted { $0.resolution > $1.resolution }

		switch preference {
		case .auto:
			return selectOptimalQuality(for: condition, from: sortedQualities)
		case .low:
			return sortedQualities.first { $0.resolution <= 240 } ?? sortedQualities.last
		case .medium:
			return sortedQualities.first { $0.resolution <= 480 } ?? sortedQualities.last
		case .high:
			return sortedQualities.first { $0.resolution <= 720 } ?? sortedQualities.last
		case .veryHigh:
			return sortedQualities.first { $0.resolution <= 1080 } ?? sortedQualities.first
		}
	}

	private func selectOptimalQuality(
		for condition: NetworkCondition,
		from qualities: [VideoQualityOption]
	) -> VideoQualityOption? {
		switch condition {
		case .wifi:
			// On WiFi, prefer highest quality available
			return qualities.first
		case .cellular:
			// On cellular, be more conservative
			if appState.useWiFiOnly {
				return qualities.first { $0.resolution <= 240 } ?? qualities.last
			} else {
				return qualities.first { $0.resolution <= 480 } ?? qualities.last
			}
		case .poor:
			// Poor connection, use lowest quality
			return qualities.last
		}
	}
}

// MARK: - Supporting Views

struct QualityPreferenceRow: View {
	let quality: VideoQuality
	let isSelected: Bool
	let networkCondition: NetworkCondition
	let action: () -> Void

	var body: some View {
		Button(action: action) {
			HStack {
				VStack(alignment: .leading, spacing: 2) {
					Text(quality.displayName)
						.font(.body)
						.foregroundColor(.primary)

					Text(estimatedQualityDescription)
						.font(.caption)
						.foregroundColor(.secondary)
				}

				Spacer()

				if isSelected {
					Image(systemName: "checkmark")
						.foregroundColor(.accentColor)
						.font(.body.bold())
				}
			}
		}
		.buttonStyle(.plain)
	}

	private var estimatedQualityDescription: String {
		switch quality {
		case .auto:
			switch networkCondition {
			case .wifi:
				return "Up to 1080p on WiFi"
			case .cellular:
				return "Up to 480p on cellular"
			case .poor:
				return "240p for poor connections"
			}
		case .low:
			return "240p - Uses less data"
		case .medium:
			return "480p - Balanced quality"
		case .high:
			return "720p - Good quality"
		case .veryHigh:
			return "1080p - Best quality"
		}
	}
}

struct QualityOptionRow: View {
	let option: VideoQualityOption
	let isSelected: Bool
	let isCurrent: Bool
	var action: (() -> Void)? = nil

	var body: some View {
		Button(action: { action?() }) {
			HStack {
				VStack(alignment: .leading, spacing: 2) {
					HStack {
						Text(option.label)
							.font(.body)
							.foregroundColor(.primary)

						if isCurrent {
							Text("PLAYING")
								.font(.caption2)
								.fontWeight(.bold)
								.foregroundColor(.white)
								.padding(.horizontal, 6)
								.padding(.vertical, 2)
								.background(Color.green)
								.clipShape(RoundedRectangle(cornerRadius: 4))
						}

						if option.isHLS {
							Text("HLS")
								.font(.caption2)
								.fontWeight(.medium)
								.foregroundColor(.blue)
								.padding(.horizontal, 4)
								.padding(.vertical, 1)
								.background(Color.blue.opacity(0.1))
								.clipShape(RoundedRectangle(cornerRadius: 3))
						}
					}

					Text(qualityDetails)
						.font(.caption)
						.foregroundColor(.secondary)
				}

				Spacer()

				if isSelected && !isCurrent {
					Image(systemName: "checkmark")
						.foregroundColor(.accentColor)
						.font(.body.bold())
				}
			}
		}
		.buttonStyle(.plain)
		.disabled(action == nil && !isCurrent)
	}

	private var qualityDetails: String {
		var details = "\(option.resolution)p"

		if option.isHLS {
			details += " • Adaptive streaming"
		} else {
			details += " • Direct file"
		}

		return details
	}
}

struct NetworkDiagnosticsView: View {
	@State private var networkSpeed: String = "Checking..."
	@State private var connectionType: String = "Unknown"

	var body: some View {
		VStack(alignment: .leading, spacing: 8) {
			HStack {
				Text("Connection Type:")
					.font(.caption)
					.foregroundColor(.secondary)
				Spacer()
				Text(connectionType)
					.font(.caption)
					.fontWeight(.medium)
			}

			HStack {
				Text("Estimated Speed:")
					.font(.caption)
					.foregroundColor(.secondary)
				Spacer()
				Text(networkSpeed)
					.font(.caption)
					.fontWeight(.medium)
			}

			Button("Test Connection") {
				testNetworkSpeed()
			}
			.font(.caption)
			.buttonStyle(.bordered)
			.buttonBorderShape(.roundedRectangle(radius: 6))
		}
		.padding(.vertical, 4)
		.onAppear {
			updateNetworkInfo()
		}
	}

	private func updateNetworkInfo() {
		// This would integrate with actual network monitoring
		connectionType = "WiFi"  // Mock data
		networkSpeed = "Fast"  // Mock data
	}

	private func testNetworkSpeed() {
		networkSpeed = "Testing..."

		// Mock network speed test
		DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
			networkSpeed = "25 Mbps"
		}
	}
}

struct AdvancedQualitySettingsView: View {
	@ObservedObject var appState: AppState
	@Environment(\.dismiss) private var dismiss

	var body: some View {
		Form {
			Section(
				header: Text("Streaming Settings"),
				footer: Text("These settings affect video playback quality and data usage.")
			) {
				Toggle("Prefer HLS Streaming", isOn: .constant(true))
					.disabled(true)  // Always prefer HLS for now

				Toggle("Auto-adjust for Battery", isOn: .constant(false))
					.disabled(true)  // Feature for future implementation
			}

			Section(
				header: Text("Data Usage"),
				footer: Text(
					"Control how much data video streaming uses on different connection types.")
			) {
				Toggle("WiFi Only Streaming", isOn: $appState.useWiFiOnly)
					.onChange(of: appState.useWiFiOnly) { _ in
						appState.saveSettings()
					}

				if !appState.useWiFiOnly {
					HStack {
						Text("Cellular Quality Limit")
						Spacer()
						Text("480p")
							.foregroundColor(.secondary)
					}
				}
			}
		}
		.navigationTitle("Advanced Settings")
		.navigationBarTitleDisplayMode(.inline)
	}
}

// MARK: - Supporting Types

enum NetworkCondition {
	case wifi
	case cellular
	case poor
}

// MARK: - Preview

#if DEBUG
	struct VideoQualitySelectionView_Previews: PreviewProvider {
		static var previews: some View {
			let appState = AppState()
			let qualities = [
				VideoQualityOption(label: "1080p", resolution: 1080, url: nil, isHLS: true),
				VideoQualityOption(label: "720p", resolution: 720, url: nil, isHLS: true),
				VideoQualityOption(label: "480p", resolution: 480, url: nil, isHLS: false),
				VideoQualityOption(label: "240p", resolution: 240, url: nil, isHLS: false),
			]

			VideoQualitySelectionView(
				appState: appState,
				availableQualities: qualities,
				currentQuality: qualities[1],
				isPresented: .constant(true)
			) { _ in
				// Mock selection handler
			}
		}
	}
#endif
