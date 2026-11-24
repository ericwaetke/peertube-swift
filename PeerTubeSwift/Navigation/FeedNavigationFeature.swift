//
//  FeedNavigationFeature.swift
//  PeerTubeSwift
//

import ComposableArchitecture
import TubeSDK

// MARK: - Feed Navigation Feature

/// Shared navigation reducer for feed tabs.
/// Handles video and channel navigation with consistent behavior.
@Reducer
struct FeedNavigationFeature {
  @Reducer
  enum Path {
    case channelDetail(VideoChannelFeature)
    case feed(FeedFeature)
  }

  @ObservableState
  struct State: Equatable {
    var path = StackState<Path.State>()
  }

  enum Action {
    case path(StackActionOf<Path>)
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .path(let action):
        switch action {
        case .element(id: _, action: .feed(.channelTapped(row: let row))):
          return Self.navigateToChannelFromRow(&state.path, row: row)
        default:
          return .none
        }
      }
    }
    .forEach(\.path, action: \.path)
  }

  /// Helper to navigate to a channel with proper state management
  static func navigateToChannel(
    _ path: inout StackState<Path.State>,
    host: String,
    channelIdentifier: String,  // Can be Int? from VideoChannelSummary or String?
    channelName: String?,
    avatarUrl: String?,
    bannerUrl: String?,
    channelDescription: String?,
    instance: Instance?
  ) -> Effect<Action> {
    guard let channelName = channelName else { return .none }

    var channelState = VideoChannelFeature.State(
      host: host,
      instance: instance
    )
    channelState.channelName = channelName
    path.append(.channelDetail(channelState))

    // Capture path ID before async block
    let pathId = path.ids.last!

    return .run { send in
      await send(
        .path(
          .element(
            id: pathId,
            action: .channelDetail(
              .loadChannelFromRow(
                channelId: channelIdentifier,
                channelName: channelName,
                avatarUrl: avatarUrl,
                bannerUrl: bannerUrl,
                description: channelDescription,
                host: host
              ))
          )))
    }
  }

  /// Navigate to channel from a VideoRow
  static func navigateToChannelFromRow(
    _ path: inout StackState<Path.State>,
    row: VideoRow
  ) -> Effect<Action> {
    guard let channel = row.channel,
      let instance = row.instance
    else {
      return .none
    }

    var channelState = VideoChannelFeature.State(
      host: instance.host,
      instance: instance
    )
    channelState.channelName = channel.name
    path.append(.channelDetail(channelState))

    let pathId = path.ids.last!

    return .run { send in
      await send(
        .path(
          .element(
            id: pathId,
            action: .channelDetail(
              .loadChannelFromRow(
                channelId: channel.id,
                channelName: channel.name,
                avatarUrl: channel.avatarUrl,
                bannerUrl: channel.bannerUrl,
                description: channel.description,
                host: instance.host
              ))
          )))
    }
  }

}

extension FeedNavigationFeature.Path.State: Equatable {}
