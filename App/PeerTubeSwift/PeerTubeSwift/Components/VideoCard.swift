//
//  VideoCard.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import Dependencies
import SQLiteData
import SwiftUI
import TubeSDK

struct VideoCard: View {
    let row: VideoRow?
    let video: TubeSDK.Video?
    let channelName: String?
    let channelAvatarUrl: String?
    let instanceHost: String?
    let instanceAvatarUrl: String?
    let client: TubeSDKClient?
    let onVideoTap: () -> Void
    let openChannel: () -> Void

    @FetchOne var cachedThumbnail: PeertubeImage?
    @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator
    @Dependency(\.defaultDatabase) var database

    init(
        row: VideoRow,
        onVideoTap: @escaping () -> Void,
        openChannel: @escaping () -> Void
    ) {
        self.row = row
        video = nil
        channelName = nil
        channelAvatarUrl = nil
        instanceHost = nil
        instanceAvatarUrl = nil
        client = nil
        self.onVideoTap = onVideoTap
        self.openChannel = openChannel

        if let thumbnail = row.video.thumbnailUrl {
            _cachedThumbnail = FetchOne(PeertubeImage.where { $0.id == thumbnail })
        } else {
            _cachedThumbnail = FetchOne(PeertubeImage.none)
        }
    }

    init(
        video: TubeSDK.Video,
        channelName: String,
        channelAvatarUrl: String?,
        instanceHost: String,
        instanceAvatarUrl: String?,
        client: TubeSDKClient?,
        onVideoTap: @escaping () -> Void,
        openChannel: @escaping () -> Void
    ) {
        row = nil
        self.video = video
        self.channelName = channelName
        self.channelAvatarUrl = channelAvatarUrl
        self.instanceHost = instanceHost
        self.instanceAvatarUrl = instanceAvatarUrl
        self.client = client
        self.onVideoTap = onVideoTap
        self.openChannel = openChannel

        // Use bestThumbnailUrl for proper thumbnail URL construction
        let thumbnailUrl = client.flatMap { video.bestThumbnailUrl(client: $0, size: .medium) }
        _cachedThumbnail = FetchOne(PeertubeImage.where { $0.id == thumbnailUrl })
    }

    let formatter = RelativeDateTimeFormatter()

    private var videoName: String {
        row?.video.name ?? video?.name ?? "Unknown"
    }

    private var videoThumbnailUrl: String? {
        if let url = row?.video.thumbnailUrl {
            return url
        }
        // Use bestThumbnailUrl for highest resolution available
        if let video = video, let client = client {
            return video.bestThumbnailUrl(client: client, size: .medium)
        }
        return nil
    }

    private var videoDuration: Int? {
        row?.video.duration ?? video?.duration
    }

    private var videoCurrentTime: Int? {
        row?.video.currentTime ?? video?.userHistory?.currentTime
    }

    private var videoPublishDate: Date? {
        row?.video.publishDate ?? video?.publishedAt
    }

    private var channelDisplayName: String {
        row?.channel?.name ?? channelName ?? "unknown"
    }

    private var channelDisplayAvatarUrl: String? {
        row?.channel?.avatarUrl ?? channelAvatarUrl
    }

    private var instanceDisplayHost: String {
        row?.instance?.host ?? instanceHost ?? ""
    }

    private var instanceDisplayAvatarUrl: String? {
        row?.instance?.avatarUrl ?? instanceAvatarUrl
    }

    var body: some View {
        VStack {
            if let thumbnailUrl = videoThumbnailUrl,
               let url = URL(string: thumbnailUrl)
            {
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
                            try? await peertubeOrchestrator.cacheImageIfNeeded(thumbnailUrl, database)
                        }
                    }

                    VStack(alignment: .leading) {
                        if !instanceDisplayHost.isEmpty {
                            InstanceIndicator(instanceName: instanceDisplayHost, instanceImage: instanceDisplayAvatarUrl)
                                .padding(8)
                        }

                        Spacer()

                        HStack {
                            Spacer()
                            if let durationInt = videoDuration {
                                Text(Duration.seconds(durationInt).formatted())
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(.thinMaterial, in: RoundedRectangle(cornerRadius: 4))
                                    .padding(8)
                            }
                        }
                    }

                    if let duration = videoDuration, let currentTime = videoCurrentTime, duration > 0, currentTime > 0 {
                        VStack {
                            Spacer()
                            GeometryReader { geometry in
                                Rectangle()
                                    .fill(Color.red)
                                    .frame(width: geometry.size.width * CGFloat(min(Double(currentTime) / Double(duration), 1.0)))
                            }
                            .frame(height: 4)
                        }
                        .clipShape(.rect(cornerRadius: 8))
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
            HStack(alignment: .top) {
                AvatarView(url: channelDisplayAvatarUrl, name: channelDisplayName)
                    .onTapGesture {
                        openChannel()
                    }
                VStack(alignment: .leading) {
                    Text(videoName)
                        .fontWeight(.bold)
                    HStack {
                        Text(channelDisplayName)
                            .font(.caption)

                        Text("·")
                        if let publishDate = videoPublishDate {
                            Text(formatter.localizedString(for: publishDate, relativeTo: Date.now))
                                .font(.caption)
                        }
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
    // VideoCard(host: "example.com", video: VideoMockData)
    //        .environment(AppState())
}
