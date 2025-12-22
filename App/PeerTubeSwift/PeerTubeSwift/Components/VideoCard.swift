//
//  VideoCard.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SwiftUI
import peertube_swift_sdk

struct VideoCard: View {
    @Environment(AppState.self) private var appState: AppState
    let host: String
    let video: Video
    
    var body: some View {
        VStack {
            if let path = video.thumbnailPath,
               let url = try? appState.client.getImageUrl(host: host, path: path) {
                ZStack(alignment: .topLeading) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.secondary
                    }
                    .frame(
                        minWidth: 0,
                        maxWidth: .infinity,
                        minHeight: 100,
                        maxHeight: .infinity
                    )
                    .aspectRatio(16 / 9, contentMode: .fit)
                    .clipShape(.rect(cornerRadius: 8))
                    
                    if let instanceName = video.channel?.host {
                        HStack (spacing: 8) {
                            // Insert Instance Icon Later
                            Image(systemName: "laser.burst")
                                .frame(width: 12, height: 12)
                                .foregroundStyle(.black)
                                .frame(width: 36, height: 36)
                                .background(Color(red: 0.74, green: 0.9, blue: 1))
                                .clipShape(.rect(cornerRadius: 8))
                            
                            Text(instanceName)
                                .padding(.horizontal, 8)
                                .foregroundStyle(.black)
                                .background(Color(red: 0.74, green: 0.9, blue: 1))
                                .clipShape(.rect(cornerRadius: 4))
                        }
                        .padding(8)
                    }
                }
            } else {
                Text("Couldn’t load thumbnail")
            }
            HStack (alignment: .top) {
                if let avatars = video.channel?.avatars,
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
                    Text("Couldn’t load Avatar")
                }
                VStack (alignment: .leading) {
                    Text(video.name ?? "Unknown Video Title")
                        .fontWeight(.bold)
                    Text(video.channel?.displayName ?? "Unknown Channel")
                        .font(.caption)
                }
                Spacer()
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

#Preview {
//    var state = AppState()
//    let videos = try await state.client.getVideos()
//    if let video = videos.first{
//        VideoCard(video: video)
//    }
}
