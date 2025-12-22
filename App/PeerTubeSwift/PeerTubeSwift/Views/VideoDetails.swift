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
    
    let formatter = RelativeDateTimeFormatter()
    
    @State private var showDescription: Bool = true
    @State private var showComments: Bool = true
    
    var body: some View {
        ZStack {
            if let videoDetails = videoDetails {
                ScrollView {
                    VStack (spacing: 16) {
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
    //                            .padding(24)
                        }
                        VStack (alignment: .leading, spacing: 16) {
                            VStack (alignment: .leading, spacing: 8) {
                                Text(videoDetails.name ?? "Unknown Video Title")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                
                                HStack {
                                    if let views = videoDetails.views {
                                        Text("^[\(views) View](inflect: true)")
                                            .font(.callout)
                                    }
                                    
                                    if let publishedAt = videoDetails.publishedAt {
                                        Text("·")
                                        Text(formatter.localizedString(for: publishedAt, relativeTo: Date.now))
                                            .font(.callout)
                                    }
                                }
                            }
                            if let likes = videoDetails.likes,
                               let dislikes = videoDetails.dislikes {
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
                                    .tint(hasDisliked ? .blue : .primary)
                                    .apply {
                                        if #available(iOS 26.0, *) {
                                            $0.buttonStyle(.glass)
                                        } else {
                                            $0.buttonStyle(.automatic)
                                        }
                                    }
                                    
                                    Button {
                                        
                                    } label: {
                                        HStack {
                                            Image(systemName: "square.and.arrow.up")
                                            Text("Share")
                                        }
                                    }
                                    .tint(hasDisliked ? .blue : .primary)
                                    .apply {
                                        if #available(iOS 26.0, *) {
                                            $0.buttonStyle(.glass)
                                        } else {
                                            $0.buttonStyle(.automatic)
                                        }
                                    }
                                }
                            }
                            
                            // Channel Subscription Bar
                            HStack {
                                ZStack (alignment: .bottomLeading) {
                                    // Default Channel Stuff
                                    HStack (alignment: .top) {
                                        if let avatars = videoDetails.channel?.avatars,
                                           let avatar = avatars.first,
                                           let fileUrl = avatar.fileUrl,
                                           let url = URL(string: fileUrl) {
                                            AsyncImage(url: url) { image in
                                                image.resizable()
                                            } placeholder: {
                                                Color.secondary
                                            }
                                            .frame(width: 48, height: 48)
                                            .clipShape(.circle)
                                        } else {
                                            Color.secondary
                                                .frame(width: 48, height: 48)
                                                .clipShape(.circle)
                                        }
                                        Text("\(videoDetails.channel?.displayName ?? "Unknown Channel")")
                                            .lineLimit(1)
                                    }
                                    // Instance Indicator
                                    if let instanceName = videoDetails.channel?.host {
                                        InstanceIndicator(instanceName: instanceName, instanceImage: nil)
                                            .padding(.leading, 36)
                                    }
                                }
                                Spacer()
                                Button("Subscribe") {
                                    
                                }
                                .apply {
                                    if #available(iOS 26.0, *) {
                                        $0.buttonStyle(.glass)
                                    } else {
                                        $0.buttonStyle(.automatic)
                                    }
                                }
                            }
                            
                            
                            
                            // Description
                            
                            if let description = videoDetails.description {
                                Divider()
                                DisclosureGroup(isExpanded: $showDescription) {
                                    // TODO: don’t do this, ugh … can’t get it to work differently right now though
                                    HStack {
                                        Text(description)
                                        Spacer()
                                    }
                                } label: {
                                    Text("Description")
                                        .foregroundStyle(.primary)
                                        .fontWeight(.bold)
                                    
                                }
                            }
                            
                            Divider()
                            
                            VStack (alignment: .leading) {
                                if let commentCount = videoDetails.comments {
                                    DisclosureGroup(isExpanded: $showComments) {
                                    } label: {
                                        HStack {
                                            Text("Comments")
                                                .fontWeight(.bold)
                                            Text(commentCount.formatted())
                                                .opacity(0.5)
                                        }
                                    }
                                    
                                }
                            }
                            Spacer()
                        }
                        .padding()
                        
                        .containerRelativeFrame(.horizontal)
                    }
                }
            }
            else {
                ProgressView()
            }
        }
//        .navigationTitle(videoDetails?.name ?? "Unknown Video")
        .onAppear {
//            if (videoDetails != nil) {return}
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


#Preview {
    NavigationStack {
        VideoDetails(host: "peertube.wtf", videoId: "18QZB6GTN1DRd1LtkeQm22")
            .environment(AppState())
    }
}
