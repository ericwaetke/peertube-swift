//
//  VideoDetails.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SwiftUI
import TubeSDK

struct VideoDetails: View {
    @Environment(AppState.self) private var appState: AppState
    let host: String
    let video: Video
    
    @State var videoDetails: TubeSDK.VideoDetails?
    
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
            
            if let views = video.views {
                Text(views.formatted())
                    .font(.caption)
            }
            if let likes = video.likes,
               let dislikes = video.dislikes{
                HStack {
                    Button {
                        print("added like")
                    } label: {
                        HStack {
                            Image(systemName: "hand.thumbsup")
                            Text(likes.formatted())
                        }
                    }
                    
                    Button {
                        print("added dislike")
                    } label: {
                        HStack {
                            Image(systemName: "hand.thumbsdown")
                            Text(dislikes.formatted())
                        }
                    }
                }
            }
        }
        .navigationTitle(video.name ?? "Unknown Video")
        .onAppear {
            videoDetails = nil
            Task {
                if let uuid = video.uuid {
                    videoDetails = try await appState.client.getVideo(host: host, id: uuid.uuidString)
                }
            }
        }
    }
}
