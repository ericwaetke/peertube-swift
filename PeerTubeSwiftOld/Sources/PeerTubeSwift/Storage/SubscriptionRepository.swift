//
//  SubscriptionRepository.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import CoreData
import Foundation

/// Repository for managing local channel subscriptions
@MainActor
public final class SubscriptionRepository: ObservableObject {
	// MARK: - Properties

	private let coreDataStack: CoreDataStack
	private let mainContext: NSManagedObjectContext

	/// Published array of all active subscriptions
	@Published public private(set) var subscriptions: [ChannelSubscription] = []

	/// Published count of subscriptions for UI updates
	@Published public private(set) var subscriptionCount: Int = 0

	// MARK: - Initialization

	public init(coreDataStack: CoreDataStack = CoreDataStack.shared) {
		self.coreDataStack = coreDataStack
		mainContext = coreDataStack.mainContext
		loadSubscriptions()
	}

	// MARK: - Subscription Management

	/// Subscribe to a channel
	/// - Parameter channel: The channel to subscribe to
	/// - Returns: The created subscription
	/// - Throws: Core Data errors
	public func subscribe(to channel: VideoChannel) async throws -> ChannelSubscription {
		// Check if already subscribed
		if let existing = try getSubscription(for: channel.name) {
			if !existing.isNotificationEnabled {
				// Re-enable existing subscription
				try await enableSubscription(existing.id)
				return existing
			} else {
				// Already subscribed
				return existing
			}
		}

		// Create new subscription
		let subscriptionId = UUID()
		let now = Date()

		try await coreDataStack.performAsyncBackgroundTask { context in
			// Create or update channel entity
			let channelEntity = try await self.createOrUpdateChannelEntity(
				from: channel,
				in: context
			)

			// Create subscription entity
			let subscriptionEntity = SubscriptionManagedObject(
				entity: NSEntityDescription.entity(
					forEntityName: "Subscription",
					in: context
				)!,
				insertInto: context
			)

			subscriptionEntity.id = subscriptionId
			subscriptionEntity.channelId = channel.name
			subscriptionEntity.subscribedAt = now
			subscriptionEntity.isEnabled = true
			subscriptionEntity.lastCheckedAt = now
			subscriptionEntity.channel = channelEntity

			try context.saveIfNeeded()
		}

		// Reload subscriptions
		loadSubscriptions()

		// Return the created subscription
		return ChannelSubscription(
			id: subscriptionId,
			channel: channel,
			subscribedAt: now,
			isNotificationEnabled: true
		)
	}

	/// Unsubscribe from a channel
	/// - Parameter channelName: The name/handle of the channel
	/// - Throws: Core Data errors
	public func unsubscribe(from channelName: String) async throws {
		try await coreDataStack.performBackgroundTask { context in
			let request: NSFetchRequest<SubscriptionManagedObject> = NSFetchRequest(
				entityName: "Subscription"
			)
			request.predicate = NSPredicate(format: "channelId == %@", channelName)

			let subscriptions = try context.fetch(request)
			for subscription in subscriptions {
				context.delete(subscription)
			}

			try context.saveIfNeeded()
		}

		loadSubscriptions()
	}

	/// Toggle subscription status (enable/disable)
	/// - Parameter subscriptionId: The subscription ID
	/// - Throws: Core Data errors
	public func toggleSubscription(_ subscriptionId: UUID) async throws {
		guard let subscription = subscriptions.first(where: { $0.id == subscriptionId }) else {
			throw SubscriptionError.subscriptionNotFound
		}

		let newStatus = !subscription.isNotificationEnabled

		try await coreDataStack.performBackgroundTask { context in
			let request: NSFetchRequest<SubscriptionManagedObject> = NSFetchRequest(
				entityName: "Subscription"
			)
			request.predicate = NSPredicate(format: "id == %@", subscriptionId as CVarArg)

			let entities = try context.fetch(request)
			if let entity = entities.first {
				entity.isEnabled = newStatus
				try context.saveIfNeeded()
			}
		}

		loadSubscriptions()
	}

