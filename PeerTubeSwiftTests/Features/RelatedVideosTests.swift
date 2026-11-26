//
//  RelatedVideosTests.swift
//  PeerTubeSwiftTests
//

import ComposableArchitecture
import Foundation
import PeerSeekSDK
import Testing
import TubeSDK

@testable import PeerTubeSwift

/// Returns HTTP 404 for every request so video loading terminates deterministically
/// without touching the network.
private final class NotFoundURLProtocol: URLProtocol {
  override class func canInit(with request: URLRequest) -> Bool {
    true
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    guard let url = request.url else {
      client?.urlProtocol(self, didFailWithError: URLError(.badURL))
      return
    }
    let response = HTTPURLResponse(
      url: url, statusCode: 404, httpVersion: nil, headerFields: nil
    )!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: Data())
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

/// Writes a mock client into the same in-memory storage used by `VideoDetailsFeature`.
private struct SharedClientWriter {
  @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
    scheme: "https", host: "peertube.wtf")

  func write(_ client: TubeSDKClient) {
    self.$client.withLock { $0 = client }
  }
}

private func mockClient(host: String) throws -> TubeSDKClient {
  let configuration = URLSessionConfiguration.ephemeral
  configuration.protocolClasses = [NotFoundURLProtocol.self]
  return try TubeSDKClient(
    scheme: "https", host: host, session: URLSession(configuration: configuration))
}

private func channelID(for recommendation: VideoRecommendation) -> String {
  "\(recommendation.channelHandle)@\(recommendation.instance)"
}

extension BaseSuite {
  @MainActor
  @Suite struct RelatedVideosTests {
    /// Cards built from recommendations keep the recommendation's identity: tapping each
    /// one forwards the right host, video ID, and channel ID through `VideoDetailsFeature`.
    @Test func loadVideosCreatesCardsThatForwardRecommendationIdentity() async {
      let recommendations = Array(VideoRecommendation.mockData.prefix(2))
      let store = TestStore(
        initialState: VideoDetailsFeature.State(
          host: "home.example", videoId: "current-video", channelId: nil)
      ) {
        VideoDetailsFeature()
      }
      // The cards themselves are only observed through the actions they emit.
      store.exhaustivity = .off

      await store.send(.relatedVideos(.loadVideos(recommendations)))

      for recommendation in recommendations {
        await store.send(
          .relatedVideos(.cards(.element(id: recommendation.id, action: .videoTapped))))
        await store.receive { action in
          guard
            case .relatedVideos(
              .cards(.element(id: recommendation.id, action: .delegate(.videoTapped)))) = action
          else { return false }
          return true
        }
        await store.receive { action in
          guard
            case .delegate(
              .navigateToVideo(
                host: recommendation.instance,
                videoId: recommendation.id,
                channelId: channelID(for: recommendation)
              )) = action
          else { return false }
          return true
        }
      }
    }

    /// Replacing an already-presented detail sheet must start loading the new video:
    /// the view's `.task` does not re-run when the sheet item stays presented.
    @Test func tapStartsLoadingReplacementVideo() async {
      let recommendation = VideoRecommendation.mockData[0]
      let host = recommendation.instance
      let videoId = recommendation.id
      let channelId = channelID(for: recommendation)
      let instance = Instance(host: host, scheme: "https")

      let storage = InMemoryStorage()
      // The initial state must be built inside the test store's dependency context so that
      // feature state and the shared client see the bootstrapped database and storage.
      let store = TestStore(
        initialState: {
          SharedClientWriter().write(try! mockClient(host: host))
          var state = AppFeature.State()
          state.videoDetail = VideoDetailsFeature.State(
            host: "old.example", videoId: "old-video", channelId: nil)
          return state
        }(),
        reducer: { AppFeature() }
      ) {
        try! $0.bootstrapDatabase()
        $0.defaultInMemoryStorage = storage
        $0.peertubeOrchestrator = PeertubeOrchestratorClient(
          syncInstanceInfo: { requestedHost, _ in
            Instance(host: requestedHost, scheme: "https")
          },
          cacheImageIfNeeded: { _, _ in }
        )
      }

      await store.send(
        .videoDetail(
          .presented(
            .delegate(.navigateToVideo(host: host, videoId: videoId, channelId: channelId))))
      ) {
        $0.videoDetail = VideoDetailsFeature.State(
          host: host, videoId: videoId, channelId: channelId)
      }
      await store.receive(\.videoDetail.presented.screenLoaded)
      await store.receive(\.videoDetail.presented.loadInstance)
      await store.receive(\.videoDetail.presented.instanceLoaded, instance) {
        $0.videoDetail?.channelPreview.instance = instance
      }
      await store.receive(\.videoDetail.presented.videoLoadFailed) {
        $0.videoDetail?.isNotFound = true
      }
    }
  }
}
