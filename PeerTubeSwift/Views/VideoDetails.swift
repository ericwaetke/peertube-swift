//
//  VideoDetails.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import ComposableArchitecture
import Dependencies
import FontKit
import PeerSeekSDK
import SQLiteData
import SwiftUI
import TubeSDK

@Reducer
struct VideoDetailsFeature {
  @Dependency(\.peerSeekClient) var peerSeekClient

  @ObservableState
  struct State: Equatable {
    let host: String
    let videoId: String
    var seekRequest: SeekRequest?
    @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
      scheme: "https", host: "peertube.wtf")

    var videoDetails: TubeSDK.VideoDetails?
    var pauseTrigger: Int = 0

    var recommendedVideos: [VideoRecommendation] = []

    var actions: VideoActionsFeature.State
    var channelPreview: ChannelPreviewFeature.State
    var description: VideoDescriptionFeature.State
    var relatedVideos: RelatedVideosFeature.State
    var comments: VideoCommentsFeature.State
    var isNotFound: Bool = false

    init(host: String, videoId: String, channelId: String?) {
      self.host = host
      self.videoId = videoId
      actions = VideoActionsFeature.State(host: host, videoId: videoId)
      channelPreview = ChannelPreviewFeature.State(
        host: host,
        notificationBell: NotificationBellFeature.State(channelId: channelId),
        videoChannel: nil
      )
      description = VideoDescriptionFeature.State()
      self.relatedVideos = RelatedVideosFeature.State()
      comments = VideoCommentsFeature.State(videoId: videoId)
    }
  }

  enum Action {
    case timeUpdate(Int)
    case seekTo(Int)
    case loadVideo(TubeSDK.VideoDetails)
    case loadInstance
    case instanceLoaded(Instance)
    case screenLoaded
    case videoLoadFailed

    case loadRecommendedVideos
    case recommendedVideosLoaded([VideoRecommendation])
    case recommendationsLoadFailed(String)

    case actions(VideoActionsFeature.Action)
    case channelPreview(ChannelPreviewFeature.Action)
    case description(VideoDescriptionFeature.Action)
    case relatedVideos(RelatedVideosFeature.Action)
    case comments(VideoCommentsFeature.Action)

    case delegate(Delegate)

    enum Delegate {
      case navigateToChannel(host: String, channel: TubeSDK.VideoChannel)
    }
  }

  var body: some ReducerOf<Self> {
    Scope(state: \.actions, action: \.actions) {
      VideoActionsFeature()
    }
    Scope(state: \.channelPreview, action: \.channelPreview) {
      ChannelPreviewFeature()
    }
    Scope(state: \.description, action: \.description) {
      VideoDescriptionFeature()
    }
    Scope(state: \.relatedVideos, action: \.relatedVideos) {
      RelatedVideosFeature()
    }
    Scope(state: \.comments, action: \.comments) {
      VideoCommentsFeature()
    }

    Reduce { state, action in
      switch action {
      case .seekTo(let time):
        state.seekRequest = SeekRequest(time: time)
        return .none

      case .timeUpdate(let time):
        return .run {
          [client = state.client, videoId = state.videoId, videoDetails = state.videoDetails] _ in
          try? await client.pingVideoWatchingInProgress(videoID: videoId, currentTime: time)

          if let uuid = videoDetails?.uuid {
            @Dependency(\.defaultDatabase) var database
            try? await database.write { db in
              try Video
                .where { $0.id.eq(uuid) }
                .update { $0.currentTime = #bind(time) }
                .execute(db)
            }
          }
        }

      case .screenLoaded:
        return .send(.loadInstance)

      case .loadInstance:
        return .run { [host = state.host] send in
          @Dependency(\.defaultDatabase) var database
          @Dependency(\.peertubeOrchestrator) var peertubeOrchestrator

          await withErrorReporting {
            let instance = try await peertubeOrchestrator.syncInstanceInfo(host, database)
            await send(.instanceLoaded(instance))
          }
        }

      case .instanceLoaded(let instance):
        state.channelPreview.instance = instance
        return .run { [client = state.client, videoId = state.videoId, host = state.host] send in
          print("running side-effect screen loaded")

          var videoDetails: TubeSDK.VideoDetails?

          do {
            videoDetails = try await client.getVideo(
              host: client.instance.host, id: videoId
            )
          } catch {
            // fallback to videos origin instance
            // only needed when video isnt found on users home instance
            print("falling back to host \(host)")
            if host != client.instance.host {
              let originClient = try TubeSDKClient(scheme: "https", host: host)
              videoDetails = try await originClient.getVideo(host: host, id: videoId)
            } else {
              throw error
            }
          }
          guard var videoDetails else {
            await send(.videoLoadFailed)
            return
          }

          if videoDetails.userHistory == nil {
            if let uuid = videoDetails.uuid {
              @Dependency(\.defaultDatabase) var database
              let localTime = try? await database.read { db in
                try Video.find(uuid).fetchOne(db)?.currentTime
              }
              if let time = localTime {
                videoDetails.userHistory = TubeSDK.VideoUserHistory(currentTime: time)
              }
            }
          }

          await send(.loadVideo(videoDetails))
        } catch: { error, send in
          print("Error loading video: \(error)")
          if let tubeError = error as? TubeError, case .notFound = tubeError {
            await send(.videoLoadFailed)
          } else if (error as NSError).code == 404 {
            await send(.videoLoadFailed)
          }
        }

      case .videoLoadFailed:
        state.isNotFound = true
        return .none

      case .loadVideo(let videoDetails):
        state.videoDetails = videoDetails

        state.actions.videoDetails = videoDetails
        state.channelPreview.videoChannel = videoDetails.channel
        state.description.videoDetails = videoDetails
        state.comments.videoDetails = videoDetails

        if state.actions.selectedQuality == nil {
          if let quality = videoDetails.streamingPlaylists?.first?.files?.first {
            state.actions.selectedQuality = quality
          }
        }

        return .run { [videoDetails = videoDetails] send in

          if let videoChannel = videoDetails.channel {
            await send(.channelPreview(.loadChannelPreview(videoChannel)))
          }

          await send(.actions(.loadUserRating))
          await send(.comments(.loadComments))
          await send(.loadRecommendedVideos)
        }

      case .description(.delegate(.seekTo(let time))):
        return .send(.seekTo(time))

      case .comments(.delegate(.seekTo(let time))):
        return .send(.seekTo(time))

      case .channelPreview(.channelTapped):
        guard let channel = state.channelPreview.videoChannel,
          let channelName = channel.name
        else {
          return .none
        }
        state.pauseTrigger += 1
        return .send(.delegate(.navigateToChannel(host: state.host, channel: channel)))

      case .delegate:
        return .none

      case .actions, .channelPreview, .description, .comments:
        return .none
      case .loadRecommendedVideos:
        return .run { [videoDetails = state.videoDetails] send in
          guard let videoDetails,
            let uuid = videoDetails.uuid
          else {
            print("couldnt load recommendations as videodetails is nil, or no uuid")
            print(videoDetails)
            return
          }
          print("The UUID is \(uuid)")
          let related = try await peerSeekClient.getVideoRecommendations(uuid: uuid)
          await send(.recommendedVideosLoaded(related))
          await send(.relatedVideos(.loadVideos(related)))
        } catch: { error, send in
          await send(.recommendationsLoadFailed(error.localizedDescription))
        }
      case .recommendedVideosLoaded(let recommendations):
        state.recommendedVideos = recommendations
        return .none
      case .recommendationsLoadFailed(let message):
        print("Error loading recommendations: \(message)")
        state.recommendedVideos = []
        return .none
      case .relatedVideos(_):
        return .none
      }
    }
  }
}

