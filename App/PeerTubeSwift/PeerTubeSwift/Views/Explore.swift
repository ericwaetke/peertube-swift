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
    @FetchAll var feed: [Video]
    
    @Dependency(\.defaultDatabase) var database
    
    func getVideoFeed() async throws -> Void {
        let clients = instances.compactMap { appState.instances[$0.host] }
        
        // Get Videos from Peertube
        for client in clients {
            let videos = try await client.getVideos()
            
            // Add Videos to SQLite
            await withErrorReporting {
                for peertubeVideo in videos {
                    guard let channel = peertubeVideo.channel,
                          let videoId = peertubeVideo.uuid,
                          let videoName = peertubeVideo.name,
                          let publishedAt = peertubeVideo.publishedAt,
                          let channelId = channel.id,
                          let channelDisplayName = channel.displayName else {
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
                    
                    try await database.write { db in
                        try VideoChannel
                            .insert { VideoChannel(id: "\(instance.host)-\(channelId)",name: channelDisplayName, instanceID: instance.id) }
                            .execute(db)
                        
                        try Video
                            .insert {
                                Video(
                                    id: videoId,
                                    channelID: "\(instance.host)-\(channelId)",
                                    instanceID: instance.id,
                                    name: videoName,
                                    publishDate: publishedAt
                                )
                            }
                            .execute(db)
                    }
                    
                    if let thumbnailPath = peertubeVideo.thumbnailPath,
                       let thumbnailURL = try? client.getImageUrl(path: thumbnailPath){
                        
                        try await database.write { db in
                            try PeertubeImage
                                .insert {
                                    PeertubeImage.Draft(instanceID: instance.id, url: thumbnailURL.absoluteString)
                                }
                                .execute(db)
                        }
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
                            ForEach(feed, id: \.self) { video in
                                VideoCard(host: "peertube.wtf", video: video)
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
                case let .videoDetail(host: host, videoId: videoId):
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
