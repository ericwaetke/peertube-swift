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
    var avatarUrl: String?
}

@Table struct VideoChannel: Identifiable, Hashable {
    // \(channelname)@\(host)
    let id: String
    var name: String

    var avatarUrl: String?
    var instanceID: Instance.ID
}

@Table struct Instance: Identifiable, Equatable, Hashable {
//    let id: UUID
    @Column(primaryKey: true)
    let host: String
    var scheme: String
    var name: String?
    var avatarUrl: String?
}

extension Instance {
    var id: String {
        self.host
    }
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
    var duration: Int?
    var views: Int = 0
    var comments: Int = 0
    var likes: Int = 0
    var dislikes: Int = 0
    var thumbnailUrl: String?
}

@Table struct PeertubeSubscription: Identifiable {
    let id: String
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
                    "host" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE,
                    "scheme" TEXT NOT NULL,
                    "name" TEXT,
                    "avatarUrl" TEXT
                ) STRICT
            """
        )
        .execute(db)

        // Create accounts (depends on instances and images)
        try #sql(
            """
                CREATE TABLE "accounts" (
                    "id" TEXT PRIMARY KEY NOT NULL,
                    "name" TEXT NOT NULL,
                    "instanceID" TEXT NOT NULL REFERENCES "instances"("host") ON DELETE CASCADE,
                    "avatarUrl" TEXT
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
                    "instanceID" TEXT NOT NULL REFERENCES "instances"("host") ON DELETE CASCADE,
                    "avatarUrl" TEXT
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
                    "instanceID" TEXT NOT NULL REFERENCES "instances"("host") ON DELETE CASCADE,
                    "name" TEXT NOT NULL,
                    "publishDate" TEXT NOT NULL,
                    "duration" INTEGER,
                    "views" INTEGER NOT NULL DEFAULT 0,
                    "comments" INTEGER NOT NULL DEFAULT 0,
                    "likes" INTEGER NOT NULL DEFAULT 0,
                    "dislikes" INTEGER NOT NULL DEFAULT 0,
                    "thumbnailUrl" TEXT
                ) STRICT
            """
        )
        .execute(db)

        // Create subscriptions (depends on channels)
        try #sql(
            """
                CREATE TABLE "peertubeSubscriptions" (
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
                CREATE INDEX "index_subscriptions_on_channelID" ON "peertubeSubscriptions"("channelID")
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
                Instance(host: "peertube.wtf", scheme: "https")
                Instance(host: "ard.de", scheme: "https", avatarUrl: "https://yt3.googleusercontent.com/ytc/AIdro_nkghDj-XHzlJ0CCE1q4BXzL01ufINgm9KUiqfhaWTBjUnZ=s160-c-k-c0x00ffffff-no-rj")

                VideoChannel(id: "peertube.wtf-1", name: "Gronkh", avatarUrl: "https://yt3.googleusercontent.com/ytc/AIdro_ko2x8r12BwkrHwYRNEVLUwCkd1MsWA496y7Pr8wX-3c6Y=s160-c-k-c0x00ffffff-no-rj", instanceID: "peertube.wtf")
                VideoChannel(id: "ard.de-1", name: "ARD", instanceID: "ard.de")
                VideoChannel(id: "peertube.wtf-2", name: "Collective Change", instanceID: "peertube.wtf")

                PeertubeSubscription.Draft(channelID: "peertube.wtf-1", createdAt: .distantPast)
                PeertubeSubscription.Draft(channelID: "peertube.wtf-2", createdAt: .now)

                Video(
                    id: UUID(1),
                    channelID: "peertube.wtf-1",
                    instanceID: "peertube.wtf",
                    name: "Minecraft Let’s Play #001",
                    publishDate: .now,
                    thumbnailUrl: "https://i.ytimg.com/vi/DM52HxaLK-Y/hqdefault.jpg?sqp=-oaymwEXCOADEI4CSFryq4qpAwkIARUAAIhCGAE=&rs=AOn4CLCYG-ebPaEOzdf_cIFY7tdd2oD5qg&days_since_epoch=20146"
                )
            }
        }
    }
}