struct VideoDetails: View {
  let store: StoreOf<VideoDetailsFeature>
  let playerManager: PlayerManager
  let formatter = RelativeDateTimeFormatter()
  @State private var isPlayerReady = false

  var body: some View {
    ZStack {
      if self.store.isNotFound {
        ContentUnavailableView(
          "Video Not Found",
          systemImage: "video.slash",
          description: Text("The video you are looking for does not exist or has been removed.")
        )
      } else if let videoDetails = self.store.videoDetails {

        VStack(spacing: 0) {
          if let videoFiles = videoDetails.streamingPlaylists?.first?.files,
            !videoFiles.isEmpty
          {
            VideoPlayerView(
              isPlayerReady: $isPlayerReady,
              onTimeUpdate: { time in self.store.send(.timeUpdate(time)) },
              videoFiles: videoFiles,
              selectedVideoFile: self.store.actions.selectedQuality,
              startTime: videoDetails.userHistory?.currentTime,
              seekRequest: self.store.seekRequest,
              videoTitle: videoDetails.name,
              channelName: videoDetails.channel?.displayName,
              thumbnailPath: videoDetails.bestThumbnailUrl(client: store.client, size: .large),
              pauseTrigger: self.store.pauseTrigger,
              playerManager: playerManager,
              videoId: store.videoId
            )
            .frame(
              minWidth: 0,
              maxWidth: .infinity,
              minHeight: 100,
              maxHeight: .infinity
            )
            .aspectRatio(16 / 9, contentMode: .fit)
          }
          ScrollView {
            VStack(alignment: .leading, spacing: 16) {
              VStack(spacing: 8) {
                Button {
                  let newValue = !self.store.state.description.descriptionVisible

                  self.store.send(.description(.descriptionVisibleChanged(newValue)))

                } label: {
                  VStack(alignment: .leading, spacing: 8) {
                    Text(videoDetails.name ?? "Unknown Video Title")
                      .font(CustomFont.fjallaOne.swiftUIFont(size: 22, relativeTo: .title2))
                      .fontWeight(.bold)
                      .foregroundStyle(Color("Label/Primary"))
                      .multilineTextAlignment(.leading)
                      .padding(.horizontal, 16)

                    HStack(spacing: 6) {
                      ViewsAndDate(
                        views: videoDetails.views, videoPublishDate: videoDetails.publishedAt,
                        unitStyle: .full
                      )
                      .foregroundStyle(Color(uiColor: .secondaryLabel))

                      if !self.store.state.description.descriptionVisible {
                        Text("… more")
                          .font(
                            CustomFont.inclusiveSansSemiBold.swiftUIFont(
                              size: 13, relativeTo: .footnote)
                          )
                          .foregroundStyle(Color("Label/Highlight"))
                      }
                    }
                    .padding(.horizontal, 16)

                    VideoDescriptionView(
                      store: self.store.scope(state: \.description, action: \.description))
                  }
                  .frame(maxWidth: .infinity, alignment: .leading)
                }
                .buttonStyle(.plain)

                VideoActionsView(store: self.store.scope(state: \.actions, action: \.actions))
                  .padding(.horizontal, 16)
              }

              .padding(.top, 16)
              .padding(.bottom, 24)
              .overlay(
                Rectangle().frame(width: nil, height: 0.33, alignment: .top).foregroundColor(
                  Color(uiColor: .separator)), alignment: .bottom)

              ChannelPreviewView(
                store: self.store.scope(state: \.channelPreview, action: \.channelPreview)
              )
              .padding()

              RelatedVideosView(
                store: self.store.scope(state: \.relatedVideos, action: \.relatedVideos))

              VStack(alignment: .leading) {
                VideoCommentsView(store: self.store.scope(state: \.comments, action: \.comments))
              }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
          }
        }
      } else {
        ProgressView()
      }
    }
    .task {
      await self.store.send(.screenLoaded).finish()
    }
    .onChange(of: store.videoDetails) { _, details in
      guard let details else { return }
      playerManager.currentVideoInfo = PlayerManager.VideoInfo(
        host: store.host,
        videoId: store.videoId,
        title: details.name,
        channelName: details.channel?.displayName,
        thumbnailUrl: details.bestThumbnailUrl(client: store.client, size: .large)
      )
    }
  }
}

#Preview {
  let _ = prepareDependencies {
    try! $0.bootstrapDatabase()
    try! $0.defaultDatabase.seed()
  }

  let playerManager = PlayerManager()

  NavigationStack {
    VideoDetails(
      store: Store(
        initialState: VideoDetailsFeature.State(
          host: "makertube.net",
          videoId: "d4VvgzW5m4jaGr9JFVBUCg",
          channelId: "veronicaexplains@makertube.net"
        )
      ) {
        VideoDetailsFeature()
      },
      playerManager: playerManager
    )
  }
}
