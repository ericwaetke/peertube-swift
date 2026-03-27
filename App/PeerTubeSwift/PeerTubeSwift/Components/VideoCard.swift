//
//  VideoCard.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SQLiteData
import SwiftUI
import TubeSDK
import Dependencies

struct VideoCard: View {
    let row: VideoRow
    let onVideoTap: () -> Void
    let openChannel: () -> Void
    
    @FetchOne var cachedThumbnail: PeertubeImage?
    @FetchOne var cachedAvatar: PeertubeImage?
    @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator
    @Dependency(\.defaultDatabase) var database

    init(
        row: VideoRow,
        onVideoTap: @escaping () -> Void,
        openChannel: @escaping () -> Void
    ) {
        self.row = row
        self.onVideoTap = onVideoTap
        self.openChannel = openChannel
        
        if let thumbnail = row.video.thumbnailUrl {
            self._cachedThumbnail = FetchOne(PeertubeImage.where { $0.id == thumbnail })
        } else {
            self._cachedThumbnail = FetchOne(PeertubeImage.none)
        }
        
        if let avatar = row.channel?.avatarUrl {
            self._cachedAvatar = FetchOne(PeertubeImage.where { $0.id == avatar })
        } else {
            self._cachedAvatar = FetchOne(PeertubeImage.none)
        }
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
                    if let cachedData = cachedThumbnail?.data, let uiImage = UIImage(data: cachedData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(
                                minWidth: 0,
                                maxWidth: .infinity,
                                minHeight: 100,
                                maxHeight: .infinity
                            )
                            .aspectRatio(16 / 9, contentMode: .fit)
                            .clipShape(.rect(cornerRadius: 8))
                    } else {
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
                        .task {
                            try? await peertubeOrchestrator.cacheImageIfNeeded(thumbnail, database)
                        }
                    }
                    
                    VStack(alignment: .leading) {
                        if let instanceName = row.instance?.host {
                            InstanceIndicator(instanceName: instanceName, instanceImage: row.instance?.avatarUrl)
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
                    
                    if let duration = row.video.duration, let currentTime = row.video.currentTime, duration > 0, currentTime > 0 {
                        VStack {
                            Spacer()
                            GeometryReader { geometry in
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: geometry.size.width * CGFloat(min(Double(currentTime) / Double(duration), 1.0)))
                            }
                            .frame(height: 4)
                        }
                        .clipShape(.rect(cornerRadius: 8)) // Ensure progress bar follows corner radius at bottom
                    }
                }
                .aspectRatio(16 / 9, contentMode: .fit)
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
                    if let cachedData = cachedAvatar?.data, let uiImage = UIImage(data: cachedData) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .frame(width: 48, height: 48)
                            .clipShape(.circle)
                            .onTapGesture {
                                openChannel()
                            }
                    } else {
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
                        .task {
                            try? await peertubeOrchestrator.cacheImageIfNeeded(avatar, database)
                        }
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
