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
    private var pendingTasks: [String: Task<Instance?, Never>] = [:]
    private let ttl: TimeInterval = 300 // 5 minutes
    
    func get(_ host: String) -> Instance? {
        guard let cached = cache[host],
              Date().timeIntervalSince(cached.timestamp) < ttl else {
            return nil
        }
        return cached.instance
    }
    
    /// Get or create a task for syncing instance info, coalescing concurrent requests
    /// for the same host to avoid redundant network calls
    func getOrCreateSyncTask(
        _ host: String,
        syncBlock: @escaping () async -> Instance?
    ) -> Task<Instance?, Never> {
        // If there's already a pending task for this host, return it
        if let existingTask = pendingTasks[host] {
            return existingTask
        }
        
        // Create a new task and store it
        let task = Task<Instance?, Never> {
            let result = await syncBlock()
            // Remove from pending once complete
            pendingTasks.removeValue(forKey: host)
            return result
        }
        
        pendingTasks[host] = task
        return task
    }
    
    func set(_ host: String, instance: Instance) {
        cache[host] = (instance, Date())
    }
    
    func invalidate(_ host: String) {
        cache.removeValue(forKey: host)
        pendingTasks.removeValue(forKey: host)
    }
    
    func invalidateAll() {
        cache.removeAll()
        pendingTasks.removeAll()
    }
}

// Global cache instance - shared across all orchestrator operations
private let instanceCache = InstanceCache()

// MARK: - PeertubeOrchestratorClient

struct PeertubeOrchestratorClient {
    var syncInstanceInfo: @Sendable (String, any DatabaseWriter) async throws -> Instance
    var cacheImageIfNeeded: @Sendable (String, any DatabaseWriter) async throws -> Void
}

/// Helper function for instance sync - separated for use in task coalescing
private func performInstanceSync(host: String, database: any DatabaseWriter) async -> Instance? {
    // Ensure the instance exists in the database
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
    
    // Fetch the latest config from the instance
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
        
        // Update in-memory cache
        await instanceCache.set(host, instance: updatedInstance)
        return updatedInstance
    } catch {
        print("Failed to sync instance info for \(host): \(error)")
        return nil
    }
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
            
            // 2. Use coalescing to avoid concurrent requests for the same host
            let syncTask = await instanceCache.getOrCreateSyncTask(host) {
                // This block runs only once even if multiple tasks request the same host
                await performInstanceSync(host: host, database: database)
            }
            
            // Wait for the task to complete (or return cached result if available)
            if let result = await syncTask.value {
                return result
            }
            
            // Fallback: try to get from DB if sync failed
            return try await database.read { db in
                try Instance.find(host).fetchOne(db) ?? Instance(host: host, scheme: "https")
            }
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

