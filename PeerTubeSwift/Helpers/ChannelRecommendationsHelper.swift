//
//  ChannelRecommendations.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 27.07.26.
//

import Dependencies
import Foundation
import PeerSeekSDK
import TubeSDK

struct Response: Codable {
  let status: String
  let data: ResponseData
}
struct ResponseData: Codable {
  let channels: [RecommendedChannel]
}
public struct RecommendedChannel: Codable, Hashable, Sendable {
  let name: String
  let channel_id: String
  let instance: String
  let primary_language: String
  /// Avatar URL from the channel's own PeerTube instance. Resolved lazily when
  /// a row appears; nil means unresolved — `AvatarView` then shows initials.
  var avatarUrl: String? = nil
  /// Category of the video that surfaced this channel, from PeerSeek.
  var primaryCategory: String? = nil
}

extension RecommendedChannel: Identifiable, Equatable {
  public var id: String {
    "\(channel_id)@\(instance)"
  }
}

/// Avatar URL lookups are cached separately from the image bytes cached by
/// `AvatarView`. The double optional distinguishes "never tried" from
/// "tried and failed" so a dead instance isn't retried on every scroll.
private actor AvatarURLCache {
  private var values: [String: String?] = [:]

  func value(for key: String) -> String?? { values[key] }
  func setValue(_ value: String?, for key: String) { values[key] = value }
}

private let avatarURLCache = AvatarURLCache()

/// Network work for channel recommendations lives behind a dependency so the
/// reducers using it can be tested without hitting PeerSeek or PeerTube.
struct ChannelRecommendationsClient {
  var getChannelPicks: @Sendable () async throws -> [RecommendedChannel]
  var getChannelRecommendations:
    @Sendable (Set<PeerSeekSDK.Category>) async throws -> Set<RecommendedChannel>
  var loadAvatar: @Sendable (_ handle: String, _ instance: String) async -> String?
}

extension ChannelRecommendationsClient: DependencyKey {
  static let liveValue = Self(
    getChannelPicks: { try await fetchChannelPicks() },
    getChannelRecommendations: { categories in
      try await fetchChannelRecommendations(categories: categories)
    },
    loadAvatar: { handle, instance in
      let key = "\(handle)@\(instance)"
      if let cached = await avatarURLCache.value(for: key) { return cached }

      guard let client = try? TubeSDKClient(scheme: "https", host: instance),
        let channel = try? await client.getChannel(channelIdentifier: key)
      else {
        await avatarURLCache.setValue(nil, for: key)
        return nil
      }

      let url =
        channel.avatars?.first?.fileUrl
        ?? channel.avatars?.first?.path.flatMap {
          try? client.getImageUrl(path: $0).absoluteString  // PeerTube < 7.1
        }
      await avatarURLCache.setValue(url, for: key)
      return url
    }
  )

  /// Tests that exercise features using this dependency get empty results
  /// instead of a test failure for accessing an unimplemented dependency.
  static let testValue = Self(
    getChannelPicks: { [] },
    getChannelRecommendations: { _ in [] },
    loadAvatar: { _, _ in nil }
  )
}

extension DependencyValues {
  var channelRecommendations: ChannelRecommendationsClient {
    get { self[ChannelRecommendationsClient.self] }
    set { self[ChannelRecommendationsClient.self] = newValue }
  }
}

public func getChannelPicks() async throws -> [RecommendedChannel] {
  try await fetchChannelPicks()
}

public func getChannelRecommendations(
  categories: Set<PeerSeekSDK.Category>
) async throws -> Set<RecommendedChannel> {
  try await fetchChannelRecommendations(categories: categories)
}

private func fetchChannelPicks() async throws -> [RecommendedChannel] {
  print("getting channel picks")
  let url = URL(string: "https://river-website.test/channel_recommendations")

  guard let url = url else {
    throw URLError(.badURL)
  }

  let (data, response) = try await URLSession.shared.data(from: url)

  guard let httpResponse = response as? HTTPURLResponse,
    (200...299).contains(httpResponse.statusCode)
  else {
    throw URLError(.badServerResponse)
  }

  let responseData = try JSONDecoder().decode(Response.self, from: data)

  return responseData.data.channels
}

private func fetchChannelRecommendations(
  categories: Set<PeerSeekSDK.Category>
) async throws -> Set<RecommendedChannel> {
  print("Getting Channel Recommendations")

  let peerSeekClient = PeerSeekClient()

  // PeerSeek rate limits concurrent requests (HTTP 429), so search sequentially.
  // One failing category must not discard the successful ones either.
  var videos: [PeerSeekSDK.Video] = []
  for category in categories {
    do {
      let results = try await searchWithRetry(client: peerSeekClient, category: category)
      videos.append(contentsOf: results.sorted { $0.views > $1.views })
    } catch {
      print("Failed to load category \(category.rawValue): \(error)")
    }
  }

  // PeerSeek returns videos, not channels — keep one entry per channel.
  var channelsById: [String: RecommendedChannel] = [:]
  for video in videos {
    let channel = RecommendedChannel(
      name: video.channel,
      channel_id: video.channelHandle,
      instance: video.instance,
      primary_language: video.language?.rawValue ?? "",
      avatarUrl: nil,
      primaryCategory: video.category.rawValue
    )
    if channelsById[channel.id] == nil {
      channelsById[channel.id] = channel
    }
  }

  // Avatars are resolved lazily per visible row by ChannelPreviewFeature;
  // doing it here would block the whole list on every channel's instance.
  return Set(channelsById.values)
}

/// PeerSeek answers bursts of searches with HTTP 429. Back off and retry a few
/// times rather than dropping the whole category.
private func searchWithRetry(
  client: PeerSeekClient,
  category: PeerSeekSDK.Category
) async throws -> [PeerSeekSDK.Video] {
  let backoffs: [Duration] = [.seconds(1), .seconds(2), .seconds(4)]
  var attempt = 0

  while true {
    do {
      return try await client.search(q: "", category: category)
    } catch let error as SeekError {
      guard case .invalidResponse(let statusCode) = error,
        statusCode == 429,
        attempt < backoffs.count
      else { throw error }

      try await Task.sleep(for: backoffs[attempt])
      attempt += 1
    }
  }
}
