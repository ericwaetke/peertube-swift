//
//  VideoChannel.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 23.12.25.
//

import Dependencies
import Foundation
import SQLiteData

@Table struct Account: Identifiable {
    let id: UUID
    var name: String
    
    var instanceID: Instance.ID
    var avatarID: PeertubeImage.ID?
}

@Table struct VideoChannel: Identifiable {
    let id: UUID
    var name: String
    
    var avatarID: PeertubeImage.ID?
    var instanceID: Instance.ID
}

@Table struct Instance: Identifiable {
    let id: UUID
    var schema: String
    var host: String
    var name: String?
    
    var avatarID: PeertubeImage.ID?
}

@Table struct PeertubeImage: Identifiable {
    let id: UUID
    let instanceID: Instance.ID
    var url: String
}

//@Table struct Comment: Identifiable {
//    let id: UUID
//    let accountID: Account.ID
//
//    let videoID: Video.ID
//    var replyToCommentID: Comment.ID?
//
//    var likes: Int
//    var dislikes: Int
//}

@Table struct Video: Identifiable {
    let id: UUID
    let channelID: VideoChannel.ID
    var instanceID: Instance.ID
}

@Table struct Subscription: Identifiable {
    let id: UUID
    let channelID: VideoChannel.ID
    
    let createdAt: Date
}

func appDatabase() throws -> any DatabaseWriter {
    let database = try SQLiteData.defaultDatabase()
    var migrator = DatabaseMigrator()
    #if DEBUG
    migrator.eraseDatabaseOnSchemaChange = true
    #endif
    
    migrator.registerMigration("Create 'games' and 'players' tables") { db in
        try #sql("""
            CREATE TABLE "videoChannels" (
                "id" TEXT PRIMARY KEY NOT NULL,
                "name" TEXT NOT NULL,
                "instanceID" TEXT NOT NULL REFERENCES "instances"("id") ON DELETE CASCADE,
                "avatarID" TEXT REFERENCES "images"("id")
            ) STRICT
        """)
        .execute (db)
        
        try #sql("""
            CREATE TABLE "instances" (
                "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                "schema" TEXT NOT NULL,
                "host" TEXT NOT NULL,
                "name" TEXT,
                "avatarID" TEXT REFERENCES "images"("id")
            ) STRICT
        """)
        .execute (db)
        
        try #sql("""
            CREATE TABLE "images" (
                "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                "instanceID" TEXT NOT NULL REFERENCES "instances"("id") ON DELETE CASCADE,
                "url" TEXT NOT NULL
            ) STRICT
        """)
        .execute (db)
        
        try #sql("""
            CREATE TABLE "subscriptions" (
                "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                "channelID" TEXT NOT NULL REFERENCES "videoChannels"("id") ON DELETE CASCADE,
                "createdAt" TEXT NOT NULL DEFAULT current_timestamp 
            ) STRICT
        """)
        .execute (db)
    }
    
    try migrator.migrate(database)
    return database
}

extension DependencyValues {
    mutating func bootstrapDatabase() throws {
        defaultDatabase = try appDatabase()
    }
}

extension DatabaseWriter {
    func seed() throws {
        try write { db in
            try db.seed {
                Instance(id: UUID(1), schema: "https", host: "peertube.wtf")
                Instance(id: UUID(2), schema: "https", host: "ard.de")
                
                VideoChannel(id: UUID(1), name: "Gronkh", instanceID: UUID(1))
                VideoChannel(id: UUID(2), name: "ARD", instanceID: UUID(2))
                VideoChannel(id: UUID(3), name: "Collective Change", instanceID: UUID(1))
                
                Subscription.Draft(channelID: UUID(1), createdAt: .distantPast)
                Subscription.Draft(channelID: UUID(3), createdAt: .now)
            }
        }
    }
}
