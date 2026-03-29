//
//  PeertubeOrchestrator.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 25.12.25.
//

import Foundation
import TubeSDK
import SwiftUI
import SQLiteData

// MARK: - Instance Cache Actor

/// Actor-based cache for instance info to avoid redundant network requests
actor InstanceCache {
    private var cache: [String: (instance: Instance, timestamp: Date)] = [:]
    private let ttl: TimeInterval = 300 // 5 minutes
    
    func get(_ host: String) -> Instance? {
        guard let cached = cache[host],
              Date().timeIntervalSince(cached.timestamp) < ttl else {
            return nil
        }
        return cached.instance
    }
    
    func set(_ host: String, instance: Instance) {
        cache[host] = (instance, Date())
    }
    
    func invalidate(_ host: String) {
        cache.removeValue(forKey: host)
    }
    
    func invalidateAll() {
        cache.removeAll()
    }
}

// Global cache instance - shared across all orchestrator operations
private let instanceCache = InstanceCache()

// MARK: - PeertubeOrchestratorClient

struct PeertubeOrchestratorClient {
    var syncInstanceInfo: @Sendable (String, any DatabaseWriter) async throws -> Instance
    var cacheImageIfNeeded: @Sendable (String, any DatabaseWriter) async throws -> Void
}

import Dependencies

extension PeertubeOrchestratorClient: DependencyKey {
    static let liveValue = Self(
        syncInstanceInfo: { host, database in
            // 1. Check in-memory cache first
            if let cachedInstance = await instanceCache.get(host) {
                // Still need to ensure it exists in DB
                let existsInDB = try await database.read { db in
                    try Instance.find(host).fetchOne(db) != nil
                }
                if existsInDB {
                    return cachedInstance
                }
            }
            
            // 2. Ensure the instance exists in the database
            let existingInstance = try await database.read { db in
                try Instance.find(host).fetchOne(db)
            }
            
            var instance = existingInstance ?? Instance(host: host, scheme: "https")
            if existingInstance == nil {
                let newInstance = instance
                try await database.write { db in
                    try Instance.insert { newInstance }.execute(db)
                }
            }
            
            // 3. Fetch the latest config from the instance
            do {
                let client = try TubeSDKClient(scheme: "https", host: host)
                let config = try await client.instance.getConfig()
                
                instance.name = config.instance.name
                if let avatar = config.instance.avatars?.first?.fileUrl {
                    instance.avatarUrl = avatar
                } else if let avatar = config.instance.avatars?.first?.path {
                    // fallback to path if fileUrl is not available
                    instance.avatarUrl = try client.getImageUrl(path: avatar).absoluteString
                }
                
                let updatedInstance = instance
                try await database.write { db in
                    try Instance.upsert { updatedInstance }.execute(db)
                }
                
                // 4. Update in-memory cache
                await instanceCache.set(host, instance: updatedInstance)
            } catch {
                print("Failed to sync instance info for \(host): \(error)")
            }
            
            return instance
        },
        cacheImageIfNeeded: { urlString, database in
            // Check if it already exists
            let exists = try await database.read { db in
                try PeertubeImage.find(urlString).fetchOne(db) != nil
            }
            if exists { return }
            
            // Download data
            guard let url = URL(string: urlString) else { return }
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Save to database
            let image = PeertubeImage(id: urlString, data: data)
            try await database.write { db in
                try PeertubeImage.insert { image }.execute(db)
            }
        }
    )
}


extension DependencyValues {
    var peertubeOrchestrator: PeertubeOrchestratorClient {
        get { self[PeertubeOrchestratorClient.self] }
        set { self[PeertubeOrchestratorClient.self] = newValue }
    }
}

