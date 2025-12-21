//
//  NetworkMonitor.swift
//  PeerTubeApp
//
//  Created on 2024-12-18.
//

import Combine
import Foundation
import Network
import SwiftUI

/// Network monitoring service for bandwidth estimation and connectivity tracking
@MainActor
public final class NetworkMonitor: ObservableObject {
	// MARK: - Published Properties

	@Published public private(set) var isConnected = false
	@Published public private(set) var connectionType: NWInterface.InterfaceType = .other
	@Published public private(set) var isExpensive = false
	@Published public private(set) var isConstrained = false
	@Published public private(set) var estimatedBandwidth: Double = 0  // Mbps
	@Published public private(set) var lastBandwidthTest: Date?
	@Published public private(set) var networkCondition: NetworkQuality = .unknown

	// MARK: - Private Properties

	private let pathMonitor = NWPathMonitor()
	private let monitorQueue = DispatchQueue(label: "NetworkMonitor", qos: .utility)
	private var bandwidthSamples: [BandwidthSample] = []
	private let maxSamples = 5
	private let sampleRetentionPeriod: TimeInterval = 300  // 5 minutes

	// MARK: - Initialization

	public init() {
		startMonitoring()
	}

	deinit {
		pathMonitor.cancel()
	}

	// MARK: - Public Methods

	/// Start network monitoring
	public func startMonitoring() {
		pathMonitor.pathUpdateHandler = { [weak self] path in
			Task { @MainActor in
				self?.handlePathUpdate(path)
			}
		}
		pathMonitor.start(queue: monitorQueue)
	}

	/// Stop network monitoring
	public func stopMonitoring() {
		pathMonitor.cancel()
	}

	/// Perform a bandwidth test
	public func testBandwidth() async {
		await performBandwidthTest()
	}

	/// Get quality recommendation based on current conditions
	public func getQualityRecommendation() -> VideoQualityRecommendation {
		let bandwidth = effectiveBandwidth

		// Consider connection type and constraints
		if isConstrained || connectionType == .cellular && bandwidth < 5.0 {
			return .limit(maxResolution: 480, reason: .constrainedConnection)
		}

		if isExpensive && connectionType == .cellular {
			return .limit(maxResolution: 720, reason: .expensiveConnection)
		}

		// Base recommendation on bandwidth
		switch networkCondition {
		case .excellent:
			return .allow(maxResolution: 1080, adaptiveStreaming: true)
		case .good:
			return .allow(maxResolution: 720, adaptiveStreaming: true)
		case .fair:
			return .allow(maxResolution: 480, adaptiveStreaming: false)
		case .poor:
			return .limit(maxResolution: 240, reason: .poorBandwidth)
		case .unknown:
			return .allow(maxResolution: 480, adaptiveStreaming: false)
		}
	}

	/// Get data usage estimate for a quality level
	public func getDataUsageEstimate(resolution: Int, durationMinutes: Double) -> DataUsageEstimate
	{
		let mbPerMinute = estimateDataUsagePerMinute(resolution: resolution)
		let totalMB = mbPerMinute * durationMinutes

		let costImpact: DataUsageEstimate.CostImpact
		if isExpensive && connectionType == .cellular {
			costImpact = totalMB > 100 ? .high : totalMB > 50 ? .medium : .low
		} else {
			costImpact = .none
		}

		return DataUsageEstimate(
			megabytes: totalMB,
			costImpact: costImpact,
			connectionType: connectionTypeDisplayName
		)
	}

	/// Check if automatic quality switching should be enabled
	public var shouldUseAdaptiveStreaming: Bool {
		return networkCondition != .poor && !isConstrained
	}

	// MARK: - Private Methods

	private func handlePathUpdate(_ path: NWPath) {
		isConnected = path.status == .satisfied
		isExpensive = path.isExpensive
		isConstrained = path.isConstrained

		// Determine connection type
		if path.usesInterfaceType(.wifi) {
			connectionType = .wifi
		} else if path.usesInterfaceType(.cellular) {
			connectionType = .cellular
		} else if path.usesInterfaceType(.wiredEthernet) {
			connectionType = .wiredEthernet
		} else {
			connectionType = .other
		}

		// Update network condition based on path characteristics
		updateNetworkCondition()

		// Perform bandwidth test if we haven't tested recently
		if shouldPerformBandwidthTest() {
			Task {
				await performBandwidthTest()
			}
		}
	}

