//
//  FeedCache.swift
//  PeerTubeSwift
//

import Foundation

// MARK: - Feed Cache Types

/// Cache entry storing videos and timestamp for TTL validation
struct FeedCacheEntry: Equatable {
  let videos: [VideoRow]
  let timestamp: Date
}

/// Feed filter types that can be cached
enum CachedFeedType: String, Equatable, Hashable {
  case exploreNewest
  case recommended
  case subscriptions
  case continueWatching

  init(from feedFilter: FeedFilter) {
    switch feedFilter {
    case .exploreNewest:
      self = .exploreNewest
    case .recommended:
      self = .recommended
    case .subscriptions:
      self = .subscriptions
    case .continueWatching:
      self = .continueWatching
    case .search, .category:
      self = .exploreNewest  // Don't cache search results

    }
  }
}

/// Global actor-based cache for feed videos
/// Lives outside of TCA State to survive navigation-based State recreation
actor FeedCacheActor {
  static let shared = FeedCacheActor()

  private var cache: [CachedFeedType: FeedCacheEntry] = [:]
  private let ttl: TimeInterval = 300  // 5 minutes

  private init() {}

  /// Get cached videos for a feed type if valid
  func get(_ feedType: FeedFilter) -> [VideoRow]? {
    let cachedType = CachedFeedType(from: feedType)
    guard let cached = cache[cachedType],
      Date().timeIntervalSince(cached.timestamp) < ttl
    else {
      return nil
    }
    return cached.videos
  }

  /// Store videos in cache with current timestamp
  func set(_ feedType: FeedFilter, videos: [VideoRow]) {
    let cachedType = CachedFeedType(from: feedType)
    cache[cachedType] = FeedCacheEntry(videos: videos, timestamp: Date())
  }

  /// Invalidate cache for a specific feed type
  func invalidate(_ feedType: FeedFilter) {
    let cachedType = CachedFeedType(from: feedType)
    cache.removeValue(forKey: cachedType)
  }

  /// Invalidate all cached feeds
  func invalidateAll() {
    cache.removeAll()
  }
}
