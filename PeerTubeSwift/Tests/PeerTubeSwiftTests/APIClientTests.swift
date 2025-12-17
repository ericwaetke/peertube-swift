//
//  APIClientTests.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import XCTest

@testable import PeerTubeSwift

@MainActor
final class APIClientTests: XCTestCase {

	private var apiClient: APIClient!
	private let testInstanceURL = URL(string: "https://test.peertube.example")!

	override func setUpWithError() throws {
		try super.setUpWithError()

		let config = APIClientConfig(
			instanceURL: testInstanceURL,
			rateLimitingEnabled: false,  // Disable for testing
			timeout: 5.0
		)
		apiClient = APIClient(config: config)
	}

	override func tearDownWithError() throws {
		apiClient = nil
		try super.tearDownWithError()
	}

	// MARK: - Initialization Tests

	func testAPIClientInitialization() throws {
		XCTAssertEqual(apiClient.instanceHost, "test.peertube.example")
		XCTAssertEqual(apiClient.apiBaseURL.absoluteString, "https://test.peertube.example/api/v1")
	}

	func testAPIClientConvenienceInitializer() throws {
		let client = APIClient(instanceURL: testInstanceURL)
		XCTAssertEqual(client.instanceHost, "test.peertube.example")
	}

	func testAPIClientStringInitializer() throws {
		let client = APIClient(instanceURLString: "https://peertube.example.com")
		XCTAssertNotNil(client)
		XCTAssertEqual(client?.instanceHost, "peertube.example.com")

		let invalidClient = APIClient(instanceURLString: "not-a-url")
		XCTAssertNil(invalidClient)
	}

	// MARK: - Authentication Tests

	func testAuthenticationTokenManagement() async throws {
		// Initially not authenticated
		let initialAuth = await apiClient.isAuthenticated()
		XCTAssertFalse(initialAuth)

		// Set token
		let token = AuthToken(
			accessToken: "test-token",
			tokenType: "Bearer",
			expiresIn: 3600
		)

		await apiClient.setAuthToken(token)

		// Should be authenticated now
		let authenticated = await apiClient.isAuthenticated()
		XCTAssertTrue(authenticated)

		// Should return the same token
		let retrievedToken = await apiClient.getAuthToken()
		XCTAssertEqual(retrievedToken?.accessToken, "test-token")
		XCTAssertEqual(retrievedToken?.tokenType, "Bearer")

		// Clear authentication
		await apiClient.clearAuthentication()
		let clearedAuth = await apiClient.isAuthenticated()
		XCTAssertFalse(clearedAuth)
	}

	// MARK: - Rate Limiting Tests

	func testRateLimitingConfiguration() throws {
		let rateLimitedConfig = APIClientConfig(
			instanceURL: testInstanceURL,
			rateLimitingEnabled: true,
			requestsPerInterval: 5,
			intervalDuration: 1.0
		)

		let rateLimitedClient = APIClient(config: rateLimitedConfig)
		XCTAssertEqual(rateLimitedClient.instanceHost, "test.peertube.example")
	}

	func testRateLimiterActor() async throws {
		let rateLimiter = RateLimiter(maxRequests: 3, timeInterval: 1.0)

		// First 3 requests should be allowed
		for _ in 0..<3 {
			let canMake = await rateLimiter.canMakeRequest()
			XCTAssertTrue(canMake)
		}

		// 4th request should be denied
		let denied = await rateLimiter.canMakeRequest()
		XCTAssertFalse(denied)

		// Should have time until next request
		let waitTime = await rateLimiter.timeUntilNextRequest()
		XCTAssertGreaterThan(waitTime, 0)
	}

	// MARK: - URL Building Tests

	func testInstanceComparison() throws {
		let sameInstance = URL(string: "https://test.peertube.example")!
		let differentInstance = URL(string: "https://other.peertube.example")!

		XCTAssertTrue(apiClient.isForInstance(sameInstance))
		XCTAssertFalse(apiClient.isForInstance(differentInstance))
	}

	// MARK: - Error Handling Tests

	func testAuthTokenStructure() throws {
		let token = AuthToken(
			accessToken: "abc123",
			tokenType: "Bearer",
			expiresIn: 7200,
			refreshToken: "refresh123",
			scope: "read write"
		)

		XCTAssertEqual(token.accessToken, "abc123")
		XCTAssertEqual(token.tokenType, "Bearer")
		XCTAssertEqual(token.expiresIn, 7200)
		XCTAssertEqual(token.refreshToken, "refresh123")
		XCTAssertEqual(token.scope, "read write")
	}

