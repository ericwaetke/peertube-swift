//
//  PeerTubeDataModel.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import CoreData
import Foundation

/// Core Data model builder for PeerTube entities
public class PeerTubeDataModel {

	/// Create and return the managed object model
	public static func createModel() -> NSManagedObjectModel {
		let model = NSManagedObjectModel()

		// Create entities
		let channelEntity = createChannelEntity()
		let videoEntity = createVideoEntity()
		let subscriptionEntity = createSubscriptionEntity()
		let instanceEntity = createInstanceEntity()

		// Add relationships
		setupRelationships(
			channel: channelEntity,
			video: videoEntity,
			subscription: subscriptionEntity,
			instance: instanceEntity
		)

		// Add entities to model
		model.entities = [channelEntity, videoEntity, subscriptionEntity, instanceEntity]

		return model
	}

	// MARK: - Entity Creation

	private static func createChannelEntity() -> NSEntityDescription {
		let entity = NSEntityDescription()
		entity.name = "Channel"
		entity.managedObjectClassName = NSStringFromClass(ChannelManagedObject.self)

		// Attributes
		let id = NSAttributeDescription()
		id.name = "id"
		id.attributeType = .stringAttributeType
		id.isOptional = false

		let name = NSAttributeDescription()
		name.name = "name"
		name.attributeType = .stringAttributeType
		name.isOptional = false

		let displayName = NSAttributeDescription()
		displayName.name = "displayName"
		displayName.attributeType = .stringAttributeType
		displayName.isOptional = true

		let description = NSAttributeDescription()
		description.name = "channelDescription"
		description.attributeType = .stringAttributeType
		description.isOptional = true

		let avatarURL = NSAttributeDescription()
		avatarURL.name = "avatarURL"
		avatarURL.attributeType = .stringAttributeType
		avatarURL.isOptional = true

		let bannerURL = NSAttributeDescription()
		bannerURL.name = "bannerURL"
		bannerURL.attributeType = .stringAttributeType
		bannerURL.isOptional = true

		let followersCount = NSAttributeDescription()
		followersCount.name = "followersCount"
		followersCount.attributeType = .integer32AttributeType
		followersCount.defaultValue = 0

		let createdAt = NSAttributeDescription()
		createdAt.name = "createdAt"
		createdAt.attributeType = .dateAttributeType
		createdAt.isOptional = true

		let updatedAt = NSAttributeDescription()
		updatedAt.name = "updatedAt"
		updatedAt.attributeType = .dateAttributeType
		updatedAt.isOptional = true

		entity.properties = [
			id, name, displayName, description, avatarURL,
			bannerURL, followersCount, createdAt, updatedAt,
		]

		return entity
	}

	private static func createVideoEntity() -> NSEntityDescription {
		let entity = NSEntityDescription()
		entity.name = "Video"
		entity.managedObjectClassName = NSStringFromClass(VideoManagedObject.self)

		// Attributes
		let id = NSAttributeDescription()
		id.name = "id"
		id.attributeType = .stringAttributeType
		id.isOptional = false

		let uuid = NSAttributeDescription()
		uuid.name = "uuid"
		uuid.attributeType = .stringAttributeType
		uuid.isOptional = false

		let name = NSAttributeDescription()
		name.name = "name"
		name.attributeType = .stringAttributeType
		name.isOptional = false

		let videoDescription = NSAttributeDescription()
		videoDescription.name = "videoDescription"
		videoDescription.attributeType = .stringAttributeType
		videoDescription.isOptional = true

		let thumbnailPath = NSAttributeDescription()
		thumbnailPath.name = "thumbnailPath"
		thumbnailPath.attributeType = .stringAttributeType
		thumbnailPath.isOptional = true

		let duration = NSAttributeDescription()
		duration.name = "duration"
		duration.attributeType = .integer32AttributeType
		duration.defaultValue = 0

		let views = NSAttributeDescription()
		views.name = "views"
		views.attributeType = .integer32AttributeType
		views.defaultValue = 0

		let likes = NSAttributeDescription()
		likes.name = "likes"
		likes.attributeType = .integer32AttributeType
		likes.defaultValue = 0

		let dislikes = NSAttributeDescription()
		dislikes.name = "dislikes"
		dislikes.attributeType = .integer32AttributeType
		dislikes.defaultValue = 0

		let publishedAt = NSAttributeDescription()
		publishedAt.name = "publishedAt"
		publishedAt.attributeType = .dateAttributeType
		publishedAt.isOptional = true

		let createdAt = NSAttributeDescription()
		createdAt.name = "createdAt"
		createdAt.attributeType = .dateAttributeType
		createdAt.isOptional = true

		let updatedAt = NSAttributeDescription()
		updatedAt.name = "updatedAt"
		updatedAt.attributeType = .dateAttributeType
		updatedAt.isOptional = true

		let isLocal = NSAttributeDescription()
		isLocal.name = "isLocal"
		isLocal.attributeType = .booleanAttributeType
		isLocal.defaultValue = false

		let state = NSAttributeDescription()
		state.name = "state"
		state.attributeType = .integer16AttributeType
		state.defaultValue = 0

		entity.properties = [
			id, uuid, name, videoDescription, thumbnailPath, duration,
			views, likes, dislikes, publishedAt, createdAt, updatedAt,
			isLocal, state,
		]

		return entity
	}

