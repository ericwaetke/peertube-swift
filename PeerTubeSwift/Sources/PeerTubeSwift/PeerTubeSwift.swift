//
//  PeerTubeSwift.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

@_exported import CoreData
import Foundation
/// Main entry point for PeerTubeSwift library
@_exported import Foundation

// MARK: - Core Components
@_exported import class PeerTubeSwift.APIClient
@_exported import struct PeerTubeSwift.APIClientConfig
@_exported import struct PeerTubeSwift.Account
@_exported import struct PeerTubeSwift.AccountSummary
@_exported import struct PeerTubeSwift.Actor
@_exported import struct PeerTubeSwift.ActorImage
@_exported import struct PeerTubeSwift.ActorSummary
// MARK: - Networking Types
@_exported import struct PeerTubeSwift.AuthToken
@_exported import struct PeerTubeSwift.BasicInstanceInfo
@_exported import struct PeerTubeSwift.ChannelListParameters
@_exported import struct PeerTubeSwift.ChannelListResponse
@_exported import struct PeerTubeSwift.ChannelSearchParameters
@_exported import class PeerTubeSwift.ChannelService
@_exported import enum PeerTubeSwift.ChannelSort
@_exported import struct PeerTubeSwift.ChannelStats
@_exported import struct PeerTubeSwift.ChannelSubscription
@_exported import class PeerTubeSwift.CoreDataStack
@_exported import struct PeerTubeSwift.DependencyContainer
// MARK: - Video Player Components
@_exported import struct PeerTubeSwift.FullscreenVideoPlayerView
@_exported import struct PeerTubeSwift.HomepageContent
@_exported import struct PeerTubeSwift.InlineVideoPlayerView
@_exported import struct PeerTubeSwift.Instance
@_exported import struct PeerTubeSwift.InstanceAbout
@_exported import struct PeerTubeSwift.InstanceConfig
@_exported import class PeerTubeSwift.InstanceService
@_exported import struct PeerTubeSwift.InstanceStats
@_exported import struct PeerTubeSwift.InstanceSummary
@_exported import enum PeerTubeSwift.NSFWFilter
@_exported import class PeerTubeSwift.NetworkingFoundation
@_exported import enum PeerTubeSwift.PeerTubeAPIError
@_exported import struct PeerTubeSwift.PeerTubeErrorResponse
// MARK: - Services
@_exported import class PeerTubeSwift.PeerTubeServices
@_exported import struct PeerTubeSwift.PlaybackSpeedOption
@_exported import struct PeerTubeSwift.QuickSearchResults
@_exported import enum PeerTubeSwift.SearchTarget
@_exported import enum PeerTubeSwift.SubscriptionError
// MARK: - Storage Types
@_exported import class PeerTubeSwift.SubscriptionRepository
// MARK: - Models
@_exported import struct PeerTubeSwift.Video
@_exported import struct PeerTubeSwift.VideoChannel
@_exported import struct PeerTubeSwift.VideoChannelSummary
@_exported import struct PeerTubeSwift.VideoDetails
@_exported import struct PeerTubeSwift.VideoFile
// MARK: - Service Parameter Types
@_exported import struct PeerTubeSwift.VideoListParameters
// MARK: - Service Response Types
@_exported import struct PeerTubeSwift.VideoListResponse
@_exported import class PeerTubeSwift.VideoPlayerController
@_exported import enum PeerTubeSwift.VideoPlayerError
@_exported import enum PeerTubeSwift.VideoPlayerUtils
@_exported import struct PeerTubeSwift.VideoPlayerView
// MARK: - Enums
@_exported import enum PeerTubeSwift.VideoPrivacy
@_exported import struct PeerTubeSwift.VideoQualityOption
@_exported import struct PeerTubeSwift.VideoResolution
@_exported import struct PeerTubeSwift.VideoSearchParameters
@_exported import class PeerTubeSwift.VideoService
@_exported import enum PeerTubeSwift.VideoSort
@_exported import enum PeerTubeSwift.VideoState
@_exported import struct PeerTubeSwift.VideoStreamingPlaylist
@_exported import struct PeerTubeSwift.VideoSummary

// MARK: - Public API
public struct PeerTubeSwift {
	/// Current version of the library
	public static let version = "0.1.0"

	/// Shared dependency container instance
	public static let container = DependencyContainer.shared

	private init() {}
}
