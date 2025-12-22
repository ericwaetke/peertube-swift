//
//  Explore.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SwiftUI
import peertube_swift_sdk

struct Explore: View {
    @Environment(AppState.self) private var appState: AppState
    
    @State var videos: [Video] = []
    @State var loading = false
    
    var body: some View {
        @Bindable var appState = appState
        
        NavigationStack(path: $appState.navigationPath) {
            ZStack {
                if loading {
                    ProgressView()
                } else {
                    ScrollView {
                        LazyVStack(alignment: .leading) {
                            ForEach(videos, id: \.self) { video in
                                VideoCard(video: video)
                                    .onTapGesture {
                                        appState.navigationPath.append(video)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Explore")
            .navigationDestination(for: Video.self) { video in
                VideoDetails(video: video)
            }
            .onAppear {
                loading = true
                Task {
                    do {
                        let result = try await appState.client.getVideos()
                        videos = result
                        loading = false
                    } catch {
                        print("Error getting videos")
                        print(error)
                        loading = false
                    }
                }
            }
            .refreshable {
                do {
                    let result = try await appState.client.getVideos()
                    videos = result
                    loading = false
                    print("Finished loading")
                } catch {
                    print("Error getting videos")
                    print(error)
                    loading = false
                }
            }
        }
    }
}

#Preview {
    Explore()
        .environment(AppState())
}