	private static func createSubscriptionEntity() -> NSEntityDescription {
		let entity = NSEntityDescription()
		entity.name = "Subscription"
		entity.managedObjectClassName = NSStringFromClass(SubscriptionManagedObject.self)

		// Attributes
		let id = NSAttributeDescription()
		id.name = "id"
		id.attributeType = .UUIDAttributeType
		id.isOptional = false

		let channelId = NSAttributeDescription()
		channelId.name = "channelId"
		channelId.attributeType = .stringAttributeType
		channelId.isOptional = false

		let subscribedAt = NSAttributeDescription()
		subscribedAt.name = "subscribedAt"
		subscribedAt.attributeType = .dateAttributeType
		subscribedAt.isOptional = false

		let isEnabled = NSAttributeDescription()
		isEnabled.name = "isEnabled"
		isEnabled.attributeType = .booleanAttributeType
		isEnabled.defaultValue = true

		let lastCheckedAt = NSAttributeDescription()
		lastCheckedAt.name = "lastCheckedAt"
		lastCheckedAt.attributeType = .dateAttributeType
		lastCheckedAt.isOptional = true

		entity.properties = [id, channelId, subscribedAt, isEnabled, lastCheckedAt]

		return entity
	}

	private static func createInstanceEntity() -> NSEntityDescription {
		let entity = NSEntityDescription()
		entity.name = "Instance"
		entity.managedObjectClassName = NSStringFromClass(InstanceManagedObject.self)

		// Attributes
		let id = NSAttributeDescription()
		id.name = "id"
		id.attributeType = .UUIDAttributeType
		id.isOptional = false

		let host = NSAttributeDescription()
		host.name = "host"
		host.attributeType = .stringAttributeType
		host.isOptional = false

		let name = NSAttributeDescription()
		name.name = "name"
		name.attributeType = .stringAttributeType
		name.isOptional = true

		let shortDescription = NSAttributeDescription()
		shortDescription.name = "shortDescription"
		shortDescription.attributeType = .stringAttributeType
		shortDescription.isOptional = true

		let version = NSAttributeDescription()
		version.name = "version"
		version.attributeType = .stringAttributeType
		version.isOptional = true

		let isDefault = NSAttributeDescription()
		isDefault.name = "isDefault"
		isDefault.attributeType = .booleanAttributeType
		isDefault.defaultValue = false

		let addedAt = NSAttributeDescription()
		addedAt.name = "addedAt"
		addedAt.attributeType = .dateAttributeType
		addedAt.isOptional = false

		entity.properties = [id, host, name, shortDescription, version, isDefault, addedAt]

		return entity
	}

	// MARK: - Relationships