	func testAPIClientConfigDefaults() throws {
		let config = APIClientConfig(instanceURL: testInstanceURL)

		XCTAssertEqual(config.instanceURL, testInstanceURL)
		XCTAssertTrue(config.rateLimitingEnabled)
		XCTAssertEqual(config.requestsPerInterval, 50)
		XCTAssertEqual(config.intervalDuration, 10.0)
		XCTAssertEqual(config.timeout, 30.0)
	}

	func testPeerTubeErrorTypes() throws {
		let errorResponse = PeerTubeErrorResponse(
			error: "Video not found",
			code: "VIDEO_NOT_FOUND",
			details: "The requested video does not exist"
		)

		XCTAssertEqual(errorResponse.error, "Video not found")
		XCTAssertEqual(errorResponse.code, "VIDEO_NOT_FOUND")
		XCTAssertEqual(errorResponse.details, "The requested video does not exist")

		// Test error enum
		let apiError = PeerTubeAPIError.serverError(statusCode: 404, error: errorResponse)
		XCTAssertNotNil(apiError.errorDescription)
		XCTAssertTrue(apiError.errorDescription!.contains("Video not found"))
	}

	// MARK: - Sendable Compliance Tests

	func testSendableCompliance() async throws {
		// Test that APIClient can be safely passed between concurrency contexts
		let client = apiClient!

		await withTaskGroup(of: Void.self) { group in
			group.addTask {
				let host = client.instanceHost
				XCTAssertEqual(host, "test.peertube.example")
			}

			group.addTask {
				let baseURL = client.apiBaseURL
				XCTAssertEqual(baseURL.host, "test.peertube.example")
			}
		}
	}

	func testConcurrentAuthenticationAccess() async throws {
		let token = AuthToken(
			accessToken: "concurrent-test-token",
			tokenType: "Bearer",
			expiresIn: 3600
		)

		// Set token from one task
		await apiClient.setAuthToken(token)

		// Access from multiple concurrent tasks
		await withTaskGroup(of: Bool.self) { group in
			for _ in 0..<10 {
				group.addTask {
					await self.apiClient.isAuthenticated()
				}
			}

			var results: [Bool] = []
			for await result in group {
				results.append(result)
			}

			// All should return true since token is set
			XCTAssertTrue(results.allSatisfy { $0 })
		}
	}

	// MARK: - Configuration Tests

	func testCustomConfiguration() throws {
		let customConfig = APIClientConfig(
			instanceURL: testInstanceURL,
			rateLimitingEnabled: false,
			requestsPerInterval: 100,
			intervalDuration: 5.0,
			timeout: 60.0
		)

		let customClient = APIClient(config: customConfig)

		XCTAssertEqual(customClient.instanceHost, "test.peertube.example")
		XCTAssertEqual(customClient.apiBaseURL.path, "/api/v1")
	}

	// MARK: - Thread Safety Tests

	func testConcurrentTokenOperations() async throws {
		let tokens = (0..<10).map { index in
			AuthToken(
				accessToken: "token-\(index)",
				tokenType: "Bearer",
				expiresIn: 3600
			)
		}

		// Perform concurrent token operations
		await withTaskGroup(of: Void.self) { group in
			for (index, token) in tokens.enumerated() {
				group.addTask {
					await self.apiClient.setAuthToken(token)

					// Small delay to increase chance of race conditions
					try? await Task.sleep(nanoseconds: UInt64.random(in: 1_000_000...10_000_000))

					let isAuth = await self.apiClient.isAuthenticated()
					XCTAssertTrue(isAuth, "Should be authenticated at index \(index)")
				}
			}
		}

		// Final state should be authenticated with some token
		let finalAuth = await apiClient.isAuthenticated()
		XCTAssertTrue(finalAuth)
	}
}

// MARK: - Test Helpers

extension APIClientTests {

	/// Helper to create a test configuration
	private func testConfig(rateLimited: Bool = false) -> APIClientConfig {
		return APIClientConfig(
			instanceURL: testInstanceURL,
			rateLimitingEnabled: rateLimited,
			requestsPerInterval: rateLimited ? 3 : 50,
			intervalDuration: rateLimited ? 0.5 : 10.0,
			timeout: 5.0
		)
	}
}

// MARK: - Mock Types for Testing

private struct MockResponse: Codable, Sendable {
	let message: String
	let timestamp: Date
}

private struct MockRequest: Codable, Sendable {
	let action: String
	let data: [String: String]
}
