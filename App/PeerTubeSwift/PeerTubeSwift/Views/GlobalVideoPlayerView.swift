import SwiftUI
import ComposableArchitecture
import TubeSDK

enum VideoPresentationState: Equatable {
    case hidden
    case minimized
    case expanded
}

struct GlobalVideoPlayerView: View {
    @Bindable var store: StoreOf<VideoDetailsFeature>
    let presentationState: VideoPresentationState
    let onStateChange: (VideoPresentationState) -> Void
    let onClose: () -> Void
    
    @Namespace private var animation
    
    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .bottom) {
                if presentationState == .expanded {
                    VStack(spacing: 0) {
                        // Header with grabber to minimize
                        HStack {
                            Button {
                                withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                    onStateChange(.minimized)
                                }
                            } label: {
                                Image(systemName: "chevron.down")
                                    .font(.title2)
                                    .padding()
                            }
                            .tint(.primary)
                            
                            Spacer()
                        }
                        .padding(.top, proxy.safeAreaInsets.top)
                        .background(Color(uiColor: .systemBackground))
                        
                        VideoDetails(store: store)
                    }
                    .background(Color(uiColor: .systemBackground))
                    .transition(.move(edge: .bottom))
                    .ignoresSafeArea()
                } else if presentationState == .minimized {
                    VStack(spacing: 0) {
                        Divider()
                        HStack(spacing: 12) {
                        // Mini player view / thumbnail
                        if let videoDetails = store.state.videoDetails,
                           let videoFiles = videoDetails.streamingPlaylists?.first?.files,
                           !videoFiles.isEmpty {
                            VideoPlayerView(
                                onTimeUpdate: { time in store.send(.timeUpdate(time)) },
                                videoFiles: videoFiles,
                                selectedVideoFile: store.state.selectedQuality,
                                startTime: videoDetails.userHistory?.currentTime
                            )
                            .aspectRatio(16/9, contentMode: .fit)
                            .frame(height: 54)
                            .cornerRadius(6)
                        } else {
                            Rectangle()
                                .fill(Color.secondary.opacity(0.3))
                                .frame(width: 96, height: 54)
                                .cornerRadius(6)
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(store.state.videoDetails?.name ?? "Loading...")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .lineLimit(1)
                            
                            Text(store.state.videoChannel?.name ?? store.state.host)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                        
                        Spacer()
                        
                        Button {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                onClose()
                            }
                        } label: {
                            Image(systemName: "xmark")
                                .font(.title3)
                                .foregroundColor(.primary)
                        }
                        .padding(.trailing, 8)
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(.ultraThinMaterial)
                    .onTapGesture {
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                            onStateChange(.expanded)
                        }
                    }
                }
                .transition(.move(edge: .bottom))
            }
        }
    }
}
}