	private static func setupRelationships(
		channel: NSEntityDescription,
		video: NSEntityDescription,
		subscription: NSEntityDescription,
		instance: NSEntityDescription
	) {
		// Channel -> Videos (One-to-Many)
		let channelVideos = NSRelationshipDescription()
		channelVideos.name = "videos"
		channelVideos.destinationEntity = video
		channelVideos.minCount = 0
		channelVideos.maxCount = 0  // Unlimited
		channelVideos.deleteRule = .cascadeDeleteRule

		// Video -> Channel (Many-to-One)
		let videoChannel = NSRelationshipDescription()
		videoChannel.name = "channel"
		videoChannel.destinationEntity = channel
		videoChannel.minCount = 1
		videoChannel.maxCount = 1
		videoChannel.deleteRule = .nullifyDeleteRule

		// Set inverse relationships
		channelVideos.inverseRelationship = videoChannel
		videoChannel.inverseRelationship = channelVideos

		// Subscription -> Channel (Many-to-One)
		let subscriptionChannel = NSRelationshipDescription()
		subscriptionChannel.name = "channel"
		subscriptionChannel.destinationEntity = channel
		subscriptionChannel.minCount = 1
		subscriptionChannel.maxCount = 1
		subscriptionChannel.deleteRule = .nullifyDeleteRule

		// Channel -> Subscriptions (One-to-Many)
		let channelSubscriptions = NSRelationshipDescription()
		channelSubscriptions.name = "subscriptions"
		channelSubscriptions.destinationEntity = subscription
		channelSubscriptions.minCount = 0
		channelSubscriptions.maxCount = 0
		channelSubscriptions.deleteRule = .cascadeDeleteRule

		// Set inverse relationships
		subscriptionChannel.inverseRelationship = channelSubscriptions
		channelSubscriptions.inverseRelationship = subscriptionChannel

		// Channel -> Instance (Many-to-One)
		let channelInstance = NSRelationshipDescription()
		channelInstance.name = "instance"
		channelInstance.destinationEntity = instance
		channelInstance.minCount = 1
		channelInstance.maxCount = 1
		channelInstance.deleteRule = .nullifyDeleteRule

		// Instance -> Channels (One-to-Many)
		let instanceChannels = NSRelationshipDescription()
		instanceChannels.name = "channels"
		instanceChannels.destinationEntity = channel
		instanceChannels.minCount = 0
		instanceChannels.maxCount = 0
		instanceChannels.deleteRule = .cascadeDeleteRule

		// Set inverse relationships
		channelInstance.inverseRelationship = instanceChannels
		instanceChannels.inverseRelationship = channelInstance

		// Add relationships to entities
		channel.properties.append(contentsOf: [
			channelVideos, channelSubscriptions, channelInstance,
		])
		video.properties.append(videoChannel)
		subscription.properties.append(subscriptionChannel)
		instance.properties.append(instanceChannels)
	}
}

// MARK: - Managed Object Classes

@objc(ChannelManagedObject)
public class ChannelManagedObject: NSManagedObject {
	@NSManaged public var id: String
	@NSManaged public var name: String
	@NSManaged public var displayName: String?
	@NSManaged public var channelDescription: String?
	@NSManaged public var avatarURL: String?
	@NSManaged public var bannerURL: String?
	@NSManaged public var followersCount: Int32
	@NSManaged public var createdAt: Date?
	@NSManaged public var updatedAt: Date?
	@NSManaged public var videos: NSSet?
	@NSManaged public var subscriptions: NSSet?
	@NSManaged public var instance: InstanceManagedObject
}

@objc(VideoManagedObject)
public class VideoManagedObject: NSManagedObject {
	@NSManaged public var id: String
	@NSManaged public var uuid: String
	@NSManaged public var name: String
	@NSManaged public var videoDescription: String?
	@NSManaged public var thumbnailPath: String?
	@NSManaged public var duration: Int32
	@NSManaged public var views: Int32
	@NSManaged public var likes: Int32
	@NSManaged public var dislikes: Int32
	@NSManaged public var publishedAt: Date?
	@NSManaged public var createdAt: Date?
	@NSManaged public var updatedAt: Date?
	@NSManaged public var isLocal: Bool
	@NSManaged public var state: Int16
	@NSManaged public var channel: ChannelManagedObject
}

@objc(SubscriptionManagedObject)
public class SubscriptionManagedObject: NSManagedObject {
	@NSManaged public var id: UUID
	@NSManaged public var channelId: String
	@NSManaged public var subscribedAt: Date
	@NSManaged public var isEnabled: Bool
	@NSManaged public var lastCheckedAt: Date?
	@NSManaged public var channel: ChannelManagedObject
}

@objc(InstanceManagedObject)
public class InstanceManagedObject: NSManagedObject {
	@NSManaged public var id: UUID
	@NSManaged public var host: String
	@NSManaged public var name: String?
	@NSManaged public var shortDescription: String?
	@NSManaged public var version: String?
	@NSManaged public var isDefault: Bool
	@NSManaged public var addedAt: Date
	@NSManaged public var channels: NSSet?
}
