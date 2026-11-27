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
  @Dependency(\.channelRecommendations) var channelRecommendations
  @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator

  @ObservableState
  struct State: Equatable {
    var cards: IdentifiedArrayOf<VideoCardFeature.State> = []

    var requestedAvatars: Set<String> = []
    var requestedInstances: Set<String> = []
  }

  enum Action {
    case loadVideos([VideoRecommendation])
    case cards(IdentifiedActionOf<VideoCardFeature>)

    case loadMetadataIfNeeded(id: String)
    case avatarLoaded(id: String, url: String?)
    case instanceLoaded(host: String, instance: Instance?)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .loadVideos(let videos):
        state.requestedAvatars.removeAll()
        state.requestedInstances.removeAll()
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
      case .loadMetadataIfNeeded(id: let cardId):
        guard let card = state.cards[id: cardId],
          let channelId = card.channelId
        else {
          return .none
        }

        let channelIdSplit = channelId.split(separator: "@", maxSplits: 1).map(String.init)
        let channelHandle = channelIdSplit.first
        let requestedHost = channelIdSplit.count > 1 ? channelIdSplit[1] : ""
        let host = requestedHost.isEmpty ? card.instanceDisplayHost : requestedHost

        var effects: [Effect<Action>] = []

        if let channelHandle, !channelHandle.isEmpty, !channelId.isEmpty,
          !state.requestedAvatars.contains(channelId)
        {
          state.requestedAvatars.insert(channelId)

          effects.append(
            .run { [cardId, channelHandle, host] send in
              let url = await channelRecommendations.loadAvatar(channelHandle, host)
              await send(.avatarLoaded(id: cardId, url: url))
            }
            .cancellable(id: "related-avatar-\(channelId)", cancelInFlight: true)
          )
        }

        if !host.isEmpty, !state.requestedInstances.contains(host) {
          state.requestedInstances.insert(host)

          effects.append(
            .run { [host] send in
              @Dependency(\.defaultDatabase) var database
              let instance = try? await peertubeOrchestrator.syncInstanceInfo(host, database)
              await send(.instanceLoaded(host: host, instance: instance))
            }
            .cancellable(id: "related-instance-\(host)", cancelInFlight: true)
          )
        }

        return effects.isEmpty ? .none : .merge(effects)

      case .avatarLoaded(id: let cardId, let url):
        guard let card = state.cards[id: cardId],
          let channelId = card.channelId,
          !channelId.isEmpty
        else {
          return .none
        }

        for index in state.cards.indices where state.cards[index].channelId == channelId {
          state.cards[index].channelAvatarUrl = url
          state.cards[index].userBadge.avatarUrl = url
        }

        return .none
      case .instanceLoaded(let host, let instance):
        for index in state.cards.indices where state.cards[index].instanceDisplayHost == host {
          state.cards[index].instanceDisplayAvatarUrl = instance?.avatarUrl
          state.cards[index].userBadge.instanceIconUrl = instance?.avatarUrl
        }

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
              .task(id: cardStore.id) {
                store.send(.loadMetadataIfNeeded(id: cardStore.id))
              }
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
