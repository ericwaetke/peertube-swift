//
//  VideoChannelView.swift
//  PeerTubeSwift
//

import ComposableArchitecture
import Dependencies
import FontKit
import SQLiteData
import SwiftUI
import TubeSDK

struct VideoChannelView: View {
  let store: StoreOf<VideoChannelFeature>

  var body: some View {
    ScrollView {
      VStack(alignment: .leading, spacing: 0) {
        ChannelHeader(store: store)
        ChannelVideoList(store: store)
      }
      .toolbar {
        if store.state.titleVisible {
          ToolbarItem(placement: .title) {
            UserBadge(
              store: Store(
                initialState: UserBadgeFeature.State(
                  variant: .medium,
                  avatarUrl: store.videoChannel?.avatarUrl,
                  channelDisplayName: store.videoChannel?.name ?? store.channelName ?? "Channel",
                  instanceDisplayName: store.host,
                  instanceIconUrl: store.instance?.avatarUrl)
              ) {
                UserBadgeFeature()
              }
            )
            .transition(.blurReplace)
          }
        }
        if #available(iOS 26.0, *) {
          ToolbarItem(placement: .primaryAction) {
            ShareLink(item: URL(string: "https://woven.design")!)
              .buttonStyle(RiverButtonToolbar(type: .gray))
          }
          .sharedBackgroundVisibility(.hidden)
        } else {
          ToolbarItem(placement: .primaryAction) {
            ShareLink(item: URL(string: "https://woven.design")!)
              .buttonStyle(RiverButtonToolbar(type: .gray))
          }
        }
      }
      .animation(.bouncy(duration: 0.25), value: store.state.titleVisible)
      .toolbarTitleDisplayMode(.inline)
    }
  }
}

// MARK: - Header

private struct ChannelHeader: View {
  let store: StoreOf<VideoChannelFeature>

  var body: some View {
    VStack(alignment: .leading, spacing: 12) {
      ChannelBanner(urlString: store.videoChannel?.bannerUrl)

      ChannelPreviewView(
        store: store.scope(state: \.channelPreview, action: \.channelPreview)
      )

      if let description = store.videoDetails?.channel?.description
        ?? store.videoChannel?.description,
        !description.isEmpty
      {
        Text(description)
          .font(.subheadline)
          .foregroundStyle(.secondary)
          .lineLimit(3)
      }

      ChannelStats(followerCount: store.followerCount, videoCount: store.videoCount)
    }
    .padding()
    .background(Color(uiColor: .systemBackground))
    .overlay(Divider(), alignment: .bottom)
    .onGeometryChange(for: Bool.self) {
      let height = $0.size.height
      let offset = $0.frame(in: .global).minY
      return -offset > height / 2
    } action: { newValue in
      store.send(.setTitleVisible(newValue))
    }
  }
}

private struct ChannelBanner: View {
  let urlString: String?

  var body: some View {
    if let urlString, let url = URL(string: urlString) {
      AsyncImage(url: url) { image in
        image.resizable().aspectRatio(contentMode: .fill)
      } placeholder: {
        Color.gray
      }
      .frame(maxWidth: .infinity, minHeight: 96, maxHeight: 96)
      .clipped()
      .clipShape(.rect(cornerRadius: 12))
    }
  }
}

private struct ChannelStats: View {
  let followerCount: Int?
  let videoCount: Int?

  var body: some View {
    HStack {
      Spacer()
      StatItem(
        value: followerCount?.formatted(.number.notation(.compactName)) ?? "0",
        label: "Subscribers"
      )
      Spacer()
      Divider()
      Spacer()
      StatItem(
        value: videoCount?.formatted(.number.notation(.compactName)) ?? "0",
        label: "Videos"
      )
      Spacer()
    }
    .padding(12)
    .frame(maxWidth: .infinity)
    .background(Color(uiColor: UIColor.secondarySystemBackground))
    .clipShape(.rect(cornerRadius: 26))
  }
}

private struct StatItem: View {
  let value: String
  let label: String

  var body: some View {
    VStack(spacing: 4) {
      Text(value)
        .font(CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 17, relativeTo: .headline))
        .foregroundStyle(Color.Label.primary)
      Text(label)
        .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 11, relativeTo: .caption2))
        .foregroundStyle(Color.Label.secondary)
    }
  }
}

// MARK: - Video list

private struct ChannelVideoList: View {
  let store: StoreOf<VideoChannelFeature>

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Videos")
        .font(.headline)
        .padding()
        .padding(.bottom, 0)

      if store.isLoadingVideos && store.videoCards.isEmpty {
        ProgressView()
          .frame(maxWidth: .infinity, minHeight: 200)
      } else if store.videoCards.isEmpty && store.hasLoadedAtLeastOnce {
        ContentUnavailableView {
          Label("No videos", systemImage: "video")
        } description: {
          Text("This channel doesn't have any videos yet")
        }
        .padding()
      } else {
        LazyVStack(spacing: 16) {
          ForEach(
            store.scope(state: \.videoCards, action: \.videoCards)
          ) { cardStore in
            VideoCardView(store: cardStore)
              .onAppear {
                store.send(.loadMoreVideosIfNeeded(currentItemId: cardStore.videoUUID))
              }
          }

          if store.isLoadingVideos && !store.videoCards.isEmpty {
            ProgressView()
              .padding()
          }
        }
      }
      Spacer()
    }
    .background(Color(uiColor: .secondarySystemBackground))
  }
}

#Preview {
  let _ = prepareDependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }

  return NavigationStack {
    VideoChannelView(
      store: Store(
        initialState: VideoChannelFeature.State(
          host: "peertube.cpy.re",
          videoDetails: TubeSDK.VideoDetails(
            channel: TubeSDK.VideoChannel(
              id: 1,
              name: "chocopie",
              host: "peertube.cpy.re",
              displayName: "Choco Pie Channel",
              description:
                "This is a test channel description that shows what the channel is about."
            )
          )
        )
      ) {
        VideoChannelFeature()
      }
    )
  }
}
