//
//  Explore.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 22.12.25.
//

import SwiftUI
import TubeSDK

struct Explore: View {
    @Environment(AppState.self) private var appState: AppState
    
    //    @State var videos: [InstanceVideoPair] = []
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
                            ForEach(appState.client.videoFeed.sorted(by: { lp, rp in
                                let lv = lp.video
                                let rv = rp.video
                                
                                guard let lPub = lv.publishedAt,
                                      let rPub = rv.publishedAt else {
                                    print("couldnt extract date to sort")
                                    return false
                                }
                                return lPub.timeIntervalSince1970 > rPub.timeIntervalSince1970
                            }), id: \.self) { pair in
                                VideoCard(host: pair.host, video: pair.video)
                                    .onTapGesture {
                                        appState.navigationPath.append(pair)
                                    }
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Explore")
            .navigationDestination(for: InstanceVideoPair.self) { pair in
                VideoDetails(host: pair.host, video: pair.video)
            }
            .onAppear {
                if appState.client.videoFeed.count > 0 { return }
                
                loading = true
                Task {
                    do {
                        try await appState.client.getVideos()
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
                    try await appState.client.getVideos()
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
