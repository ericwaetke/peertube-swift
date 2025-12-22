//
//  ContentView.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.12.25.
//

import SwiftUI
import TubeSDK

struct ContentView: View {
    @Environment(AppState.self) private var appState: AppState
    @StateObject private var networkMonitor = NetworkMonitor()
    
    
    @State var videoDetails: VideoDetails?
    
    var body: some View {
        @Bindable var appState = appState
        TabView(selection: $appState.selectedTab) {
            // Browse Tab
            Explore()
            .tabItem {
                Label(AppState.Tab.browse.rawValue, systemImage: AppState.Tab.browse.systemImage)
            }
            .tag(AppState.Tab.browse)
            
            // Subscriptions Tab
            NavigationStack {
                VStack(spacing: 12) {
                    Text("Subscriptions")
                        .font(.title2)
                    //					Text("Count: \(appState.subscriptionService.subscriptionCount)")
                }
                .padding()
                .navigationTitle("Subscriptions")
            }
            .tabItem {
                Label(
                    AppState.Tab.subscriptions.rawValue,
                    systemImage: AppState.Tab.subscriptions.systemImage)
            }
            .tag(AppState.Tab.subscriptions)
            
            // Settings Tab
            NavigationStack {
                Form {
                    Section(header: Text("Playback")) {
                        Toggle("Auto-play videos", isOn: $appState.autoPlayVideos)
                        Picker("Default quality", selection: $appState.defaultVideoQuality) {
                            ForEach(VideoQuality.allCases, id: \.self) { quality in
                                Text(quality.displayName).tag(quality)
                            }
                        }
                    }
                    Section(header: Text("Network")) {
                        Toggle("Use WiFi only", isOn: $appState.useWiFiOnly)
                    }
                    Section(header: Text("Notifications")) {
                        Toggle("Enable notifications", isOn: $appState.enableNotifications)
                    }
                }
                .navigationTitle("Settings")
            }
            .tabItem {
                Label(
                    AppState.Tab.settings.rawValue, systemImage: AppState.Tab.settings.systemImage)
            }
            .tag(AppState.Tab.settings)
        }
        .onAppear {
            networkMonitor.startMonitoring()
        }
    }
}

#Preview {
    ContentView()
        .environment(AppState())
}
