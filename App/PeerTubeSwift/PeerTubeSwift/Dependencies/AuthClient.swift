import Foundation
import Dependencies
import Security
import TubeSDK

public struct UserSession: Codable, Equatable, Sendable {
    public var username: String
    public var host: String
    public var token: OAuthToken
    public var avatarUrl: String?
    
    public init(username: String, host: String, token: OAuthToken, avatarUrl: String? = nil) {
        self.username = username
        self.host = host
        self.token = token
        self.avatarUrl = avatarUrl
    }
}

public struct AuthClient: Sendable {
    public var getSession: @Sendable () async throws -> UserSession?
    public var saveSession: @Sendable (UserSession) async throws -> Void
    public var deleteSession: @Sendable () async throws -> Void
}

extension AuthClient: DependencyKey {
    public static let liveValue = AuthClient(
        getSession: {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "PeerTubeSwiftAuth",
                kSecReturnData as String: true,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            var item: CFTypeRef?
            let status = SecItemCopyMatching(query as CFDictionary, &item)
            
            guard status == errSecSuccess, let data = item as? Data else {
                return nil
            }
            
            return try JSONDecoder().decode(UserSession.self, from: data)
        },
        saveSession: { session in
            let data = try JSONEncoder().encode(session)
            
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "PeerTubeSwiftAuth"
            ]
            
            let attributes: [String: Any] = [
                kSecValueData as String: data
            ]
            
            var status = SecItemUpdate(query as CFDictionary, attributes as CFDictionary)
            
            if status == errSecItemNotFound {
                var newItem = query
                newItem[kSecValueData as String] = data
                status = SecItemAdd(newItem as CFDictionary, nil)
            }
            
            guard status == errSecSuccess else {
                throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
            }
        },
        deleteSession: {
            let query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrService as String: "PeerTubeSwiftAuth"
            ]
            
            let status = SecItemDelete(query as CFDictionary)
            guard status == errSecSuccess || status == errSecItemNotFound else {
                throw NSError(domain: NSOSStatusErrorDomain, code: Int(status), userInfo: nil)
            }
        }
    )
    
    public static let testValue = AuthClient(
        getSession: { nil },
        saveSession: { _ in },
        deleteSession: { }
    )
}

extension DependencyValues {
    public var authClient: AuthClient {
        get { self[AuthClient.self] }
        set { self[AuthClient.self] = newValue }
    }
}
