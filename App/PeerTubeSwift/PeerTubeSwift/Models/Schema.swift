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
    // \(host)-\(id)
    let id: String
    var name: String

    var avatarID: PeertubeImage.ID?
    var instanceID: Instance.ID
}

@Table struct Instance: Identifiable {
    let id: UUID
    var scheme: String
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

@Table struct Video: Identifiable, Hashable {
    let id: UUID
    let channelID: VideoChannel.ID
    var instanceID: Instance.ID

    var name: String
    var publishDate: Date
    var views: Int = 0
    var comments: Int = 0
    var likes: Int = 0
    var dislikes: Int = 0
    var thumbnailID: PeertubeImage.ID?
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

    migrator.registerMigration("Create PeerTube database schema") { db in
        // Create instances first (no dependencies)
        try #sql(
            """
                CREATE TABLE "instances" (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "scheme" TEXT NOT NULL,
                    "host" TEXT NOT NULL UNIQUE,
                    "name" TEXT,
                    "avatarID" TEXT REFERENCES "peertubeImages"("id")
                ) STRICT
            """
        )
        .execute(db)

        // Create images (depends on instances)
        try #sql(
            """
                CREATE TABLE "peertubeImages" (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "instanceID" TEXT NOT NULL REFERENCES "instances"("id") ON DELETE CASCADE,
                    "url" TEXT NOT NULL
                ) STRICT
            """
        )
        .execute(db)

        // Create accounts (depends on instances and images)
        try #sql(
            """
                CREATE TABLE "accounts" (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "name" TEXT NOT NULL,
                    "instanceID" TEXT NOT NULL REFERENCES "instances"("id") ON DELETE CASCADE,
                    "avatarID" TEXT REFERENCES "peertubeImages"("id")
                ) STRICT
            """
        )
        .execute(db)

        // Create video channels (depends on instances and images)
        try #sql(
            """
                CREATE TABLE "videoChannels" (
                    "id" TEXT PRIMARY KEY NOT NULL UNIQUE,
                    "name" TEXT NOT NULL,
                    "instanceID" TEXT NOT NULL REFERENCES "instances"("id") ON DELETE CASCADE,
                    "avatarID" TEXT REFERENCES "peertubeImages"("id")
                ) STRICT
            """
        )
        .execute(db)

        // Create videos (depends on channels and instances)
        try #sql(
            """
                CREATE TABLE "videos" (
                    "id" TEXT PRIMARY KEY NOT NULL,
                    "channelID" TEXT NOT NULL REFERENCES "videoChannels"("id") ON DELETE CASCADE,
                    "instanceID" TEXT NOT NULL REFERENCES "instances"("id") ON DELETE CASCADE,
                    "name" TEXT NOT NULL,
                    "publishDate" TEXT NOT NULL,
                    "views" INTEGER NOT NULL DEFAULT 0,
                    "comments" INTEGER NOT NULL DEFAULT 0,
                    "likes" INTEGER NOT NULL DEFAULT 0,
                    "dislikes" INTEGER NOT NULL DEFAULT 0,
                    "thumbnailID" TEXT REFERENCES "peertubeImages"("id")
                ) STRICT
            """
        )
        .execute(db)

        // Create subscriptions (depends on channels)
        try #sql(
            """
                CREATE TABLE "subscriptions" (
                    "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE DEFAULT (uuid()),
                    "channelID" TEXT NOT NULL UNIQUE REFERENCES "videoChannels"("id") ON DELETE CASCADE,
                    "createdAt" TEXT NOT NULL DEFAULT current_timestamp
                ) STRICT
            """
        )
        .execute(db)

        // Create indexes for better performance
        try #sql(
            """
                CREATE INDEX "index_peertubeImages_on_instanceID" ON "peertubeImages"("instanceID")
            """
        )
        .execute(db)

        try #sql(
            """
                CREATE INDEX "index_accounts_on_instanceID" ON "accounts"("instanceID")
            """
        )
        .execute(db)

        try #sql(
            """
                CREATE INDEX "index_videoChannels_on_instanceID" ON "videoChannels"("instanceID")
            """
        )
        .execute(db)

        try #sql(
            """
                CREATE INDEX "index_videos_on_channelID" ON "videos"("channelID")
            """
        )
        .execute(db)

        try #sql(
            """
                CREATE INDEX "index_subscriptions_on_channelID" ON "subscriptions"("channelID")
            """
        )
        .execute(db)
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
                Instance(id: UUID(1), scheme: "https", host: "peertube.wtf")
                Instance(id: UUID(2), scheme: "https", host: "ard.de")

                VideoChannel(id: "peertube.wtf-1", name: "Gronkh", instanceID: UUID(1))
                VideoChannel(id: "ard.de-1", name: "ARD", instanceID: UUID(2))
                VideoChannel(id: "peertube.wtf-2", name: "Collective Change", instanceID: UUID(1))

                Subscription.Draft(channelID: "peertube.wtf-1", createdAt: .distantPast)
                Subscription.Draft(channelID: "peertube.wtf-2", createdAt: .now)
            }
        }
    }
}
