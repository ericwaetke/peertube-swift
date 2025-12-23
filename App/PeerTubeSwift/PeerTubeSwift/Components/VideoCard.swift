//
//  VideoCard.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SwiftUI
import TubeSDK

struct VideoCard: View {
    @Environment(AppState.self) private var appState: AppState
    let host: String
    let video: TubeSDK.Video
    
    let formatter = RelativeDateTimeFormatter()
    
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
                    
                    VStack(alignment: .leading) {
                        if let instanceName = video.channel?.host {
                            InstanceIndicator(instanceName: instanceName, instanceImage: nil)
                            .padding(8)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            if let durationInt = video.duration {
                                Text(Duration.seconds(durationInt).formatted())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 4))
//                                    .clipShape(.rect(cornerRadius: 4))
                                    .padding(8)
                            }
                        }
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
                    Color.secondary
                        .frame(width: 48, height: 48)
                        .clipShape(.circle)
                }
                VStack (alignment: .leading) {
                    Text(video.name ?? "Unknown Video Title")
                        .fontWeight(.bold)
                    HStack {
                        Text("\(video.channel?.displayName ?? "Unknown Channel")")
                            .font(.caption)
                        if let publishedAt = video.publishedAt {
                            Text("·")
                            Text(formatter.localizedString(for: publishedAt, relativeTo: Date.now))
                                .font(.caption)
                        }
                    }
                }
                Spacer()
                Image(systemName: "ellipsis.circle")
            }
        }
    }
}

#Preview {
//    VideoCard(host: "example.com", video: VideoMockData)
//        .environment(AppState())
}
