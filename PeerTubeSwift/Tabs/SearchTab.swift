//
//  SearchTag.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 30.07.26.
//

import ComposableArchitecture
import Dependencies
import PeerSeekSDK
import SQLiteData
import SwiftUI
import TubeSDK
import WebURL

@Reducer
struct SearchTabFeature {
  @ObservableState
  struct State: Equatable {
    var navigation = FeedNavigationFeature.State()

    var searchText = String()
    var isSearchActive = false
    var suggestions: [PeerSeekSDK.Suggestion] = []

    @Shared(.inMemory("session")) var session: UserSession?
  }

  @Dependency(\.peerSeekClient) var peerSeekClient
  @Dependency(\.suspendingClock) var clock
  enum CancelID { case searchSuggestions }

  enum Action {
    case navigation(FeedNavigationFeature.Action)

    case setSearch(String)
    case startSearch
    case activateSearch
    case setSearchActive(Bool)

    case categoryTapped(PeerSeekSDK.Category)

    case delegate(Delegate)

    case triggerUpdateSuggestions(String)
    case updateSuggestions([PeerSeekSDK.Suggestion])

    enum Delegate {
      case openSettings
    }
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.navigation, action: \.navigation) {
      FeedNavigationFeature()
    }
    Reduce { state, action in
      switch action {
      case .navigation(.path(let action)):
        switch action {
        case .element(
          id: _,
          action: .channelDetail(.delegate(.navigateToVideo(host: let host, videoId: let videoId)))):
          return FeedNavigationFeature.navigateToVideo(
            &state.navigation, host: host, videoId: videoId
          )
          .map { (action: FeedNavigationFeature.Action) -> SearchTabFeature.Action in
            .navigation(action)
          }

        default:
          return .none
        }

      case .delegate:
        return .none

      case .setSearch(let text):
        state.searchText = text
        return .send(.triggerUpdateSuggestions(text))

      case .startSearch:
        guard !state.searchText.isEmpty else { return .none }
        state.navigation.path.append(.feed(FeedFeature.State(feedType: .search(state.searchText))))
        return .send(
          .navigation(
            .path(
              .element(
                id: state.navigation.path.ids.last!,
                action: .feed(
                  .loadVideosBySearch(state.searchText))
              ))))

      case .activateSearch:
        state.isSearchActive = true
        return .none

      case .setSearchActive(let active):
        state.isSearchActive = active
        return .none
      case .navigation(.videoDetail(_)):
        return .none
      case .categoryTapped(let category):
        state.navigation.path.append(
          .feed(FeedFeature.State(feedType: .category(category.rawValue))))
        return .send(
          .navigation(
            .path(
              .element(
                id: state.navigation.path.ids.last!,
                action: .feed(
                  .loadVideosByCategory(category))
              ))))
      case .triggerUpdateSuggestions(let q):
        return .run { send in
          try await withTaskCancellation(id: CancelID.searchSuggestions, cancelInFlight: true) {
            try await clock.sleep(for: .milliseconds(300))
            guard !Task.isCancelled else { return }

            let res = try await self.peerSeekClient.getSearchSuggestions(q: q)
            if res.count > 0 {
              await send(.updateSuggestions(res))
            }
          }
        }
      case .updateSuggestions(let suggestions):
        print("updating suggestions to: \(suggestions)")
        state.suggestions = suggestions
        return .none
      }
    }
  }
}

// THE COLOR EXTENSION AND MOCKDATA IS JUST FOR TESTING!!!
extension Color {
  static var random: Color {
    return Color(
      red: Double.random(in: 0...1),
      green: Double.random(in: 0...1),
      blue: Double.random(in: 0...1))
  }
}

struct MockData {
  static var colors: [Color] {
    var array: [Color] = []
    for _ in 0..<30 { array.append(Color.random) }
    return array

  }
}

let categories: [PeerSeekSDK.Category] = [
  .newsPolitics
]

struct SearchTab: View {
  @Bindable var store: StoreOf<SearchTabFeature>

  var body: some View {
    NavigationStack(path: $store.scope(state: \.navigation.path, action: \.navigation.path)) {
      contentView
    } destination: { pathStore in
      destinationView(for: pathStore)
    }
    .sheet(
      item: $store.scope(
        state: \.navigation.videoDetail, action: \.navigation.videoDetail
      )
    ) { store in
      VideoDetails(store: store)
        .presentationDragIndicator(.visible)
    }
  }

  @ViewBuilder
  private var contentView: some View {
    ScrollView {
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))]) {
        ForEach(Array(shownCategories.keys), id: \.self) { category in
          CategoryCard(category: category)
            .onTapGesture {
              self.store.send(.categoryTapped(category))
            }
        }
      }
      .padding()
    }
    .navigationTitle("Search")
    .searchable(
      text: $store.searchText.sending(\.setSearch),
    )
    .searchSuggestions({
      ForEach(store.suggestions, id: \.self) { suggestion in
        Label(suggestion.term, systemImage: "magnifyingglass")
          .searchCompletion(suggestion.term)
      }
    })
    .onSubmit(of: .search) {
      self.store.send(.startSearch)
    }
  }

  @ViewBuilder
  private func destinationView(for pathStore: StoreOf<FeedNavigationFeature.Path>) -> some View {
    switch pathStore.case {
    case .channelDetail(let store):
      VideoChannelView(store: store)
    case .feed(let store):
      Feed(store: store)
    }
  }
}

#Preview {
  let _ = prepareDependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }

  SearchTab(
    store: Store(initialState: SearchTabFeature.State()) {
      SearchTabFeature()
    }
  )
}
