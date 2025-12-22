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
    let videoId: String
    
    @State var videoDetails: TubeSDK.VideoDetails?
    
    @State var hasLiked = false
    @State var hasDisliked = false
    
    var body: some View {
        ZStack {
            if let videoDetails = videoDetails {
                VStack {
                    if let streamingPlaylists = videoDetails.streamingPlaylists,
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
                            Text(videoDetails.name ?? "Unknown Video Title")
                                .fontWeight(.bold)
                            
                            if let views = videoDetails.views {
                                Text("^[\(views) View](inflect: true)")
                                    .font(.caption)
                            }
                            if let likes = videoDetails.likes,
                               let dislikes = videoDetails.dislikes{
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
                            if let commentCount = videoDetails.comments {
                                Text("^[\(commentCount) Comments](inflect: true)")
                                    .fontWeight(.bold)
                            }
                        }
                        Spacer()
                    }
                    .padding()
                    
                    .containerRelativeFrame(.horizontal)
                }
            }
            else {
                ProgressView()
            }
        }
        .navigationTitle(videoDetails?.name ?? "Unknown Video")
        .onAppear {
            if (videoDetails != nil) {return}
            Task {
                videoDetails = try await appState.client.getVideo(host: host, id: videoId)
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
