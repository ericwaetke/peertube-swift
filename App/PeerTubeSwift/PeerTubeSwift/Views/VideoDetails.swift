//
//  VideoDetails.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SwiftUI
import peertube_swift_sdk

struct VideoDetails: View {
    @Environment(AppState.self) private var appState: AppState
    let video: Video
    
    @State var videoDetails: peertube_swift_sdk.VideoDetails?
    
    var body: some View {
        VStack {
            if let videoDetails = videoDetails,
               let streamingPlaylists = videoDetails.streamingPlaylists,
               let video = streamingPlaylists.first,
//                           let qualities = video.files,
//                           let fullHD = qualities.first,
               let urlString = video.playlistUrl,
               let url = URL(string: urlString){
                VideoPlayerView(videoURL: url)
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 100,
                        maxHeight: .infinity
                    )
                    .aspectRatio(16 / 9, contentMode: .fit)
            }
            Text(video.name ?? "Unknown Video Title")
                .fontWeight(.bold)
                .onAppear {
                    print(video.name)
                }
        }
        .onAppear {
            videoDetails = nil
            Task {
                if let uuid = video.uuid {
                    videoDetails = try await appState.client.getVideo(id: uuid.uuidString)
                }
            }
        }
    }
}
