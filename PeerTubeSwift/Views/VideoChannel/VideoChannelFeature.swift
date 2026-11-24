//
//  VideoChannelFeature.swift
//  PeerTubeSwift
//

import ComposableArchitecture
import Dependencies
import Foundation
import SQLiteData
import TubeSDK

@Reducer
struct VideoChannelFeature {
  @ObservableState
  struct State: Equatable {
    let host: String
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
      scheme: "https", host: "peertube.wtf")

    var channelPreview: ChannelPreviewFeature.State

    var titleVisible: Bool = false

    var instance: Instance?
    var videoChannel: VideoChannel?
    var videoDetails: TubeSDK.VideoDetails?
    var channelName: String?
    var followerCount: Int?
    var videoCount: Int?

    // Video list state
    var videos: [TubeSDK.Video] = []
    var videoCards: IdentifiedArrayOf<VideoCardFeature.State> = []
    var isLoadingVideos = false
    var hasLoadedAtLeastOnce = false
    var currentPage = 0
    let pageSize = 15
    var hasMoreVideos = true

    init(
      host: String,
      instance: Instance? = nil,
      videoDetails: TubeSDK.VideoDetails? = nil
    ) {
      self.host = host
      self.instance = instance
      self.videoDetails = videoDetails
      self.channelPreview = ChannelPreviewFeature.State(
        host: host,
        notificationBell: NotificationBellFeature.State(channelId: nil, isOn: false),
        videoChannel: videoDetails?.channel,
        instance: instance
      )
    }
  }

  enum Action {
    case loadChannelFromRow(
      channelId: String, channelName: String, avatarUrl: String?, bannerUrl: String?,
      description: String?, host: String
    )
    case channelDetailsLoaded(
      channelId: String, channelName: String, avatarUrl: String?, bannerUrl: String?,
      description: String?, host: String, followerCount: Int?
    )
    case channelPreview(ChannelPreviewFeature.Action)

    // Video list actions
    case loadVideos
    case loadMoreVideosIfNeeded(currentItemId: String?)
    case finishLoadingVideos([TubeSDK.Video], total: Int?)
    case videoTapped(TubeSDK.Video)
    case videoCards(IdentifiedActionOf<VideoCardFeature>)

    case setTitleVisible(Bool)

    case delegate(Delegate)

    enum Delegate: Equatable {
      case navigateToVideo(host: String, videoId: String)
    }
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.channelPreview, action: \.channelPreview) {
      ChannelPreviewFeature()
    }
    Reduce { state, action in
      switch action {
      case .loadChannelFromRow(
        let channelId, let channelName, let avatarUrl, let bannerUrl, let description, let host):
        state.channelName = channelName

        // Fetch full channel details from API to get description
        return .run {
          [
            client = state.client, channelId = channelId, channelName = channelName,
            avatarUrl = avatarUrl, bannerUrl = bannerUrl, description = description, host = host
          ] send in
          do {
            let fullChannel = try await client.getChannel(channelIdentifier: channelId)
            let banner: String? = fullChannel.banners?.first?.fileUrl
            await send(
              .channelDetailsLoaded(
                channelId: channelId,
                channelName: fullChannel.displayName ?? channelName,
                avatarUrl: fullChannel.avatars?.first?.fileUrl ?? avatarUrl,
                bannerUrl: banner,
                description: fullChannel.description,
                host: host,
                followerCount: fullChannel.followersCount
              ))
          } catch {
            await send(
              .channelDetailsLoaded(
                channelId: channelId,
                channelName: channelName,
                avatarUrl: avatarUrl,
                bannerUrl: bannerUrl,
                description: description,
                host: host,
                followerCount: nil
              ))
          }
        }

      case .channelDetailsLoaded(
        let channelId, let channelName, let avatarUrl, let bannerUrl, let description, let host,
        let followerCount):
        // Update channel name if we got a better one from API
        if channelName != state.channelName {
          state.channelName = channelName
        }
        state.followerCount = followerCount
        // Create a local VideoChannel from the data
        state.videoChannel = VideoChannel(
          id: channelId,
          name: channelName,
          avatarUrl: avatarUrl,
          bannerUrl: bannerUrl,
          description: description,
          instanceID: host,
          followerCount: followerCount
        )

        let tubeSdkVideoChannel = TubeSDK.VideoChannel(
          name: channelId.components(separatedBy: "@").first,
          avatars: avatarUrl.flatMap { url in
            [TubeSDK.ActorImage(fileUrl: url)]
          },
          host: host,
          displayName: channelName,
          description: description
        )
        // Also create a minimal VideoDetails so the view has channel info
        state.videoDetails = TubeSDK.VideoDetails(
          channel: tubeSdkVideoChannel
        )

        return .run { [videoChannel = tubeSdkVideoChannel] send in
          await send(.channelPreview(.loadChannelPreview(videoChannel)))
          await send(.loadVideos)
        }

      case .loadVideos:
        // Determine channel ID from either videoDetails or videoChannel
        let channelId: String
        if let videoDetails = state.videoDetails,
          let channel = videoDetails.channel,
          let channelUsername = channel.name,
          let channelHost = channel.host
        {
          channelId = "\(channelUsername)@\(channelHost)"
        } else if let channel = state.videoChannel {
          channelId = channel.id
        } else {
          return .none
        }

        state.isLoadingVideos = true
        state.currentPage = 0
        state.videos = []

        return .run {
          [client = state.client, channelId = channelId, pageSize = state.pageSize] send in
          do {
            let response = try await client.getVideosPaginated(
              channelIdentifier: channelId,
              start: 0,
              count: pageSize
            )
            await send(.finishLoadingVideos(response.data, total: response.total))
          } catch {
            await send(.finishLoadingVideos([], total: nil))
          }
        }

      case .loadMoreVideosIfNeeded(let currentItemId):
        // Load more when user scrolls near the end
        guard let currentItemId = currentItemId,
          state.hasMoreVideos,
          !state.isLoadingVideos
        else {
          return .none
        }

        // Check if we're near the end (last 3 items)
        let currentIndex = state.videos.firstIndex { $0.uuid?.uuidString == currentItemId } ?? -1
        guard currentIndex >= state.videos.count - 3 else {
          return .none
        }

        // Load more
        let channelId: String
        if let videoDetails = state.videoDetails,
          let channel = videoDetails.channel,
          let channelUsername = channel.name,
          let channelHost = channel.host
        {
          channelId = "\(channelUsername)@\(channelHost)"
        } else if let channel = state.videoChannel {
          channelId = channel.id
        } else {
          return .none
        }

        let nextPage = state.currentPage + 1
        state.isLoadingVideos = true

        return .run {
          [client = state.client, channelId = channelId, pageSize = state.pageSize, nextPage] send
          in
          do {
            let response = try await client.getVideosPaginated(
              channelIdentifier: channelId,
              start: nextPage * pageSize,
              count: pageSize
            )
            await send(.finishLoadingVideos(response.data, total: response.total))
          } catch {
            await send(.finishLoadingVideos([], total: nil))
          }
        }

      case .finishLoadingVideos(let newVideos, let total):
        if state.currentPage == 0, let total {
          state.videoCount = total
        }
        if state.currentPage == 0 {
          state.videos = newVideos
        } else {
          state.videos.append(contentsOf: newVideos)
        }
        let newCards = newVideos.map { video in
          let thumbnailUrl = video.bestThumbnailUrl(client: state.client, size: .medium)
          let cdName = state.videoChannel?.name ?? state.channelName ?? "Channel"
          let caUrl = video.channel?.avatars?.first?.fileUrl
          return VideoCardFeature.State(
            variant: .large,
            id: video.uuid?.uuidString ?? UUID().uuidString,
            videoUUID: video.uuid?.uuidString,
            videoName: video.name ?? "Unknown",
            videoThumbnailUrl: thumbnailUrl,
            videoDuration: video.duration,
            videoCurrentTime: video.userHistory?.currentTime,
            videoPublishDate: video.publishedAt,
            videoViews: video.views,
            channelDisplayName: cdName,
            channelAvatarUrl: caUrl,
            channelId: video.channel.flatMap { $0.name.map { "\($0)@\(state.host)" } },
            channelDescription: nil,
            instanceDisplayHost: state.host,
            instanceDisplayAvatarUrl: state.instance?.avatarUrl,
            userBadge: UserBadgeFeature.State(
              variant: .medium,
              avatarUrl: caUrl ?? "",
              channelDisplayName: cdName,
              instanceDisplayName: state.host,
              instanceIconUrl: state.instance?.avatarUrl ?? ""
            ),
            videoRow: nil
          )
        }
        if state.currentPage == 0 {
          state.videoCards = IdentifiedArray(uncheckedUniqueElements: newCards)
        } else {
          state.videoCards.append(contentsOf: newCards)
        }
        state.hasMoreVideos = newVideos.count >= state.pageSize
        state.currentPage += 1
        state.isLoadingVideos = false
        state.hasLoadedAtLeastOnce = true
        return .none

      case .videoTapped(let video):
        guard let videoId = video.uuid?.uuidString else { return .none }
        return .send(.delegate(.navigateToVideo(host: state.host, videoId: videoId)))

      case .videoCards(.element(id: let id, action: .delegate(.videoTapped))):
        guard let card = state.videoCards[id: id],
          let videoUUID = card.videoUUID,
          let video = state.videos.first(where: { $0.uuid?.uuidString == videoUUID })
        else { return .none }
        return .send(.videoTapped(video))

      case .videoCards(.element(id: _, action: .delegate(.openChannel))):
        return .none

      case .videoCards:
        return .none

      case .channelPreview:
        return .none

      case .delegate:
        return .none
      case .setTitleVisible(let visibility):
        state.titleVisible = visibility
        return .none
      }
    }
    .forEach(\.videoCards, action: \.videoCards) {
      VideoCardFeature()
    }
  }
}
