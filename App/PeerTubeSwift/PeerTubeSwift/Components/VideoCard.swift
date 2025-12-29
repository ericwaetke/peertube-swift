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
    let row: VideoRow
    let onVideoTap: () -> Void
    let openChannel: () -> Void
    
    init(
        row: VideoRow,
        onVideoTap: @escaping () -> Void,
        openChannel: @escaping () -> Void
    ) {
        self.row = row
        self.onVideoTap = onVideoTap
        self.openChannel = openChannel
    }
    
//    @FetchOne
//    var channel: VideoChannel?
//    
//    @FetchOne(PeertubeImage.where { $0.id == video.thumbnailID }) var thumbnail: PeertubeImage?
    
    let formatter = RelativeDateTimeFormatter()
    
    var body: some View {
        VStack {
            if let thumbnail = row.video.thumbnailUrl,
                let url = URL(string: thumbnail) {
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
                        if let instanceName = row.instance?.host {
                            InstanceIndicator(instanceName: instanceName, instanceImage: nil)
                            .padding(8)
                        }
                        
                        Spacer()
                        
                        HStack {
                            Spacer()
                            if let durationInt = row.video.duration {
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
                if let avatar = row.channel?.avatarUrl,
                   let url = URL(string: avatar) {
                    AsyncImage(url: url) { image in
                        image.resizable()
                    } placeholder: {
                        Color.secondary
                    }
                    .frame(width: 48, height: 48)
                    .clipShape(.circle)
                    .onTapGesture {
                        openChannel()
                    }
                } else {
                    Color.secondary
                        .frame(width: 48, height: 48)
                        .clipShape(.circle)
                }
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
        .onTapGesture {
            onVideoTap()
        }
    }
}

#Preview {
//    VideoCard(host: "example.com", video: VideoMockData)
//        .environment(AppState())
}
