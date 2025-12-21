//
//  PeerTubeModels+URL.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import Foundation


// MARK: - VideoDetails Extensions

//extension VideoDetails {
//	/// Computed thumbnail URL based on current app instance
//	var thumbnailURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			thumbnailPath != nil
//		else {
//			return nil
//		}
//		return VideoPlayerUtils.getThumbnailURL(from: self, instanceURL: instanceURL)
//	}
//
//	/// Computed preview URL based on current app instance
//	var previewURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			let previewPath = previewPath
//		else {
//			return nil
//		}
//		return instanceURL.appendingPathComponent(previewPath)
//	}
//
//	/// Computed embed URL based on current app instance
//	var embedURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			let embedPath = embedPath
//		else {
//			return nil
//		}
//		return instanceURL.appendingPathComponent(embedPath)
//	}
//}
//
//// MARK: - Video Extensions
//
//extension Video {
//	/// Computed thumbnail URL based on current app instance
//	var thumbnailURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			let thumbnailPath = thumbnailPath
//		else {
//			return nil
//		}
//		return instanceURL.appendingPathComponent(thumbnailPath)
//	}
//
//	/// Computed preview URL based on current app instance
//	var previewURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			let previewPath = previewPath
//		else {
//			return nil
//		}
//		return instanceURL.appendingPathComponent(previewPath)
//	}
//}
//
//// MARK: - VideoSummary Extensions
//
//extension VideoSummary {
//	/// Computed thumbnail URL based on current app instance
//	var thumbnailURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			let thumbnailPath = thumbnailPath
//		else {
//			return nil
//		}
//		return instanceURL.appendingPathComponent(thumbnailPath)
//	}
//}
//
//// MARK: - VideoChannel Extensions
//
//extension VideoChannel {
//	/// Computed avatar URL based on current app instance and primary avatar
//	var avatarURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			let avatar = primaryAvatar,
//			let avatarPath = avatar.url
//		else {
//			return nil
//		}
//		return instanceURL.appendingPathComponent(avatarPath)
//	}
//
//	/// Computed banner URL based on current app instance and primary banner
//	var bannerURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			let banner = primaryBanner,
//			let bannerPath = banner.url
//		else {
//			return nil
//		}
//		return instanceURL.appendingPathComponent(bannerPath)
//	}
//}
//
//// MARK: - VideoChannelSummary Extensions
//
//extension VideoChannelSummary {
//	/// Computed avatar URL based on current app instance and avatar
//	var avatarURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			let avatar = avatar,
//			let avatarPath = avatar.url
//		else {
//			return nil
//		}
//		return instanceURL.appendingPathComponent(avatarPath)
//	}
//}
//
//// MARK: - Account Extensions
//
//extension Account {
//	/// Computed avatar URL based on current app instance and primary avatar
//	var avatarURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			let avatar = primaryAvatar,
//			let avatarPath = avatar.url
//		else {
//			return nil
//		}
//		return instanceURL.appendingPathComponent(avatarPath)
//	}
//}
//
//// MARK: - AccountSummary Extensions
//
//extension AccountSummary {
//	/// Computed avatar URL based on current app instance and avatar
//	var avatarURL: URL? {
//		guard let appState = AppStateProvider.shared.appState,
//			let instanceURL = appState.currentInstance?.baseURL,
//			let avatar = avatar,
//			let avatarPath = avatar.url
//		else {
//			return nil
//		}
//		return instanceURL.appendingPathComponent(avatarPath)
//	}
//}

// MARK: - AppState Provider

/// Singleton to provide access to AppState from extensions
class AppStateProvider {
	static let shared = AppStateProvider()
	weak var appState: AppState?

	private init() {}

	func setAppState(_ appState: AppState) {
		self.appState = appState
	}
}
