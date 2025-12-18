//
//  VideoQualityManager.swift
//  PeerTubeApp
//
//  Created on 2024-12-18.
//

import Foundation
import Network
import PeerTubeSwift
import SwiftUI

/// Manager for automatic video quality selection and network monitoring
@MainActor
public final class VideoQualityManager: ObservableObject {
	// MARK: - Published Properties

	@Published public private(set) var currentNetworkCondition: NetworkCondition = .unknown
	@Published public private(set) var estimatedBandwidth: Double = 0  // Mbps
	@Published public private(set) var connectionType: ConnectionType = .unknown
	@Published public private(set) var isMonitoring = false

	// MARK: - Private Properties

	private let pathMonitor = NWPathMonitor()
	private let monitorQueue = DispatchQueue(label: "VideoQualityManager.NetworkMonitor")
	private var bandwidthSamples: [Double] = []
	private let maxSamples = 10

	// MARK: - Initialization

	public init() {
		setupNetworkMonitoring()
	}

	deinit {
		stopMonitoring()
	}

	// MARK: - Public Methods

	/// Start network monitoring
	public func startMonitoring() {
		guard !isMonitoring else { return }

		pathMonitor.start(queue: monitorQueue)
		isMonitoring = true
	}

	/// Stop network monitoring
	public func stopMonitoring() {
		pathMonitor.cancel()
		isMonitoring = false
	}

	/// Select optimal video quality based on current conditions
	/// - Parameters:
	///   - availableQualities: Available quality options
	///   - userPreference: User's quality preference
	///   - useWiFiOnly: Whether to limit quality on cellular
	/// - Returns: Selected quality option
	public func selectOptimalQuality(
		from availableQualities: [VideoQualityOption],
		userPreference: VideoQuality,
		useWiFiOnly: Bool
	) -> VideoQualityOption? {
		guard !availableQualities.isEmpty else { return nil }

		let sortedQualities = availableQualities.sorted { $0.resolution > $1.resolution }

		// Handle manual quality preferences
		switch userPreference {
		case .auto:
			return selectAutoQuality(from: sortedQualities, useWiFiOnly: useWiFiOnly)
		case .low:
			return findQualityNear(resolution: 240, in: sortedQualities)
		case .medium:
			return findQualityNear(resolution: 480, in: sortedQualities)
		case .high:
			return findQualityNear(resolution: 720, in: sortedQualities)
		case .veryHigh:
			return findQualityNear(resolution: 1080, in: sortedQualities)
		}
	}

	/// Get recommended quality for current network conditions
	/// - Parameter availableQualities: Available quality options
	/// - Returns: Recommended quality option
	public func getRecommendedQuality(from availableQualities: [VideoQualityOption])
		-> VideoQualityOption?
	{
		guard !availableQualities.isEmpty else { return nil }

		let sortedQualities = availableQualities.sorted { $0.resolution > $1.resolution }

		switch currentNetworkCondition {
		case .excellent:
			// 1080p+ for excellent connections
			return sortedQualities.first { $0.resolution >= 1080 } ?? sortedQualities.first

		case .good:
			// 720p for good connections
			return sortedQualities.first { $0.resolution <= 720 && $0.resolution >= 480 }
				?? findQualityNear(resolution: 720, in: sortedQualities)

		case .fair:
			// 480p for fair connections
			return sortedQualities.first { $0.resolution <= 480 && $0.resolution >= 240 }
				?? findQualityNear(resolution: 480, in: sortedQualities)

		case .poor:
			// 240p for poor connections
			return sortedQualities.first { $0.resolution <= 240 }
				?? sortedQualities.last

		case .unknown:
			// Default to medium quality when unknown
			return findQualityNear(resolution: 480, in: sortedQualities)
		}
	}

