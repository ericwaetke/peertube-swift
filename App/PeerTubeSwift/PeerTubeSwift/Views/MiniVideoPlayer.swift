//
//  MiniVideoPlayer.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 26.12.25.
//

import ComposableArchitecture
import SwiftUI
import TubeSDK

@Reducer
struct MiniVideoPlayerFeature {
    @ObservableState
    struct State {
        let videoState: VideoDetailsFeature.State
        @Shared(.inMemory("client")) var client: TubeSDKClient = try! TubeSDKClient(
            scheme: "https", host: "peertube.wtf")
    }

    enum Action {
        case onTap
        case onDismiss
    }

    var body: some ReducerOf<Self> {
        Reduce { state, action in
            switch action {
            case .onTap:
                return .none
            case .onDismiss:
                return .none
            }
        }
    }
}

struct MiniVideoPlayer: View {
    @Bindable var store: StoreOf<MiniVideoPlayerFeature>

    @Dependency(\.videoPlayerCoordinator) var coordinator

    var body: some View {
        HStack(spacing: 12) {
            // Actual video player view (mini size)
            MiniPersistentVideoPlayerView()
                .frame(width: 60, height: 34)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .onTapGesture {
                    coordinator.togglePlayback()
                }

            // Video info
            VStack(alignment: .leading, spacing: 2) {
                Text(coordinator.currentVideoInfo?.title ?? "Loading...")
                    .font(.system(size: 14, weight: .medium))
                    .lineLimit(1)
                    .foregroundColor(.primary)

                Text(coordinator.currentVideoInfo?.channelName ?? "")
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .foregroundColor(.secondary)
            }

            Spacer()

            // Play/pause button
            Button(action: {
                coordinator.togglePlayback()
            }) {
                Image(systemName: coordinator.isPlaying ? "pause.fill" : "play.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.primary)
            }
            .buttonStyle(.plain)

            // Dismiss button
            Button {
                self.store.send(.onDismiss)
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14))
                    .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .contentShape(Rectangle())
        .onTapGesture {
            self.store.send(.onTap)
        }
        .padding(.horizontal, 16)
        .padding(.bottom, 8)
    }
}

#Preview {
    let videoState = VideoDetailsFeature.State(
        host: "peertube.wtf",
        videoId: "18QZB6GTN1DRd1LtkeQm22"
    )

    MiniVideoPlayer(
        store: Store(initialState: MiniVideoPlayerFeature.State(videoState: videoState)) {
            MiniVideoPlayerFeature()
        }
    )
    //    .previewLayout(.sizeThatFits)
    //    .sizeThatFitsLayout
    .padding()
}