	/// Enable a subscription
	/// - Parameter subscriptionId: The subscription ID
	/// - Throws: Core Data errors
	public func enableSubscription(_ subscriptionId: UUID) async throws {
		try await coreDataStack.performBackgroundTask { context in
			let request: NSFetchRequest<SubscriptionManagedObject> = NSFetchRequest(
				entityName: "Subscription"
			)
			request.predicate = NSPredicate(format: "id == %@", subscriptionId as CVarArg)

			let entities = try context.fetch(request)
			if let entity = entities.first {
				entity.isEnabled = true
				try context.saveIfNeeded()
			}
		}

		loadSubscriptions()
	}

	// MARK: - Subscription Queries

	/// Get all subscriptions
	/// - Returns: Array of channel subscriptions
	public func getAllSubscriptions() -> [ChannelSubscription] {
		return subscriptions
	}

	/// Get enabled subscriptions only
	/// - Returns: Array of enabled channel subscriptions
	public func getEnabledSubscriptions() -> [ChannelSubscription] {
		return subscriptions.filter { $0.isNotificationEnabled }
	}

	/// Check if subscribed to a channel
	/// - Parameter channelName: The channel name/handle
	/// - Returns: True if subscribed, false otherwise
	public func isSubscribed(to channelName: String) -> Bool {
		return subscriptions.contains { $0.channel.name == channelName && $0.isNotificationEnabled }
	}

	/// Get subscription for a specific channel
	/// - Parameter channelName: The channel name/handle
	/// - Returns: The subscription if it exists
	/// - Throws: Core Data errors
	public func getSubscription(for channelName: String) throws -> ChannelSubscription? {
		let request: NSFetchRequest<SubscriptionManagedObject> = NSFetchRequest(
			entityName: "Subscription"
		)
		request.predicate = NSPredicate(format: "channelId == %@", channelName)

		let entities = try mainContext.fetch(request)
		guard let entity = entities.first else { return nil }

		return try convertToChannelSubscription(entity)
	}

	/// Get subscription count
	/// - Returns: Total number of active subscriptions
	public func getSubscriptionCount() -> Int {
		return subscriptionCount
	}

	// MARK: - Channel Management

	/// Update channel information (when fetching new data from API)
	/// - Parameter channel: Updated channel information
	/// - Throws: Core Data errors
	public func updateChannel(_ channel: VideoChannel) async throws {
		try await coreDataStack.performAsyncBackgroundTask { context in
			_ = try await self.createOrUpdateChannelEntity(from: channel, in: context)
			try context.saveIfNeeded()
		}

		loadSubscriptions()
	}

	/// Cache video metadata for a channel
	/// - Parameters:
	///   - videos: Array of videos to cache
	///   - channelName: The channel name
	/// - Throws: Core Data errors
	public func cacheVideos(_ videos: [Video], for channelName: String) async throws {
		try await coreDataStack.performBackgroundTask { context in
			// Find the channel
			let channelRequest: NSFetchRequest<ChannelManagedObject> = NSFetchRequest(
				entityName: "Channel"
			)
			channelRequest.predicate = NSPredicate(format: "name == %@", channelName)

			guard let channelEntity = try context.fetch(channelRequest).first else {
				throw SubscriptionError.channelNotFound
			}

			// Update or create video entities
			for video in videos {
				let videoRequest: NSFetchRequest<VideoManagedObject> = NSFetchRequest(
					entityName: "Video"
				)
				videoRequest.predicate = NSPredicate(format: "uuid == %@", video.uuid)

				let existingVideos = try context.fetch(videoRequest)
				let videoEntity: VideoManagedObject

				if let existing = existingVideos.first {
					videoEntity = existing
				} else {
					videoEntity = VideoManagedObject(
						entity: NSEntityDescription.entity(forEntityName: "Video", in: context)!,
						insertInto: context
					)
					videoEntity.uuid = video.uuid
				}

				// Update video properties
				videoEntity.id = String(video.id)
				videoEntity.name = video.name
				videoEntity.videoDescription = video.truncatedDescription
				videoEntity.thumbnailPath = video.thumbnailPath
				videoEntity.duration = Int32(video.duration)
				videoEntity.views = Int32(video.views)
				videoEntity.likes = Int32(video.likes)
				videoEntity.dislikes = Int32(video.dislikes)
				videoEntity.publishedAt = video.publishedAt
				videoEntity.createdAt = video.createdAt
				videoEntity.updatedAt = video.updatedAt
				videoEntity.isLocal = video.isLocal
				videoEntity.state = Int16(video.state.rawValue)
				videoEntity.channel = channelEntity
			}

			try context.saveIfNeeded()
		}
	}

