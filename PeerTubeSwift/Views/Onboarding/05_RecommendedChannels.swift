//
//  05_RecommendedChannels.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 21.09.26.
//

import ComposableArchitecture
import Dependencies
import FontKit
import PeerSeekSDK
import SwiftUI
import TubeSDK

@Reducer
struct OnboardingRecommendedChannelsFeature {
  @ObservableState
  struct State: Equatable {
    var channels: IdentifiedArrayOf<ChannelPreviewFeature.State> = []
    @Shared(.appStorage("interestedCategories")) var selectedCategories: Set<PeerSeekSDK.Category> =
      []

    var loading = false
  }

  enum Action {
    case loadChannelRecommendations
    case saveChannelRecommendations(Set<RecommendedChannel>)
    case channels(IdentifiedActionOf<ChannelPreviewFeature>)
  }

  @Dependency(\.channelRecommendations) var channelRecommendations

  /// PeerSeek stores languages as ISO codes (e.g. "de"); show a readable name.
  private static func languageName(for code: String) -> String? {
    guard !code.isEmpty else { return nil }
    return Locale.current.localizedString(forLanguageCode: code) ?? code
  }

  private static func rowState(for recommendation: RecommendedChannel)
    -> ChannelPreviewFeature.State
  {
    ChannelPreviewFeature.State(
      host: recommendation.instance,
      notificationBell: NotificationBellFeature.State(channelId: recommendation.id),
      videoChannel: TubeSDK.VideoChannel(
        name: recommendation.channel_id,
        avatars: recommendation.avatarUrl.map { [ActorImage(fileUrl: $0)] },
        host: recommendation.instance,
        displayName: recommendation.name
      ),
      instance: Instance(host: recommendation.instance, scheme: "https"),
      variant: .prominent,
      language: languageName(for: recommendation.primary_language),
      primaryCategory: recommendation.primaryCategory,
      channelID: recommendation.id
    )
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .loadChannelRecommendations:
        state.loading = true
        print(state.selectedCategories)
        return .run { [selectedCategories = state.selectedCategories] send in
          do {
            let recommendations = try await channelRecommendations.getChannelRecommendations(
              selectedCategories
            )
            await send(.saveChannelRecommendations(recommendations))
          } catch {
            // Leave the current list untouched if recommendations can't load.
            print("error loading channels")
          }
        }
      case .saveChannelRecommendations(let recommendations):
        state.loading = false
        state.channels = IdentifiedArrayOf(
          uniqueElements:
            recommendations
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
            .map(Self.rowState(for:))
        )
        return .none
      case .channels:
        return .none
      }
    }
    .forEach(\.channels, action: \.channels) {
      ChannelPreviewFeature()
    }
  }
}

struct OnboardingRecommendedChannelsView: View {
  let store: StoreOf<OnboardingRecommendedChannelsFeature>

  var body: some View {
    ScrollView {
      if store.loading {
        ProgressView()
      }
      LazyVStack {
        ForEach(store.scope(state: \.channels, action: \.channels)) { row in
          ChannelPreviewView(store: row)
            .task(id: row.channelID) {
              row.send(.loadAvatarIfNeeded)
            }
        }
      }
    }
    .padding()
  }
}

#Preview {
  OnboardingRecommendedChannelsView(
    store: Store(
      initialState: OnboardingRecommendedChannelsFeature.State(
        selectedCategories: [PeerSeekSDK.Category.activism]
      )
    ) {
      OnboardingRecommendedChannelsFeature()
    }
  )
}
