//
//  Explore.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SQLiteData
import SwiftUI
import TubeSDK

struct Explore: View {
    @Environment(AppState.self) private var appState: AppState
    
    @State var loading = false
    
    @FetchAll var instances: [Instance]
    
    @Selection struct Row: Hashable {
        public static func == (lhs: Explore.Row, rhs: Explore.Row) -> Bool {
            return lhs.video.id == rhs.video.id
        }
        
        let video: Video
        let thumbnail: PeertubeImage?
        let channel: VideoChannel?
    }
    
    @FetchAll(
        #sql(
            """
            SELECT 
                \(Video.columns),
                \(PeertubeImage.columns),
                \(VideoChannel.columns)
            FROM \(Video.self)
            LEFT JOIN \(PeertubeImage.self) ON \(Video.thumbnailID) = \(PeertubeImage.id)
            LEFT JOIN \(VideoChannel.self) ON \(Video.channelID) = \(VideoChannel.id)
            """
        )
    )
    var feed: [Row]
    
    @Dependency(\.defaultDatabase) var database
    
    func getVideoFeed() async throws {
        let clients = instances.compactMap { appState.instances[$0.host] }
        
        // Get Videos from Peertube
        for client in clients {
            let videos = try await client.getVideos()
            
            // Add Videos to SQLite
            
            for peertubeVideo in videos {
                guard let channel = peertubeVideo.channel,
                      let videoId = peertubeVideo.uuid,
                      let videoName = peertubeVideo.name,
                      let publishedAt = peertubeVideo.publishedAt,
                      let channelId = channel.id,
                      let channelDisplayName = channel.displayName
                else {
                    print("Error adding video")
                    continue
                }
                
                let instance = try await database.read { db in
                    try Instance
                        .where { $0.host == client.instance.host }
                        .limit(1)
                        .fetchOne(db)
                }
                
                guard let instance = instance else {
                    print("instance not found in db")
                    continue
                }
                
                await withErrorReporting {
                    try await database.write { db in
                        var thumbnailId: UUID?
                        
                        if let thumbnailPath = peertubeVideo.thumbnailPath,
                           let thumbnailURL = try? client.getImageUrl(path: thumbnailPath)
                        {
                            thumbnailId = try PeertubeImage
                                .insert {
                                    PeertubeImage.Draft(
                                        instanceID: instance.id, url: thumbnailURL.absoluteString)
                                }
                                .returning(\.id)
                                .fetchOne(db)
                        }
                        
                        try VideoChannel
                            .insert {
                                VideoChannel(
                                    id: "\(instance.host)-\(channelId)", name: channelDisplayName,
                                    instanceID: instance.id)
                            }
                            .execute(db)
                        
                        try Video
                            .upsert {
                                Video(
                                    id: videoId,
                                    channelID: "\(instance.host)-\(channelId)",
                                    instanceID: instance.id,
                                    name: videoName,
                                    publishDate: publishedAt,
                                    thumbnailID: thumbnailId
                                )
                            }
                            .execute(db)
                    }
                }
            }
        }
        
        return
    }
    
    var body: some View {
        @Bindable var appState = appState
        
        NavigationStack(path: $appState.navigationPath) {
            ZStack {
                if loading {
                    ProgressView()
                } else if feed.isEmpty {
                    ContentUnavailableView {
                        Label("Your Feed is empty", systemImage: "video")
                    } description: {
                        Button("Add an Instance to get their latest videos") {
                            
                        }
                    }
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(feed, id: \.self) { row in
                                VideoCard(row: row)
                                    .onTapGesture {
                                        //                                        guard let videoId = pair.video.uuid?.uuidString else {
                                        //                                            print("Couldnt get video id")
                                        //                                            return
                                        //                                        }
                                        //                                        appState.navigateTo(.videoDetail(host: pair.host, videoId: videoId))
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Explore")
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .videoDetail(host: let host, videoId: let videoId):
                    VideoDetails(host: host, videoId: videoId)
                default:
                    Text("View not implemented")
                }
                
            }
            .task {
                await withErrorReporting {
                    try await appState.addInstance(scheme: "https", host: "peertube.wtf")
                    try await appState.addInstance(scheme: "https", host: "peertube.wtf")
                }
                
                do {
                    try await getVideoFeed()
                } catch {
                    print("Error getting video feed")
                    print(error)
                }
            }
            .refreshable {
                loading = true
                do {
                    try await getVideoFeed()
                    loading = false
                    print("Finished loading")
                } catch {
                    print("Error getting videos")
                    print(error)
                    loading = false
                }
            }
        }
    }
}

#Preview {
    //    Explore()
    //        .environment(AppState.example)
}