	// MARK: - Bulk Operations

	/// Clear all subscriptions (for testing or reset)
	/// - Throws: Core Data errors
	public func clearAllSubscriptions() async throws {
		try await coreDataStack.performBackgroundTask { context in
			let request: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
				entityName: "Subscription"
			)
			let deleteRequest = NSBatchDeleteRequest(fetchRequest: request)

			try context.execute(deleteRequest)
			try context.saveIfNeeded()
		}

		loadSubscriptions()
	}

	/// Import subscriptions from an array
	/// - Parameter subscriptions: Subscriptions to import
	/// - Throws: Core Data errors
	public func importSubscriptions(_ subscriptions: [ChannelSubscription]) async throws {
		for subscription in subscriptions {
			_ = try await subscribe(to: subscription.channel)
		}
	}

	// MARK: - Private Methods

	private func loadSubscriptions() {
		do {
			let request: NSFetchRequest<SubscriptionManagedObject> = NSFetchRequest(
				entityName: "Subscription"
			)
			request.sortDescriptors = [
				NSSortDescriptor(key: "subscribedAt", ascending: false)
			]

			let entities = try mainContext.fetch(request)
			let convertedSubscriptions = try entities.compactMap { entity in
				try convertToChannelSubscription(entity)
			}

			subscriptions = convertedSubscriptions
			subscriptionCount = subscriptions.count
		} catch {
			print("Failed to load subscriptions: \(error)")
			subscriptions = []
			subscriptionCount = 0
		}
	}

	private func convertToChannelSubscription(_ entity: SubscriptionManagedObject) throws
		-> ChannelSubscription
	{
		let channelEntity = entity.channel
		let channel = VideoChannel(
			id: Int(channelEntity.id) ?? 0,
			url: "https://\(channelEntity.instance.host)/video-channels/\(channelEntity.name)",
			name: channelEntity.name,
			avatars: channelEntity.avatarURL.map {
				[ActorImage(filename: $0, width: nil, height: nil)]
			}
				?? [],
			host: channelEntity.instance.host,
			hostRedundancyAllowed: nil,
			followingCount: 0,
			followersCount: Int(channelEntity.followersCount),
			createdAt: channelEntity.createdAt ?? Date(),
			updatedAt: channelEntity.updatedAt ?? Date(),
			displayName: channelEntity.displayName ?? channelEntity.name,
			description: channelEntity.channelDescription,
			support: nil,
			isLocal: false,
			banners: channelEntity.bannerURL.map {
				[ActorImage(filename: $0, width: nil, height: nil)]
			}
				?? [],
			ownerAccount: AccountSummary(
				id: 0,
				name: "owner",
				host: channelEntity.instance.host,
				displayName: "Channel Owner",
				avatar: nil
			)
		)

		return ChannelSubscription(
			id: entity.id,
			channel: channel,
			subscribedAt: entity.subscribedAt,
			isNotificationEnabled: entity.isEnabled
		)
	}

	private func createOrUpdateChannelEntity(
		from channel: VideoChannel,
		in context: NSManagedObjectContext
	) async throws -> ChannelManagedObject {
		// Find existing channel
		let channelRequest: NSFetchRequest<ChannelManagedObject> = NSFetchRequest(
			entityName: "Channel"
		)
		channelRequest.predicate = NSPredicate(format: "name == %@", channel.name)

		let existingChannels = try context.fetch(channelRequest)
		let channelEntity: ChannelManagedObject

		if let existing = existingChannels.first {
			channelEntity = existing
		} else {
			channelEntity = ChannelManagedObject(
				entity: NSEntityDescription.entity(forEntityName: "Channel", in: context)!,
				insertInto: context
			)
			channelEntity.name = channel.name
		}

		// Update channel properties
		channelEntity.id = String(channel.id)
		channelEntity.displayName = channel.displayName
		channelEntity.channelDescription = channel.description
		channelEntity.avatarURL = channel.primaryAvatar?.filename
		channelEntity.bannerURL = channel.primaryBanner?.filename
		channelEntity.followersCount = Int32(channel.followersCount)
		channelEntity.createdAt = channel.createdAt
		channelEntity.updatedAt = channel.updatedAt

		// Find or create instance entity
		channelEntity.instance = try await createOrUpdateInstanceEntity(
			host: channel.host,
			in: context
		)

		return channelEntity
	}

	private func createOrUpdateInstanceEntity(
		host: String,
		in context: NSManagedObjectContext
	) async throws -> InstanceManagedObject {
		// Find existing instance
		let instanceRequest: NSFetchRequest<InstanceManagedObject> = NSFetchRequest(
			entityName: "Instance"
		)
		instanceRequest.predicate = NSPredicate(format: "host == %@", host)

		let existingInstances = try context.fetch(instanceRequest)
		let instanceEntity: InstanceManagedObject

		if let existing = existingInstances.first {
			instanceEntity = existing
		} else {
			instanceEntity = InstanceManagedObject(
				entity: NSEntityDescription.entity(forEntityName: "Instance", in: context)!,
				insertInto: context
			)
			instanceEntity.id = UUID()
			instanceEntity.host = host
			instanceEntity.addedAt = Date()
			instanceEntity.isDefault = false
		}

		return instanceEntity
	}
}

