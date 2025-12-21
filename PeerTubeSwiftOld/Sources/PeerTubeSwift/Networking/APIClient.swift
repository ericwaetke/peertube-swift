//
//  APIClient.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// Authentication token for PeerTube API
public struct AuthToken: Codable, Sendable {
    public let accessToken: String
    public let tokenType: String
    public let expiresIn: Int
    public let refreshToken: String?
    public let scope: String?

    public init(
        accessToken: String,
        tokenType: String = "Bearer",
        expiresIn: Int,
        refreshToken: String? = nil,
        scope: String? = nil
    ) {
        self.accessToken = accessToken
        self.tokenType = tokenType
        self.expiresIn = expiresIn
        self.refreshToken = refreshToken
        self.scope = scope
    }
}

/// API Client configuration
public struct APIClientConfig: Sendable {
    public let instanceURL: URL
    public let rateLimitingEnabled: Bool
    public let requestsPerInterval: Int
    public let intervalDuration: TimeInterval
    public let timeout: TimeInterval

    public init(
        instanceURL: URL,
        rateLimitingEnabled: Bool = true,
        requestsPerInterval: Int = 50,
        intervalDuration: TimeInterval = 10.0,
        timeout: TimeInterval = 30.0
    ) {
        self.instanceURL = instanceURL
        self.rateLimitingEnabled = rateLimitingEnabled
        self.requestsPerInterval = requestsPerInterval
        self.intervalDuration = intervalDuration
        self.timeout = timeout
    }
}

/// Rate limiter actor for managing API request throttling
actor RateLimiter {
    private let maxRequests: Int
    private let timeInterval: TimeInterval
    private var requestTimestamps: [Date] = []

    init(maxRequests: Int, timeInterval: TimeInterval) {
        self.maxRequests = maxRequests
        self.timeInterval = timeInterval
    }

    /// Check if a request can be made and record it if allowed
    func canMakeRequest() async -> Bool {
        let now = Date()
        let cutoff = now.addingTimeInterval(-timeInterval)

        // Remove old timestamps
        requestTimestamps.removeAll { $0 < cutoff }

        // Check if we're under the limit
        guard requestTimestamps.count < maxRequests else {
            return false
        }

        // Record this request
        requestTimestamps.append(now)
        return true
    }

    /// Get time until next request is allowed
    func timeUntilNextRequest() async -> TimeInterval {
        guard requestTimestamps.count >= maxRequests else {
            return 0
        }

        let oldestRequest = requestTimestamps.first!
        let nextAvailable = oldestRequest.addingTimeInterval(timeInterval)
        return max(0, nextAvailable.timeIntervalSinceNow)
    }
}

/// Authentication manager actor for thread-safe token handling
actor AuthenticationManager {
    private var currentToken: AuthToken?

    func setToken(_ token: AuthToken?) {
        currentToken = token
    }

    func getToken() -> AuthToken? {
        return currentToken
    }

    func hasValidToken() -> Bool {
        // TODO: Implement token expiry checking
        return currentToken != nil
    }

    func clearToken() {
        currentToken = nil
    }
}

/// Main PeerTube API Client with Swift 6 concurrency support
public final class APIClient: Sendable {
    // MARK: - Properties

    private let config: APIClientConfig
    private let networking: NetworkingFoundation
    private let rateLimiter: RateLimiter?
    private let authManager: AuthenticationManager

    // MARK: - Computed Properties

    /// Base API URL for this instance
    public var apiBaseURL: URL {
        config.instanceURL.appendingPathComponent("/api/v1")
    }

    // MARK: - Initialization

    public init(
        config: APIClientConfig,
        networking: NetworkingFoundation = NetworkingFoundation.shared
    ) {
        self.config = config
        self.networking = networking
        rateLimiter =
            config.rateLimitingEnabled
                ? RateLimiter(
                    maxRequests: config.requestsPerInterval,
                    timeInterval: config.intervalDuration
                ) : nil
        authManager = AuthenticationManager()
    }

