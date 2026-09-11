//
//  Schema.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 23.12.25.
//

import Dependencies
import Foundation
import PeerSeekSDK
import SQLiteData
import TubeSDK

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
  var description: String?
  var instanceID: Instance.ID

  init(
    id: String, name: String, avatarUrl: String? = nil, description: String? = nil,
    instanceID: Instance.ID
  ) {
    self.id = id
    self.name = name
    self.avatarUrl = avatarUrl
    self.description = description
    self.instanceID = instanceID
  }

  init(videoChannelSummary: VideoChannelSummary, client: TubeSDKClient, instanceID: String) throws {
    guard let channelName = videoChannelSummary.name,
      let channelHost = videoChannelSummary.host
    else {
      throw TubeError.invalidChannelData
    }
    self.id = "\(channelName)@\(channelHost)"
    self.name = videoChannelSummary.displayName ?? channelName
    self.avatarUrl = videoChannelSummary.avatars?.first?.fileUrl
    self.instanceID = instanceID
  }
}

@Table struct Instance: Identifiable, Equatable, Hashable {
  //    let id: UUID
  @Column(primaryKey: true)
  let host: String
  var scheme: String
  var name: String?
  var avatarUrl: String?

  init(host: String, scheme: String, name: String? = nil, avatarUrl: String? = nil) {
    self.host = host
    self.scheme = scheme
    self.name = name
    self.avatarUrl = avatarUrl
  }
  init(videoChannelSummary: VideoChannelSummary, client: TubeSDKClient) throws {
    guard let host = videoChannelSummary.host,
      let urlString = videoChannelSummary.url,
      let url = URL(string: urlString),
      let scheme = url.scheme
    else {
      throw TubeError.missingRequiredField("host, URL, or scheme")
    }
    self.host = host
    self.scheme = scheme
    //        self.name = videoChannelSummary.displayName
    //        self.avatarUrl = videoChannelSummary.avatars?.first?.fileUrl
  }
}

extension Instance {
  var id: String {
    host
  }
}

// @Table struct Comment: Identifiable {
//    let id: UUID
//    let accountID: Account.ID
//
//    let videoID: Video.ID
//    var replyToCommentID: Comment.ID?
//
//    var likes: Int
//    var dislikes: Int
// }

@Table struct Video: Identifiable, Hashable {
  let id: UUID
  let channelID: VideoChannel.ID
  var instanceID: Instance.ID

  var name: String
  var publishDate: Date
  var duration: Int?
  var currentTime: Int?
  var views: Int = 0
  var comments: Int = 0
  var likes: Int = 0
  var dislikes: Int = 0
  var thumbnailUrl: String?

  init(
    id: UUID, channelID: VideoChannel.ID, instanceID: Instance.ID, name: String, publishDate: Date,
    duration: Int? = nil, currentTime: Int? = nil, views: Int, comments: Int, likes: Int,
    dislikes: Int, thumbnailUrl: String? = nil
  ) {
    self.id = id
    self.channelID = channelID
    self.instanceID = instanceID
    self.name = name
    self.publishDate = publishDate
    self.duration = duration
    self.currentTime = currentTime
    self.views = views
    self.comments = comments
    self.likes = likes
    self.dislikes = dislikes
    self.thumbnailUrl = thumbnailUrl
  }

  init(assembledVideo: AssembledVideo) {
    self.id = assembledVideo.id
    self.channelID = assembledVideo.channel.id
    self.instanceID = assembledVideo.instance.id
    self.name = assembledVideo.name
    self.publishDate = assembledVideo.publishDate
    self.duration = assembledVideo.duration
    self.currentTime = assembledVideo.currentTime
    self.views = assembledVideo.views
    self.comments = assembledVideo.comments
    self.likes = assembledVideo.likes
    self.dislikes = assembledVideo.dislikes
    self.thumbnailUrl = assembledVideo.thumbnailUrl
  }