	private func shouldPerformBandwidthTest() -> Bool {
		guard isConnected else { return false }

		// Don't test too frequently
		if let lastTest = lastBandwidthTest,
			Date().timeIntervalSince(lastTest) < 60
		{
			return false
		}

		// Don't test on expensive connections unless necessary
		if isExpensive && connectionType == .cellular {
			return bandwidthSamples.isEmpty
		}

		return true
	}

	private func performBandwidthTest() async {
		guard isConnected else { return }

		let testSizes = [512_000, 1_048_576]  // 512KB, 1MB
		var results: [Double] = []

		for testSize in testSizes {
			if let bandwidth = await performSingleBandwidthTest(bytes: testSize) {
				results.append(bandwidth)

				// Stop early on expensive connections
				if isExpensive && results.count >= 1 {
					break
				}
			}
		}

		if !results.isEmpty {
			let averageBandwidth = results.reduce(0, +) / Double(results.count)
			await MainActor.run {
				addBandwidthSample(averageBandwidth)
				lastBandwidthTest = Date()
				updateNetworkCondition()
			}
		}
	}

	private func performSingleBandwidthTest(bytes: Int) async -> Double? {
		// Use a reliable test endpoint (in production, you might want to use your own)
		guard let testURL = URL(string: "https://httpbin.org/bytes/\(bytes)") else {
			return nil
		}

		let startTime = Date()

		do {
			let (data, _) = try await URLSession.shared.data(from: testURL)
			let endTime = Date()

			let duration = endTime.timeIntervalSince(startTime)
			let bytesTransferred = Double(data.count)
			let bitsPerSecond = (bytesTransferred * 8) / duration
			let mbps = bitsPerSecond / 1_000_000

			return mbps
		} catch {
			return nil
		}
	}

	private func addBandwidthSample(_ bandwidth: Double) {
		let sample = BandwidthSample(
			bandwidth: bandwidth, timestamp: Date(), connectionType: connectionType)
		bandwidthSamples.append(sample)

		// Remove old samples
		let cutoffTime = Date().addingTimeInterval(-sampleRetentionPeriod)
		bandwidthSamples.removeAll { $0.timestamp < cutoffTime }

		// Keep only recent samples
		if bandwidthSamples.count > maxSamples {
			bandwidthSamples.removeFirst(bandwidthSamples.count - maxSamples)
		}

		// Update estimated bandwidth
		updateEstimatedBandwidth()
	}

	private func updateEstimatedBandwidth() {
		guard !bandwidthSamples.isEmpty else {
			estimatedBandwidth = 0
			return
		}

		// Weight recent samples more heavily
		let now = Date()
		let weightedSum = bandwidthSamples.reduce(0) { sum, sample in
			let age = now.timeIntervalSince(sample.timestamp)
			let weight = max(0.1, 1.0 - (age / sampleRetentionPeriod))
			return sum + (sample.bandwidth * weight)
		}

		let weightSum = bandwidthSamples.reduce(0) { sum, sample in
			let age = now.timeIntervalSince(sample.timestamp)
			let weight = max(0.1, 1.0 - (age / sampleRetentionPeriod))
			return sum + weight
		}

		estimatedBandwidth = weightedSum / weightSum
	}

	private func updateNetworkCondition() {
		let bandwidth = effectiveBandwidth

		// Adjust thresholds based on connection type
		let thresholds = getQualityThresholds(for: connectionType)

		if bandwidth >= thresholds.excellent {
			networkCondition = .excellent
		} else if bandwidth >= thresholds.good {
			networkCondition = .good
		} else if bandwidth >= thresholds.fair {
			networkCondition = .fair
		} else if bandwidth > 0 {
			networkCondition = .poor
		} else {
			networkCondition = .unknown
		}

		// Factor in connection constraints
		if isConstrained || isExpensive {
			networkCondition = min(networkCondition, .fair)
		}
	}