    public convenience init(instanceURL: URL) {
        let config = APIClientConfig(instanceURL: instanceURL)
        self.init(config: config)
    }

    // MARK: - Authentication

    /// Set authentication token
    public func setAuthToken(_ token: AuthToken?) async {
        await authManager.setToken(token)
    }

    /// Get current authentication token
    public func getAuthToken() async -> AuthToken? {
        return await authManager.getToken()
    }

    /// Check if client has valid authentication
    public func isAuthenticated() async -> Bool {
        return await authManager.hasValidToken()
    }

    /// Clear authentication token
    public func clearAuthentication() async {
        await authManager.clearToken()
    }

    // MARK: - Request Methods

    /// Perform a GET request
    public func get<T: Codable & Sendable>(
        path: String,
        queryParameters: [String: String]? = nil,
        authenticated: Bool = false
    ) async throws -> T {
        let url = try buildURL(path: path, queryParameters: queryParameters)
        return try await performRequest(
            url: url,
            method: .GET,
            authenticated: authenticated
        )
    }

    /// Perform a POST request with JSON body
    public func post<Request: Codable & Sendable, Response: Codable & Sendable>(
        path: String,
        body: Request,
        authenticated: Bool = true
    ) async throws -> Response {
        let url = try buildURL(path: path)
        return try await performRequest(
            url: url,
            method: .POST,
            body: body,
            authenticated: authenticated
        )
    }

    /// Perform a POST request without body
    public func post<T: Codable & Sendable>(
        path: String,
        authenticated: Bool = true
    ) async throws -> T {
        let url = try buildURL(path: path)
        return try await performRequest(
            url: url,
            method: .POST,
            authenticated: authenticated
        )
    }

    /// Perform a PUT request
    public func put<Request: Codable & Sendable, Response: Codable & Sendable>(
        path: String,
        body: Request,
        authenticated: Bool = true
    ) async throws -> Response {
        let url = try buildURL(path: path)
        return try await performRequest(
            url: url,
            method: .PUT,
            body: body,
            authenticated: authenticated
        )
    }

    /// Perform a DELETE request
    public func delete(
        path: String,
        authenticated: Bool = true
    ) async throws {
        let url = try buildURL(path: path)
        let _: EmptyResponse = try await performRequest(
            url: url,
            method: .DELETE,
            authenticated: authenticated
        )
    }

    /// Perform a request that returns raw data
    public func getData(
        path: String,
        queryParameters: [String: String]? = nil,
        authenticated: Bool = false
    ) async throws -> Data {
        let url = try buildURL(path: path, queryParameters: queryParameters)
        return try await performRawRequest(
            url: url,
            method: .GET,
            authenticated: authenticated
        )
    }

    // MARK: - Private Methods

    private func buildURL(
        path: String,
        queryParameters: [String: String]? = nil
    ) throws -> URL {
        let url = apiBaseURL.appendingPathComponent(path)

        guard let queryParameters = queryParameters, !queryParameters.isEmpty else {
            return url
        }

        let queryItems = queryParameters.map { key, value in
            URLQueryItem(name: key, value: value)
        }

        guard let urlWithQuery = url.appending(queryItems: queryItems) else {
            throw NetworkError.invalidURL
        }

        return urlWithQuery
    }

    private func performRequest<T: Codable & Sendable>(
        url: URL,
        method: HTTPMethod,
        authenticated: Bool = false
    ) async throws -> T {
        try await enforceRateLimit()

        let headers = try await buildHeaders(authenticated: authenticated)

        return try await networking.request(
            url: url,
            method: method,
            headers: headers
        )
    }

    private func performRequest<Request: Codable & Sendable, Response: Codable & Sendable>(
        url: URL,
        method: HTTPMethod,
        body: Request,
        authenticated: Bool = false
    ) async throws -> Response {
        try await enforceRateLimit()

        let headers = try await buildHeaders(
            authenticated: authenticated, contentType: "application/json"
        )

        return try await networking.request(
            url: url,
            method: method,
            headers: headers,
            requestBody: body
        )
    }

