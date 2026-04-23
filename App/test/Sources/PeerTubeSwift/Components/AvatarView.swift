//
//  AvatarView.swift
//  PeerTubeSwift
//

import Dependencies
import SQLiteData
import SwiftUI

struct AvatarView: View {
    let url: String?
    let name: String
    let size: CGFloat

    @FetchOne var cachedAvatar: PeertubeImage?
    @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator
    @Dependency(\.defaultDatabase) var database

    init(url: String?, name: String, size: CGFloat = 48) {
        self.url = url
        self.name = name
        self.size = size

        if let avatarUrl = url {
            _cachedAvatar = FetchOne(PeertubeImage.where { $0.id.eq(avatarUrl) })
        } else {
            _cachedAvatar = FetchOne(PeertubeImage.none)
        }
    }

    var body: some View {
        if let avatarUrl = url, let imageUrl = URL(string: avatarUrl) {
            if let cachedData = cachedAvatar?.data, let uiImage = UIImage(data: cachedData) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: size, height: size)
                    .clipShape(Circle())
            } else {
                AsyncImage(url: imageUrl) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    fallbackView
                }
                .frame(width: size, height: size)
                .clipShape(Circle())
                .task {
                    try? await peertubeOrchestrator.cacheImageIfNeeded(avatarUrl, database)
                }
            }
        } else {
            fallbackView
        }
    }

    @ViewBuilder
    private var fallbackView: some View {
        ZStack {
            Color.fromHash(of: name)
            Text(name.initials)
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }
}
