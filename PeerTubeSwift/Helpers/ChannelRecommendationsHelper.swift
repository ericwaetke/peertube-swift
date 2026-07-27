//
//  ChannelRecommendations.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 27.07.26.
//

import Foundation

struct Response: Codable {
  let status: String
  let data: ResponseData
}
struct ResponseData: Codable {
  let channels: [RecommendedChannel]
}
public struct RecommendedChannel: Codable {
  let name: String
  let channel_id: String
  let instance: String
  let primary_language: String
}

extension RecommendedChannel: Identifiable, Equatable {
  public var id: String {
    "\(channel_id)@\(instance)"
  }
}

public func getRecommendations() async throws -> [RecommendedChannel] {
  print("getting recommendations")
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
  print(responseData.data.channels)
  return responseData.data.channels
}
