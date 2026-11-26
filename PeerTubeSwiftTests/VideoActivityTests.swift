//
//  VideoActivityTests.swift
//  PeerTubeSwiftTests
//

import ComposableArchitecture
import DependenciesTestSupport
import Foundation
import GRDB
import SQLiteData
import Testing

@testable import PeerTubeSwift

@Suite struct VideoActivityTests {
  @Test func activitiesVideoTableStoresActivitiesAndNullifiesDeletedReferences() throws {
    try withDependencies {
      try $0.bootstrapDatabase()
    } operation: {
      @Dependency(\.defaultDatabase) var database

      #expect(
        VideoActivity.VideoActivityType.allCases.map { $0.rawValue } == [
          "opened", "watched", "liked", "disliked", "commented", "descriptionOpened",
          "channelTapped", "relatedVideoTapped", "videoTimestampSeekTapped",
          "outboundDescriptionLinkTapped", "share",
        ])

      try database.write { db in
        try db.execute(
          sql: """
            INSERT INTO "instances" ("host", "scheme") VALUES ('example.org', 'https');
            INSERT INTO "videoChannels" ("id", "name", "instanceID") VALUES ('channel-1', 'Channel', 'example.org');
            INSERT INTO "videos" ("id", "channelID", "instanceID", "name", "publishDate")
              VALUES ('video-1', 'channel-1', 'example.org', 'Video', current_timestamp);
            INSERT INTO "activities_video" ("id", "videoID", "channelID", "timestamp", "type")
              VALUES ('00000000-0000-0000-0000-000000000001', 'video-1', 'channel-1', current_timestamp, 'watched');
            """)
      }

      let rows = try database.read { db in
        try Row.fetchAll(db, sql: "SELECT * FROM activities_video")
      }
      #expect(rows.count == 1)
      #expect(rows.first?["type"] as? String == "watched")
      #expect(rows.first?["videoID"] as? String == "video-1")
      #expect(rows.first?["channelID"] as? String == "channel-1")

      try database.write { db in
        try db.execute(
          sql: """
            DELETE FROM "videos" WHERE id = 'video-1';
            DELETE FROM "videoChannels" WHERE id = 'channel-1';
            """)
      }
      let afterDelete = try database.read { db in
        try Row.fetchAll(db, sql: "SELECT * FROM activities_video")
      }
      #expect(afterDelete.count == 1)
      #expect(afterDelete.first?["videoID"] == nil)
      #expect(afterDelete.first?["channelID"] == nil)
    }
  }
}
