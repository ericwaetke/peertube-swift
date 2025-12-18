//
//  PeerTubeSwift.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import CoreData
import Foundation

/// Main entry point for PeerTubeSwift library
public struct PeerTubeSwift {
	/// Current version of the library
	public static let version = "0.1.0"

	/// Shared dependency container instance
	public static let container = DependencyContainer.shared

	private init() {}
}
