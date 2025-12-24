//
//  VideoCard.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SQLiteData
import SwiftUI
import TubeSDK

struct VideoCard: View {
    let row: Explore.Row
    
//    @FetchOne
//    var channel: VideoChannel?
//    
//    @FetchOne(PeertubeImage.where { $0.id == video.thumbnailID }) var thumbnail: PeertubeImage?
    
    let formatter = RelativeDateTimeFormatter()
    
    var body: some View {
        VStack {
            if let thumbnail = row.thumbnail,
                let url = URL(string: thumbnail.url) {
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
                    
//                    VStack(alignment: .leading) {
//                        if let instanceName = video.channel?.host {
//                            InstanceIndicator(instanceName: instanceName, instanceImage: nil)
//                            .padding(8)
//                        }
//                        
//                        Spacer()
//                        
//                        HStack {
//                            Spacer()
//                            if let durationInt = video.duration {
//                                Text(Duration.seconds(durationInt).formatted())
//                                    .padding(.horizontal, 8)
//                                    .padding(.vertical, 4)
//                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 4))
////                                    .clipShape(.rect(cornerRadius: 4))
//                                    .padding(8)
//                            }
//                        }
//                    }
                }
            } else {
            Color.secondary
                .frame(
                    minWidth: 0,
                    maxWidth: .infinity,
                    minHeight: 100,
                    maxHeight: .infinity
                )
                .aspectRatio(16 / 9, contentMode: .fit)
                .clipShape(.rect(cornerRadius: 8))
            }
            HStack (alignment: .top) {
//                if let avatars = video.channel?.avatars,
//                   let avatar = avatars.first,
//                   let fileUrl = avatar.fileUrl,
//                   let url = URL(string: fileUrl) {
//                    AsyncImage(url: url) { image in
//                        image.resizable()
//                    } placeholder: {
//                        Color.secondary
//                    }
//                    .frame(width: 48, height: 48)
//                    .clipShape(.circle)
//                } else {
//                    Color.secondary
//                        .frame(width: 48, height: 48)
//                        .clipShape(.circle)
//                }
                VStack (alignment: .leading) {
                    Text(row.video.name)
                        .fontWeight(.bold)
                    HStack {
                        Text(row.channel?.name ?? "unknown channel")
                            .font(.caption)
                        
                            Text("·")
                        Text(formatter.localizedString(for: row.video.publishDate, relativeTo: Date.now))
                                .font(.caption)
                        
                    }
                }
                Spacer()
                Image(systemName: "ellipsis.circle")
            }
        }
        .task {
//            await withErrorReporting {
//                try await $channel.load(
//                    VideoChannel
//                        .where { $0.name == video.channelID }
//                )
//                .task
//            }
        }
    }
}

#Preview {
//    VideoCard(host: "example.com", video: VideoMockData)
//        .environment(AppState())
}
