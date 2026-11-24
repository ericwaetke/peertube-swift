//
//  FeedView.swift
//  PeerTubeSwift
//

import ComposableArchitecture
import SQLiteData
import SwiftUI

struct Feed: View {
  let store: StoreOf<FeedFeature>

  var body: some View {
    ScrollView {
      ZStack {
        if let errorMessage = store.errorMessage {
          FeedErrorView(message: errorMessage) {
            store.send(.pulledToRefresh)
          }
        } else if store.isLoadingVideos && store.videoCards.isEmpty {
          FeedLoadingView()
        } else if store.videoCards.isEmpty && store.hasLoadedAtLeastOnce {
          FeedEmptyView(
            hasInstances: !store.instances.isEmpty,
            onAddInstance: { store.send(.addInstanceButtonTapped) },
            onReload: { store.send(.pulledToRefresh) }
          )
        } else {
          FeedContent(store: store)
        }
      }
    }
    .task {
      await store.send(.initialScreenLoad).finish()
    }
    .refreshable {
      await store.send(.pulledToRefresh).finish()
    }
    .background(Color(uiColor: UIColor.systemGroupedBackground))
    .navigationTitle(store.feedType.navigationTitle)
  }
}

// MARK: - States

private struct FeedErrorView: View {
  let message: String
  let onRetry: () -> Void

  var body: some View {
    ContentUnavailableView {
      Label("Error loading feed", systemImage: "exclamationmark.triangle")
    } description: {
      VStack(spacing: 12) {
        Text(message)
        Button("Try Again", action: onRetry)
          .buttonStyle(.borderedProminent)
      }
    }
    .containerRelativeFrame([.horizontal, .vertical])
  }
}

private struct FeedLoadingView: View {
  var body: some View {
    ProgressView()
      .containerRelativeFrame([.horizontal, .vertical])
  }
}

private struct FeedEmptyView: View {
  let hasInstances: Bool
  let onAddInstance: () -> Void
  let onReload: () -> Void

  var body: some View {
    if hasInstances {
      ContentUnavailableView {
        Label("Your Feed is empty", systemImage: "video")
      } description: {
        VStack {
          Text("You have instances added, but they dont seem to have any videos right now")
          Button("Reload", action: onReload)
        }
      }
      .containerRelativeFrame([.horizontal, .vertical])
    } else {
      ContentUnavailableView {
        Label("Your Feed is empty", systemImage: "video")
      } description: {
        Button("Add an Instance to get their latest videos", action: onAddInstance)
      }
      .containerRelativeFrame([.horizontal, .vertical])
    }
  }
}

// MARK: - Content

private struct FeedContent: View {
  let store: StoreOf<FeedFeature>

  var body: some View {
    VStack(spacing: 0) {
      LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 350))], alignment: .leading, spacing: 0
      ) {
        ForEach(cards, id: \.element) { index, cardStore in
          if index == 3 {
            Spacer().frame(height: 16)
            ContinueWatching(
              store: store.scope(state: \.continueWatching, action: \.continueWatching))
            Spacer().frame(height: 16)
          }
          VideoCardView(store: cardStore)
        }
      }

      if store.hasMoreVideos && store.hasLoadedAtLeastOnce {
        FeedLoadMoreButton(isLoading: store.isLoadingMore) {
          store.send(.loadMoreVideos)
        }
      }
    }
  }

  private var cards: [(offset: Int, element: StoreOf<VideoCardFeature>)] {
    Array(Array(store.scope(state: \.videoCards, action: \.videoCards)).enumerated())
  }
}

private struct FeedLoadMoreButton: View {
  let isLoading: Bool
  let onLoadMore: () -> Void

  var body: some View {
    if isLoading {
      ProgressView("Loading more...")
        .padding()
    } else {
      Button(action: onLoadMore) {
        Label("Load More", systemImage: "arrow.down.circle")
          .padding()
      }
      .buttonStyle(.bordered)
      .padding(.bottom)
    }
  }
}

#Preview {
  let _ = prepareDependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }

  NavigationStack {
    Feed(
      store: Store(initialState: FeedFeature.State(feedType: .subscriptions)) {
        FeedFeature()
      }
    )
  }
}