// MARK: - Supporting Types

/// Local channel subscription model
public struct ChannelSubscription: Identifiable, Codable, Hashable {
	public let id: UUID
	public let channel: VideoChannel
	public let subscribedAt: Date
	public let isNotificationEnabled: Bool

	public init(
		id: UUID = UUID(),
		channel: VideoChannel,
		subscribedAt: Date = Date(),
		isNotificationEnabled: Bool = true
	) {
		self.id = id
		self.channel = channel
		self.subscribedAt = subscribedAt
		self.isNotificationEnabled = isNotificationEnabled
	}
}

/// Subscription-related errors
public enum SubscriptionError: LocalizedError {
	case subscriptionNotFound
	case channelNotFound
	case duplicateSubscription
	case persistenceError(Error)

	public var errorDescription: String? {
		switch self {
		case .subscriptionNotFound:
			return "Subscription not found"
		case .channelNotFound:
			return "Channel not found"
		case .duplicateSubscription:
			return "Already subscribed to this channel"
		case .persistenceError(let error):
			return "Data persistence error: \(error.localizedDescription)"
		}
	}
}

// MARK: - Extensions

extension ChannelSubscription {
	/// Whether this subscription was created recently (within last 24 hours)
	public var isRecent: Bool {
		let dayAgo = Date().addingTimeInterval(-24 * 60 * 60)
		return subscribedAt > dayAgo
	}

	/// Formatted subscription date
	public var formattedSubscriptionDate: String {
		let formatter = DateFormatter()
		formatter.dateStyle = .medium
		return formatter.string(from: subscribedAt)
	}
}