	private var effectiveBandwidth: Double {
		if estimatedBandwidth > 0 {
			return estimatedBandwidth
		}

		// Fallback estimates based on connection type
		switch connectionType {
		case .wifi:
			return 25.0  // Assume decent WiFi
		case .wiredEthernet:
			return 100.0  // Assume good wired connection
		case .cellular:
			return isExpensive ? 5.0 : 15.0  // Conservative cellular estimate
		default:
			return 5.0  // Very conservative
		}
	}

	private func getQualityThresholds(for connectionType: NWInterface.InterfaceType)
		-> QualityThresholds
	{
		switch connectionType {
		case .wifi, .wiredEthernet:
			return QualityThresholds(excellent: 25, good: 10, fair: 5)
		case .cellular:
			return QualityThresholds(excellent: 15, good: 8, fair: 3)
		default:
			return QualityThresholds(excellent: 20, good: 8, fair: 3)
		}
	}

	private func estimateDataUsagePerMinute(resolution: Int) -> Double {
		switch resolution {
		case 0..<360:
			return 5.0  // ~5MB/min for 240p
		case 360..<540:
			return 15.0  // ~15MB/min for 480p
		case 540..<900:
			return 25.0  // ~25MB/min for 720p
		case 900..<1440:
			return 45.0  // ~45MB/min for 1080p
		default:
			return 80.0  // ~80MB/min for higher resolutions
		}
	}

	private var connectionTypeDisplayName: String {
		switch connectionType {
		case .wifi: return "WiFi"
		case .cellular: return "Cellular"
		case .wiredEthernet: return "Ethernet"
		default: return "Unknown"
		}
	}
}

// MARK: - Supporting Types

private struct BandwidthSample {
	let bandwidth: Double  // Mbps
	let timestamp: Date
	let connectionType: NWInterface.InterfaceType
}

private struct QualityThresholds {
	let excellent: Double  // Mbps
	let good: Double
	let fair: Double
}

public enum NetworkQuality: Int, CaseIterable, Comparable {
	case unknown = 0
	case poor = 1
	case fair = 2
	case good = 3
	case excellent = 4

	public var displayName: String {
		switch self {
		case .unknown: return "Unknown"
		case .poor: return "Poor"
		case .fair: return "Fair"
		case .good: return "Good"
		case .excellent: return "Excellent"
		}
	}

	public var color: Color {
		switch self {
		case .unknown: return .gray
		case .poor: return .red
		case .fair: return .orange
		case .good: return .blue
		case .excellent: return .green
		}
	}

	public static func < (lhs: NetworkQuality, rhs: NetworkQuality) -> Bool {
		lhs.rawValue < rhs.rawValue
	}
}

public struct VideoQualityRecommendation {
	let maxResolution: Int
	let adaptiveStreaming: Bool
	let reason: RecommendationReason?

	public static func allow(maxResolution: Int, adaptiveStreaming: Bool)
		-> VideoQualityRecommendation
	{
		VideoQualityRecommendation(
			maxResolution: maxResolution, adaptiveStreaming: adaptiveStreaming, reason: nil)
	}

	public static func limit(maxResolution: Int, reason: RecommendationReason)
		-> VideoQualityRecommendation
	{
		VideoQualityRecommendation(
			maxResolution: maxResolution, adaptiveStreaming: false, reason: reason)
	}

	public enum RecommendationReason {
		case poorBandwidth
		case constrainedConnection
		case expensiveConnection

		public var description: String {
			switch self {
			case .poorBandwidth:
				return "Limited by poor network speed"
			case .constrainedConnection:
				return "Connection is constrained"
			case .expensiveConnection:
				return "Avoiding high data usage on cellular"
			}
		}
	}
}

public struct DataUsageEstimate {
	let megabytes: Double
	let costImpact: CostImpact
	let connectionType: String

	public enum CostImpact {
		case none
		case low
		case medium
		case high

		public var color: Color {
			switch self {
			case .none: return .green
			case .low: return .yellow
			case .medium: return .orange
			case .high: return .red
			}
		}

		public var description: String {
			switch self {
			case .none: return "No additional cost"
			case .low: return "Low data usage"
			case .medium: return "Moderate data usage"
			case .high: return "High data usage"
			}
		}
	}

	public var formattedSize: String {
		if megabytes < 1000 {
			return String(format: "%.0f MB", megabytes)
		} else {
			return String(format: "%.1f GB", megabytes / 1000)
		}
	}
}