    private func performRawRequest(
        url: URL,
        method: HTTPMethod,
        authenticated: Bool = false
    ) async throws -> Data {
        try await enforceRateLimit()

        let headers = try await buildHeaders(authenticated: authenticated)

        return try await networking.requestData(
            url: url,
            method: method,
            headers: headers
        )
    }

    private func buildHeaders(
        authenticated: Bool,
        contentType: String? = nil
    ) async throws -> [String: String] {
        var headers: [String: String] = [:]

        // Add content type if specified
        if let contentType = contentType {
            headers["Content-Type"] = contentType
        }

        // Add authentication if required
        if authenticated {
            guard let token = await authManager.getToken() else {
                throw NetworkError.httpError(statusCode: 401, data: nil)
            }
            headers["Authorization"] = "\(token.tokenType) \(token.accessToken)"
        }

        return headers
    }

    private func enforceRateLimit() async throws {
        guard let rateLimiter = rateLimiter else { return }

        while !(await rateLimiter.canMakeRequest()) {
            let waitTime = await rateLimiter.timeUntilNextRequest()
            if waitTime > 0 {
                try await Task.sleep(nanoseconds: UInt64(waitTime * 1_000_000_000))
            }
        }
    }
}

// MARK: - Helper Types

/// Empty response for requests that don't return data
private struct EmptyResponse: Codable, Sendable {}

// MARK: - Convenience Extensions

public extension APIClient {
    /// Create APIClient for a PeerTube instance URL string
    convenience init?(instanceURLString: String) {
        guard let url = URL(string: instanceURLString) else {
            return nil
        }
        self.init(instanceURL: url)
    }

    /// Get the instance hostname
    var instanceHost: String {
        config.instanceURL.host ?? ""
    }

    /// Check if this client is for a specific instance
    func isForInstance(_ url: URL) -> Bool {
        return config.instanceURL.host == url.host && config.instanceURL.scheme == url.scheme
    }
}

// MARK: - Error Handling Extensions

extension APIClient {
    /// Handle common API errors with more specific error types
    private func handleAPIError(_ error: Error) throws -> Never {
        if let networkError = error as? NetworkError {
            switch networkError {
            case let .httpError(statusCode, data):
                // Try to parse PeerTube-specific error response
                if let data = data,
                   let errorResponse = try? networking.jsonDecoder.decode(
                       PeerTubeErrorResponse.self, from: data
                   )
                {
                    throw PeerTubeAPIError.serverError(statusCode: statusCode, error: errorResponse)
                } else {
                    throw PeerTubeAPIError.httpError(statusCode: statusCode)
                }
            case .networkUnavailable:
                throw PeerTubeAPIError.networkUnavailable
            case .timeout:
                throw PeerTubeAPIError.timeout
            default:
                throw PeerTubeAPIError.networkError(networkError)
            }
        }
        throw error
    }
}

// MARK: - PeerTube-Specific Error Types

/// PeerTube API specific errors
public enum PeerTubeAPIError: Error, LocalizedError, Sendable {
    case httpError(statusCode: Int)
    case serverError(statusCode: Int, error: PeerTubeErrorResponse)
    case networkUnavailable
    case timeout
    case authenticationRequired
    case rateLimitExceeded
    case networkError(NetworkError)

    public var errorDescription: String? {
        switch self {
        case let .httpError(statusCode):
            return "HTTP error: \(statusCode)"
        case let .serverError(statusCode, error):
            return "Server error (\(statusCode)): \(error.error)"
        case .networkUnavailable:
            return "Network unavailable"
        case .timeout:
            return "Request timeout"
        case .authenticationRequired:
            return "Authentication required"
        case .rateLimitExceeded:
            return "Rate limit exceeded"
        case let .networkError(networkError):
            return "Network error: \(networkError.localizedDescription)"
        }
    }
}

/// PeerTube error response structure
public struct PeerTubeErrorResponse: Codable, Sendable {
    public let error: String
    public let code: String?
    public let details: String?

    public init(error: String, code: String? = nil, details: String? = nil) {
        self.error = error
        self.code = code
        self.details = details
    }
}
