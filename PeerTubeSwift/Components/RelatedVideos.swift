//
//  RelatedVideos.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 06.10.26.
//

import ComposableArchitecture
import Dependencies
import FontKit
import PeerSeekSDK
import SQLiteData
import SwiftUI

@Reducer
struct RelatedVideosFeature {
  @ObservableState
  struct State: Equatable {
    var cards: IdentifiedArrayOf<VideoCardFeature.State> = []
  }

  enum Action {
    case loadVideos([VideoRecommendation])
    case cards(IdentifiedActionOf<VideoCardFeature>)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .loadVideos(let videos):
        state.cards = IdentifiedArrayOf(
          uniqueElements: videos.map { video in
            let dateFormatter = ISO8601DateFormatter()
            let date = dateFormatter.date(from: video.publishedAt)
            return VideoCardFeature.State(
              variant: .medium,
              id: video.id,
              videoUUID: video.id,
              videoName: video.title,
              videoThumbnailUrl: video.thumbnailUrl,
              videoDuration: video.durationSeconds,
              videoCurrentTime: 0,
              videoPublishDate: date,
              videoViews: video.views,
              channelDisplayName: video.channel,
              channelAvatarUrl: nil,
              channelId: "\(video.channelHandle)@\(video.instance)",
              channelDescription: nil,
              instanceDisplayHost: video.instance,
              instanceDisplayAvatarUrl: nil,
              userBadge: UserBadgeFeature.State(
                variant: .medium,
                avatarUrl: nil,
                channelDisplayName: video.channel,
                instanceDisplayName: video.instance,
                instanceIconUrl: nil
              ),
              videoRow: nil
            )
          })
        return .none
      case .cards(_):
        return .none
      }
    }
    .forEach(\.cards, action: \.cards) {
      VideoCardFeature()
    }
  }
}

struct RelatedVideosView: View {
  @Bindable var store: StoreOf<RelatedVideosFeature>

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      Text("Related Videos")
        .font(CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote))
        .textCase(.uppercase)
        .foregroundStyle(Color.Label.secondary)
        .padding(.horizontal, 16)

      ScrollView(.horizontal) {
        HStack(alignment: .top) {
          ForEach(store.scope(state: \.cards, action: \.cards)) { cardStore in
            VideoCardView(store: cardStore)
              .frame(width: 280)
          }
        }
      }
      .contentMargins(16)
    }
  }
}

#Preview {
  RelatedVideosView(
    store: Store(
      initialState: RelatedVideosFeature.State()
    ) {
      RelatedVideosFeature()
    })
}