	/// Test network speed and update estimated bandwidth
	public func testNetworkSpeed() async {
		guard let testURL = URL(string: "https://httpbin.org/bytes/1048576") else { return }  // 1MB test

		let startTime = Date()

		do {
			let (data, _) = try await URLSession.shared.data(from: testURL)
			let endTime = Date()
			let duration = endTime.timeIntervalSince(startTime)
			let bytesTransferred = Double(data.count)
			let bitsPerSecond = (bytesTransferred * 8) / duration
			let mbps = bitsPerSecond / 1_000_000

			await MainActor.run {
				updateBandwidthEstimate(mbps)
				updateNetworkCondition()
			}
		} catch {
			// Test failed, maintain current estimates
			print("Network speed test failed: \(error)")
		}
	}

	/// Get quality details for display
	/// - Parameter quality: Quality option
	/// - Returns: Formatted details string
	public func getQualityDetails(for quality: VideoQualityOption) -> String {
		var details = "\(quality.resolution)p"

		if quality.isHLS {
			details += " • HLS"
		}

		// Add estimated data usage
		let estimatedMBPerMinute = estimateDataUsage(for: quality.resolution)
		details += " • ~\(estimatedMBPerMinute)MB/min"

		return details
	}

	/// Check if quality change is recommended
	/// - Parameters:
	///   - currentQuality: Current playing quality
	///   - availableQualities: Available quality options
	/// - Returns: Recommended quality if change is suggested
	public func shouldSwitchQuality(
		from currentQuality: VideoQualityOption,
		availableQualities: [VideoQualityOption]
	) -> VideoQualityOption? {
		let recommended = getRecommendedQuality(from: availableQualities)

		guard let recommended = recommended,
			recommended.id != currentQuality.id
		else {
			return nil
		}

		// Only suggest switching if there's a significant difference
		let resolutionDifference = abs(recommended.resolution - currentQuality.resolution)
		return resolutionDifference >= 240 ? recommended : nil
	}

	// MARK: - Private Methods

	private func setupNetworkMonitoring() {
		pathMonitor.pathUpdateHandler = { [weak self] path in
			Task { @MainActor in
				self?.handleNetworkPathUpdate(path)
			}
		}
	}

	private func handleNetworkPathUpdate(_ path: NWPath) {
		// Update connection type
		if path.usesInterfaceType(.wifi) {
			connectionType = .wifi
		} else if path.usesInterfaceType(.cellular) {
			connectionType = .cellular
		} else if path.usesInterfaceType(.wiredEthernet) {
			connectionType = .ethernet
		} else {
			connectionType = .unknown
		}

		// Update network condition based on path status
		if path.status == .satisfied {
			// Start with a default condition and refine with bandwidth testing
			if connectionType == .wifi || connectionType == .ethernet {
				currentNetworkCondition = .good
			} else {
				currentNetworkCondition = .fair
			}
		} else {
			currentNetworkCondition = .poor
		}
	}

	private func selectAutoQuality(
		from sortedQualities: [VideoQualityOption],
		useWiFiOnly: Bool
	) -> VideoQualityOption? {
		// Apply WiFi-only restriction
		if useWiFiOnly && connectionType != .wifi {
			return sortedQualities.first { $0.resolution <= 240 } ?? sortedQualities.last
		}

		// Select based on network condition and connection type
		switch (currentNetworkCondition, connectionType) {
		case (.excellent, .wifi), (.excellent, .ethernet):
			return sortedQualities.first  // Highest available

		case (.good, .wifi), (.good, .ethernet):
			return sortedQualities.first { $0.resolution <= 1080 } ?? sortedQualities.first

		case (.good, .cellular):
			return sortedQualities.first { $0.resolution <= 720 }
				?? findQualityNear(resolution: 720, in: sortedQualities)

		case (.fair, _):
			return sortedQualities.first { $0.resolution <= 480 }
				?? findQualityNear(resolution: 480, in: sortedQualities)

		case (.poor, _),
			(_, .cellular) where estimatedBandwidth < 5:
			return sortedQualities.first { $0.resolution <= 240 } ?? sortedQualities.last

		default:
			return findQualityNear(resolution: 480, in: sortedQualities)
		}
	}