  init(tubeVideo: TubeSDK.Video, client: TubeSDKClient) throws {
    guard
      let uuid = tubeVideo.uuid,
      let channelID = tubeVideo.channel?.id,
      let name = tubeVideo.name,
      let views = tubeVideo.views,
      let publishDate = tubeVideo.publishedAt,
      let comments = tubeVideo.comments,
      let likes = tubeVideo.likes,
      let dislikes = tubeVideo.dislikes
    else {
      print("couldnt assemble `Video` from tube video. No video channel summary")
      throw TubeError.missingRequiredField("video fields (uuid, name, views, etc.)")
    }

    guard let channelName = tubeVideo.channel?.name,
      let channelHost = tubeVideo.channel?.host
    else {
      throw TubeError.invalidChannelData
    }

    self.id = uuid
    self.channelID = "\(channelName)@\(channelHost)"
    self.instanceID = channelHost
    self.name = name
    self.publishDate = publishDate
    self.duration = tubeVideo.duration
    self.currentTime = tubeVideo.userHistory?.currentTime
    self.views = views
    self.comments = comments
    self.likes = likes
    self.dislikes = dislikes
    self.thumbnailUrl = tubeVideo.bestThumbnailUrl(client: client)
  }
}

struct AssembledVideo: Identifiable, Hashable {
  var id: UUID
  var channel: VideoChannel
  var instance: Instance

  var name: String
  var publishDate: Date
  var duration: Int?
  var currentTime: Int?
  var views: Int = 0
  var comments: Int = 0
  var likes: Int = 0
  var dislikes: Int = 0
  var thumbnailUrl: String?

  init(tubeVideo: TubeSDK.Video, client: TubeSDKClient) throws {
    guard
      let uuid = tubeVideo.uuid,
      //            let channelID = tubeVideo.channel?.id,
      let name = tubeVideo.name,
      let views = tubeVideo.views,
      let publishDate = tubeVideo.publishedAt,
      let likes = tubeVideo.likes,
      let dislikes = tubeVideo.dislikes
    else {
      print("couldnt assemble `AssembledVideo` from tube video. Values are missing")
      if tubeVideo.uuid == nil { print("uuid missing") }
      if tubeVideo.name == nil { print("name missing") }
      if tubeVideo.views == nil { print("views missing") }
      if tubeVideo.publishedAt == nil { print("publishedAt missing") }
      if tubeVideo.likes == nil { print("likes missing") }
      if tubeVideo.dislikes == nil { print("dislikes missing") }

      throw TubeError.missingRequiredField("video fields (uuid, name, views, etc.)")
    }

    guard let videoChannelSummary = tubeVideo.channel else {
      print("couldnt assemble `AssembledVideo` from tube video. No video channel summary")
      throw TubeError.invalidChannelData
    }

    let instance = try Instance(videoChannelSummary: videoChannelSummary, client: client)

    let channel = try VideoChannel(
      videoChannelSummary: videoChannelSummary, client: client, instanceID: instance.id)

    self.id = uuid
    self.channel = channel
    self.instance = instance
    self.name = name
    self.publishDate = publishDate
    self.duration = tubeVideo.duration
    self.currentTime = tubeVideo.userHistory?.currentTime
    self.views = views
    self.comments = comments ?? 0
    self.likes = likes
    self.dislikes = dislikes
    self.thumbnailUrl = tubeVideo.bestThumbnailUrl(client: client)
  }

