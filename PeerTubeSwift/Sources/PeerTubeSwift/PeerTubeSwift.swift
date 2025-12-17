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
@_exported import class PeerTubeSwift.CoreDataStack
@_exported import struct PeerTubeSwift.DependencyContainer
@_exported import class PeerTubeSwift.NetworkingFoundation

// MARK: - Models
@_exported import struct PeerTubeSwift.ActorImage
@_exported import struct PeerTubeSwift.Actor
@_exported import struct PeerTubeSwift.ActorSummary
@_exported import struct PeerTubeSwift.Account
@_exported import struct PeerTubeSwift.AccountSummary
@_exported import struct PeerTubeSwift.VideoChannel
@_exported import struct PeerTubeSwift.VideoChannelSummary
@_exported import struct PeerTubeSwift.Video
@_exported import struct PeerTubeSwift.VideoSummary
@_exported import struct PeerTubeSwift.VideoDetails
@_exported import struct PeerTubeSwift.VideoFile
@_exported import struct PeerTubeSwift.VideoResolution
@_exported import struct PeerTubeSwift.VideoStreamingPlaylist
@_exported import struct PeerTubeSwift.Instance
@_exported import struct PeerTubeSwift.InstanceSummary
@_exported import struct PeerTubeSwift.InstanceConfig

// MARK: - Enums
@_exported import enum PeerTubeSwift.VideoPrivacy
@_exported import enum PeerTubeSwift.VideoState

// MARK: - Public API
public struct PeerTubeSwift {
	/// Current version of the library
	public static let version = "0.1.0"

	/// Shared dependency container instance
	public static let container = DependencyContainer.shared

	private init() {}
}