	private func findQualityNear(
		resolution target: Int,
		in qualities: [VideoQualityOption]
	) -> VideoQualityOption? {
		// Try to find exact match first
		if let exact = qualities.first(where: { $0.resolution == target }) {
			return exact
		}

		// Find closest match
		return qualities.min { quality1, quality2 in
			abs(quality1.resolution - target) < abs(quality2.resolution - target)
		}
	}

	private func updateBandwidthEstimate(_ newSample: Double) {
		bandwidthSamples.append(newSample)

		// Keep only recent samples
		if bandwidthSamples.count > maxSamples {
			bandwidthSamples.removeFirst()
		}

		// Calculate average bandwidth
		estimatedBandwidth = bandwidthSamples.reduce(0, +) / Double(bandwidthSamples.count)
	}

	private func updateNetworkCondition() {
		// Update condition based on bandwidth estimate
		switch estimatedBandwidth {
		case 25...:
			currentNetworkCondition = .excellent
		case 10..<25:
			currentNetworkCondition = .good
		case 3..<10:
			currentNetworkCondition = .fair
		case 0..<3:
			currentNetworkCondition = .poor
		default:
			currentNetworkCondition = .unknown
		}
	}

	private func estimateDataUsage(for resolution: Int) -> Int {
		// Rough estimates for data usage per minute
		switch resolution {
		case 0..<360:
			return 5  // ~5MB/min for 240p
		case 360..<540:
			return 15  // ~15MB/min for 480p
		case 540..<900:
			return 25  // ~25MB/min for 720p
		case 900..<1440:
			return 45  // ~45MB/min for 1080p
		default:
			return 80  // ~80MB/min for 1440p+
		}
	}
}

// MARK: - Supporting Types

public enum NetworkCondition: String, CaseIterable {
	case excellent = "excellent"
	case good = "good"
	case fair = "fair"
	case poor = "poor"
	case unknown = "unknown"

	public var displayName: String {
		switch self {
		case .excellent: return "Excellent"
		case .good: return "Good"
		case .fair: return "Fair"
		case .poor: return "Poor"
		case .unknown: return "Unknown"
		}
	}

	public var color: Color {
		switch self {
		case .excellent: return .green
		case .good: return .blue
		case .fair: return .orange
		case .poor: return .red
		case .unknown: return .gray
		}
	}
}

public enum ConnectionType: String, CaseIterable {
	case wifi = "wifi"
	case cellular = "cellular"
	case ethernet = "ethernet"
	case unknown = "unknown"

	public var displayName: String {
		switch self {
		case .wifi: return "WiFi"
		case .cellular: return "Cellular"
		case .ethernet: return "Ethernet"
		case .unknown: return "Unknown"
		}
	}

	public var systemImage: String {
		switch self {
		case .wifi: return "wifi"
		case .cellular: return "antenna.radiowaves.left.and.right"
		case .ethernet: return "cable.connector"
		case .unknown: return "questionmark.circle"
		}
	}
}

// MARK: - Extensions

extension VideoQuality {
	/// Get the maximum resolution for this quality preference
	public var maxResolution: Int {
		switch self {
		case .auto: return Int.max
		case .low: return 240
		case .medium: return 480
		case .high: return 720
		case .veryHigh: return 1080
		}
	}

	/// Get recommended minimum bandwidth for this quality
	public var recommendedBandwidth: Double {
		switch self {
		case .auto: return 0
		case .low: return 1.5  // 1.5 Mbps for 240p
		case .medium: return 3  // 3 Mbps for 480p
		case .high: return 5  // 5 Mbps for 720p
		case .veryHigh: return 8  // 8 Mbps for 1080p
		}
	}
}