  init(seekVideo: PeerSeekSDK.Video, currentTime: Int?) async throws {
    guard let uuid = UUID(uuidString: seekVideo.id) else {
      throw TubeError.invalidUUID
    }

    @Dependency(\.defaultDatabase) var database

    let instance = try await database.write { db in
      try Instance.upsert {
        Instance.Draft(host: seekVideo.instance, scheme: "https")
      }
      .returning(\.self)
      .fetchOne(db)
    }

    guard let instance = instance else {
      throw TubeError.invalidInstance
    }

    print("instance: \(instance)")

    self.id = uuid
    self.channel = VideoChannel(
      id: "\(seekVideo.channelHandle)@\(seekVideo.instance)",
      name: seekVideo.channel ?? "Unknown Channel", instanceID: instance.id)
    self.instance = instance
    self.name = seekVideo.title
    self.publishDate = seekVideo.publishedAt
    self.duration = seekVideo.durationSeconds
    self.currentTime = currentTime
    self.views = seekVideo.views
    self.comments = seekVideo.comments
    self.likes = seekVideo.likes
    self.dislikes = 0
    self.thumbnailUrl = seekVideo.thumbnailUrl
  }
}

@Table struct PeertubeSubscription: Identifiable, Equatable, Hashable {
  let id: String
  let channelID: VideoChannel.ID

  let createdAt: Date
  var notifyOnNewVideo: Bool = false
}

@Table struct PeertubeImage: Identifiable, Equatable {
  let id: String
  var data: Data
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
              "avatarUrl" TEXT,
              "description" TEXT
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
              "currentTime" INTEGER,
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

  migrator.registerMigration("Add notifyOnNewVideo to subscriptions") { db in
    try db.execute(
      literal: """
            ALTER TABLE "peertubeSubscriptions"
            ADD COLUMN "notifyOnNewVideo" INTEGER NOT NULL DEFAULT 0
        """)
  }

  migrator.registerMigration("Create peertubeImages") { db in
    try #sql(
      """
          CREATE TABLE "peertubeImages" (
              "id" TEXT PRIMARY KEY NOT NULL ON CONFLICT REPLACE,
              "data" BLOB NOT NULL
          ) STRICT
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
        Instance(
          host: "ard.de", scheme: "https",
          avatarUrl:
            "https://yt3.googleusercontent.com/ytc/AIdro_nkghDj-XHzlJ0CCE1q4BXzL01ufINgm9KUiqfhaWTBjUnZ=s160-c-k-c0x00ffffff-no-rj"
        )

        VideoChannel(
          id: "peertube.wtf-1", name: "Gronkh",
          avatarUrl:
            "https://yt3.googleusercontent.com/ytc/AIdro_ko2x8r12BwkrHwYRNEVLUwCkd1MsWA496y7Pr8wX-3c6Y=s160-c-k-c0x00ffffff-no-rj",
          instanceID: "peertube.wtf")
        VideoChannel(id: "ard.de-1", name: "ARD", instanceID: "ard.de")
        VideoChannel(id: "peertube.wtf-2", name: "Collective Change", instanceID: "peertube.wtf")
        VideoChannel(
          id: "arthurpizza@tilvids.com", name: "arthur.pizza",
          avatarUrl:
            "https://peertube.wtf/lazy-static/avatars/8cdb6bf9-f59d-4ab6-9c19-976d8e4a9f37.jpg",
          instanceID: "peertube.wtf")

        PeertubeSubscription.Draft(channelID: "arthurpizza@tilvids.com", createdAt: .distantPast)
        //                PeertubeSubscription.Draft(channelID: "peertube.wtf-2", createdAt: .now)

        Video(
          id: UUID(1),
          channelID: "peertube.wtf-1",
          instanceID: "peertube.wtf",
          name: "Minecraft Let’s Play #001",
          publishDate: .now,
          duration: 0,
          currentTime: 0,
          views: 0,
          comments: 0,
          likes: 0,
          dislikes: 0,
          thumbnailUrl:
            "https://i.ytimg.com/vi/DM52HxaLK-Y/hqdefault.jpg?sqp=-oaymwEXCOADEI4CSFryq4qpAwkIARUAAIhCGAE=&rs=AOn4CLCYG-ebPaEOzdf_cIFY7tdd2oD5qg&days_since_epoch=20146"
        )
      }
    }
  }
}
