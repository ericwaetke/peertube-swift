//
//  NetworkingFoundation.swift
//  PeerTubeSwift
//
//  Created on 2024-12-17.
//

import Foundation

/// Network errors that can occur during API requests
public enum NetworkError: Error, LocalizedError, Sendable {
	case invalidURL
	case noData
	case invalidResponse
	case httpError(statusCode: Int, data: Data?)
	case decodingError(Error)
	case encodingError(Error)
	case networkUnavailable
	case timeout
	case unknown(Error)

	public var errorDescription: String? {
		switch self {
		case .invalidURL:
			return "Invalid URL"
		case .noData:
			return "No data received"
		case .invalidResponse:
			return "Invalid response"
		case .httpError(let statusCode, _):
			return "HTTP error with status code: \(statusCode)"
		case .decodingError(let error):
			return "Decoding error: \(error.localizedDescription)"
		case .encodingError(let error):
			return "Encoding error: \(error.localizedDescription)"
		case .networkUnavailable:
			return "Network unavailable"
		case .timeout:
			return "Request timeout"
		case .unknown(let error):
			return "Unknown error: \(error.localizedDescription)"
		}
	}
}

/// HTTP method types
public enum HTTPMethod: String, Sendable {
	case GET
	case POST
	case PUT
	case DELETE
	case PATCH
}

/// Networking foundation class for PeerTube API communication
public final class NetworkingFoundation: @unchecked Sendable {
	// MARK: - Properties

	/// Shared instance
	public static let shared = NetworkingFoundation()

	/// URL session for network requests
	public let urlSession: URLSession

	/// JSON decoder with custom date decoding strategy
	public let jsonDecoder: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		decoder.keyDecodingStrategy = .convertFromSnakeCase
		return decoder
	}()

	/// JSON encoder with custom date encoding strategy
	public let jsonEncoder: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		encoder.keyEncodingStrategy = .convertToSnakeCase
		return encoder
	}()

	// MARK: - Initialization

	public init(configuration: URLSessionConfiguration = .default) {
		// Configure session for optimal performance
		configuration.timeoutIntervalForRequest = 30.0
		configuration.timeoutIntervalForResource = 60.0
		configuration.requestCachePolicy = .useProtocolCachePolicy
		configuration.httpMaximumConnectionsPerHost = 5

		urlSession = URLSession(configuration: configuration)
	}

	// MARK: - Request Methods

	/// Perform a generic network request
	public func request<T: Codable & Sendable>(
		url: URL,
		method: HTTPMethod = .GET,
		headers: [String: String]? = nil,
		body: Data? = nil
	) async throws -> T {
		let data = try await performRequest(
			url: url,
			method: method,
			headers: headers,
			body: body
		)

		do {
			return try jsonDecoder.decode(T.self, from: data)
		} catch {
			throw NetworkError.decodingError(error)
		}
	}

	/// Perform a request that returns raw data
	public func requestData(
		url: URL,
		method: HTTPMethod = .GET,
		headers: [String: String]? = nil,
		body: Data? = nil
	) async throws -> Data {
		return try await performRequest(
			url: url,
			method: method,
			headers: headers,
			body: body
		)
	}

	/// Perform a request with a Codable request body
	public func request<Request: Codable & Sendable, Response: Codable & Sendable>(
		url: URL,
		method: HTTPMethod = .POST,
		headers: [String: String]? = nil,
		requestBody: Request
	) async throws -> Response {
		let bodyData: Data
		do {
			bodyData = try jsonEncoder.encode(requestBody)
		} catch {
			throw NetworkError.encodingError(error)
		}

		var requestHeaders = headers ?? [:]
		requestHeaders["Content-Type"] = "application/json"

		return try await request(
			url: url,
			method: method,
			headers: requestHeaders,
			body: bodyData
		)
	}

	// MARK: - Private Methods

	private func performRequest(
		url: URL,
		method: HTTPMethod,
		headers: [String: String]?,
		body: Data?
	) async throws -> Data {
		var request = URLRequest(url: url)
		request.httpMethod = method.rawValue
		request.httpBody = body

		// Add headers
		headers?.forEach { key, value in
			request.setValue(value, forHTTPHeaderField: key)
		}

		// Add user agent
		request.setValue(
			"PeerTubeSwift/\(PeerTubeSwift.version) iOS",
			forHTTPHeaderField: "User-Agent"
		)

		do {
			let (data, response) = try await urlSession.data(for: request)

			guard let httpResponse = response as? HTTPURLResponse else {
				throw NetworkError.invalidResponse
			}

			// Check for HTTP errors
			switch httpResponse.statusCode {
			case 200...299:
				return data
			case 400...499:
				throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
			case 500...599:
				throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
			default:
				throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
			}

		} catch let error as NetworkError {
			throw error
		} catch let urlError as URLError {
			switch urlError.code {
			case .notConnectedToInternet, .networkConnectionLost:
				throw NetworkError.networkUnavailable
			case .timedOut:
				throw NetworkError.timeout
			default:
				throw NetworkError.unknown(urlError)
			}
		} catch {
			throw NetworkError.unknown(error)
		}
	}
}

// MARK: - Convenience Extensions

extension URL {
	/// Create URL with query parameters
	func appending(queryItems: [URLQueryItem]) -> URL? {
		guard var components = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
			return nil
		}
		components.queryItems = (components.queryItems ?? []) + queryItems
		return components.url
	}
}

extension URLQueryItem {
	/// Convenience initializer for string values
	init(name: String, value: String?) {
		self.init(name: name, value: value)
	}

	/// Convenience initializer for integer values
	init(name: String, value: Int) {
		self.init(name: name, value: String(value))
	}

	/// Convenience initializer for boolean values
	init(name: String, value: Bool) {
		self.init(name: name, value: value ? "true" : "false")
	}
}
