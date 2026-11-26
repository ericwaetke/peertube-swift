//
//  OnboardingTestSupport.swift
//  PeerTubeSwiftTests
//

import Foundation
import Testing
import TubeSDK

@testable import PeerTubeSwift

// MARK: - Constants and fixtures

/// Matches the default shared client's host, so a leaked `@Shared` value still
/// points at the same community in tests.
let onboardingTestHost = "peertube.wtf"
let instancesPath = "/api/v1/instances"
let serverConfigPath = "/api/v1/config"
let oauthClientsPath = "/api/v1/oauth-clients/local"
let userTokenPath = "/api/v1/users/token"
let mePath = "/api/v1/users/me"

let onboardingAvatarURL = "https://peertube.wtf/avatars/alice.png"

func stubbedToken() -> OAuthToken {
  OAuthToken(
    accessToken: "access-token",
    refreshToken: "refresh-token",
    tokenType: "Bearer",
    expiresIn: 3600
  )
}

func onboardingClient() -> TubeSDKClient {
  try! TubeSDKClient(scheme: "https", host: onboardingTestHost)
}

func stubbedSession(avatarUrl: String? = onboardingAvatarURL) -> UserSession {
  UserSession(
    username: "alice",
    host: onboardingTestHost,
    token: stubbedToken(),
    avatarUrl: avatarUrl
  )
}

/// `ServerConfig` has no public memberwise initializer, so decode the smallest
/// payload that satisfies its required fields (`instance` and `serverVersion`).
func stubbedServerConfig(name: String = "Test Community") -> ServerConfig {
  try! JSONDecoder().decode(
    ServerConfig.self, from: Data(stubbedServerConfigJSON(name: name).utf8))
}

func stubbedServerConfigJSON(name: String = "Test Community") -> String {
  """
  {"instance":{"name":"\(name)"},"serverVersion":"7.0.0"}
  """
}

// MARK: - Deterministic HTTP stubbing

/// The SDK builds its own requests with `URLSession.shared`, so a globally
/// registered `URLProtocol` is the reliable seam: no per-test dependency
/// overrides can be lost when tests run in parallel.
final class OnboardingStubURLProtocol: URLProtocol {
  private static let paths: Set<String> = [
    oauthClientsPath, userTokenPath, mePath, serverConfigPath, instancesPath,
  ]

  private static let responses: [String: (status: Int, body: String)] = [
    oauthClientsPath: (200, #"{"client_id":"client-id","client_secret":"client-secret"}"#),
    userTokenPath: (
      200,
      #"{"access_token":"access-token","refresh_token":"refresh-token","token_type":"Bearer","expires_in":3600}"#
    ),
    mePath: (200, #"{"account":{"avatars":[{"fileUrl":"\#(onboardingAvatarURL)"}]}}"#),
    serverConfigPath: (200, stubbedServerConfigJSON()),
    instancesPath: (
      200,
      """
      {"total":2,"data":[{"id":1,"host":"peertube.wtf"},{"id":2,"host":"other.example"}]}
      """
    ),
  ]

  override class func canInit(with request: URLRequest) -> Bool {
    guard let path = request.url?.path else { return false }
    return paths.contains(path)
  }

  override class func canonicalRequest(for request: URLRequest) -> URLRequest {
    request
  }

  override func startLoading() {
    guard let url = request.url, let stub = Self.responses[url.path] else {
      client?.urlProtocol(self, didFailWithError: URLError(.badServerResponse))
      return
    }
    let response = HTTPURLResponse(
      url: url, statusCode: stub.status, httpVersion: nil, headerFields: nil
    )!
    client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
    client?.urlProtocol(self, didLoad: Data(stub.body.utf8))
    client?.urlProtocolDidFinishLoading(self)
  }

  override func stopLoading() {}
}

/// Lazy, thread-safe one-time registration.
private let stubProtocolRegistration: Void = {
  URLProtocol.registerClass(OnboardingStubURLProtocol.self)
}()

func installOnboardingStubProtocol() {
  _ = stubProtocolRegistration
}
