//
//  SearchTag.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 30.07.26.
//

import ComposableArchitecture
import Dependencies
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

    @Shared(.inMemory("session")) var session: UserSession?
  }

  enum Action {
    case navigation(FeedNavigationFeature.Action)

    case setSearch(String)
    case startSearch
    case activateSearch
    case setSearchActive(Bool)

    case categoryTapped(String)

    case delegate(Delegate)

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
        return .none

      case .startSearch:
        guard !state.searchText.isEmpty else { return .none }
        state.navigation.path.append(.feed(FeedFeature.State(feedType: .search)))
        return .send(
          .navigation(
            .path(
              .element(
                id: state.navigation.path.ids.last!,
                action: .feed(
                  .loadVideosBySearch(TubeSDK.SearchVideoQueryParameters(search: state.searchText)))
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
        ForEach(MockData.colors, id: \.self) {
          CategoryCard(color: $0)
            .onTapGesture {
              self.store.send(.categoryTapped($0.debugDescription))
            }
        }
      }
      .padding()
    }
    .navigationTitle("Search")
    .searchable(
      text: $store.searchText.sending(\.setSearch),
      //      isPresented: $store.isSearchActive.sending(\.setSearchActive)
    )
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
