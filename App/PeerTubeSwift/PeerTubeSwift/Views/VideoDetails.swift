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
    
    @State var hasLiked = false
    @State var hasDisliked = false
    
    var body: some View {
        VStack {
            if let videoDetails = videoDetails,
               let streamingPlaylists = videoDetails.streamingPlaylists,
               let video = streamingPlaylists.first,
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
                    .padding(24)
            }
            VStack (alignment: .leading) {
                VStack (alignment: .leading) {
                    Text(video.name ?? "Unknown Video Title")
                        .fontWeight(.bold)
                    
                    if let views = video.views {
                        Text("^[\(views) View](inflect: true)")
                            .font(.caption)
                    }
                    if let likes = video.likes,
                       let dislikes = video.dislikes{
                        HStack {
                            Button {
                                print("added like")
                                hasLiked = true
                                hasDisliked = false
                            } label: {
                                HStack {
                                    Image(systemName: "hand.thumbsup")
                                    Text(likes.formatted())
                                }
                            }
                            .tint(hasLiked ? .blue : .primary)
                            .apply {
                                if #available(iOS 26.0, *) {
                                    $0.buttonStyle(.glass)
                                } else {
                                    $0.buttonStyle(.automatic)
                                }
                            }
                            
                            
                            Button {
                                print("added dislike")
                                hasLiked = false
                                hasDisliked = true
                            } label: {
                                HStack {
                                    Image(systemName: "hand.thumbsdown")
                                    Text(dislikes.formatted())
                                }
                            }
                            .tint(hasLiked ? .blue : .primary)
                            .apply {
                                if #available(iOS 26.0, *) {
                                    $0.buttonStyle(.glass)
                                } else {
                                    $0.buttonStyle(.automatic)
                                }
                            }
                        }
                    }
                }
                .containerRelativeFrame(.horizontal)
                
                VStack {
                    if let commentCount = video.comments {
                        Text("^[\(commentCount) Comments](inflect: true)")
                            .fontWeight(.bold)
                    }
                }
                Spacer()
            }
            .padding()
            
            .containerRelativeFrame(.horizontal)
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


// Source - https://stackoverflow.com/a
// Posted by Mojtaba Hosseini
// Retrieved 2025-12-22, License - CC BY-SA 4.0

extension View {
    func apply<V: View>(@ViewBuilder _ block: (Self) -> V) -> V { block(self) }
}
