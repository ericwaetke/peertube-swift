//
//  FeedNavigationStack.swift
//  PeerTubeSwift
//

import ComposableArchitecture
import SwiftUI

/// The navigation path store every feed-style tab scopes out of its own feature.
typealias FeedNavigationPathStore = Store<
  StackState<FeedNavigationFeature.Path.State>,
  StackAction<FeedNavigationFeature.Path.State, FeedNavigationFeature.Path.Action>
>

/// Shared navigation shell for the feed-style tabs.
///
/// Feed, explore and search each own a `FeedNavigationFeature` and render the same two
/// destinations; only their root content differs. This owns the `NavigationStack` and the
/// destination switch so the three tabs cannot drift apart.
struct FeedNavigationStack<Root: View>: View {
  @Binding var path: FeedNavigationPathStore
  @ViewBuilder var root: () -> Root

  var body: some View {
    NavigationStack(path: $path) {
      root()
    } destination: { pathStore in
      switch pathStore.case {
      case .channelDetail(let store):
        VideoChannelView(store: store)
      case .feed(let store):
        Feed(store: store)
      }
    }
  }
}
