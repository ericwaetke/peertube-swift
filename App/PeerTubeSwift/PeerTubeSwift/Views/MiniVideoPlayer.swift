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

    var body: some View {
        HStack(spacing: 12) {
            // Video thumbnail
            if let videoDetails = self.store.videoState.videoDetails {
                if let previewPath = videoDetails.previewPath,
                    let url = try? self.store.client.getImageUrl(path: previewPath) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Rectangle()
                                .fill(.gray.opacity(0.3))
                        }
                        .frame(width: 60, height: 34)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
                
                // Video info
                VStack(alignment: .leading, spacing: 2) {
                    Text(self.store.state.videoState.videoDetails?.name ?? "Loading...")
                        .font(.system(size: 14, weight: .medium))
                        .lineLimit(1)
                        .foregroundColor(.primary)
                    
                    Text(
                        "Collective Change"
                    )
                    .font(.system(size: 12))
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                }
                
            }

            Spacer()

            // Play/pause button (placeholder for now)
            Button(action: {
                // TODO: Implement play/pause functionality
            }) {
                Image(systemName: "play.fill")
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

    MiniVideoPlayer(store: Store(initialState: MiniVideoPlayerFeature.State(videoState: videoState)) {
        MiniVideoPlayerFeature()
    })
//    .previewLayout(.sizeThatFits)
//    .sizeThatFitsLayout
    .padding()
}
