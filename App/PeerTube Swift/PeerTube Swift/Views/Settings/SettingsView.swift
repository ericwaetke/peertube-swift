//
//  SettingsView.swift
//  PeerTubeApp
//
//  Created on 2024-12-17.
//

import PeerTubeSwift
import SwiftUI

struct SettingsView: View {
    // MARK: - Properties

    @EnvironmentObject private var appState: AppState
    @State private var showingInstanceSelection = false
    @State private var showingAbout = false

    // MARK: - Body

    var body: some View {
        NavigationView {
            List {
                // Instance section
                instanceSection

                // Playback settings
                playbackSection

                // Subscriptions
                subscriptionsSection

                // Data and storage
                dataSection

                // Notifications
                notificationsSection

                // Appearance
                appearanceSection

                // About and support
                aboutSection
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
    }

    // MARK: - Instance Section

    private var instanceSection: some View {
        Section {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Current Instance")
                        .font(.headline)

                    if let instance = appState.currentInstance {
                        Text(instance.name)
                            .font(.subheadline)
                            .foregroundColor(.primary)

                        Text(instance.host)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    } else {
                        Text("No instance selected")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Button("Change") {
                    showingInstanceSelection = true
                }
                .font(.subheadline)
                .foregroundColor(.blue)
            }
            .padding(.vertical, 4)
        } header: {
            Text("PeerTube Instance")
        } footer: {
            Text(
                "Each PeerTube instance is independent with its own community, content, and rules.")
        }
    }

    // MARK: - Playback Section

    private var playbackSection: some View {
        Section {
            // Auto-play videos
            HStack {
                Image(systemName: "play.circle")
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Auto-play Videos")
                        .font(.body)

                    Text("Automatically start playing videos when opened")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("", isOn: $appState.autoPlayVideos)
                    .onChange(of: appState.autoPlayVideos) { _ in
                        appState.saveSettings()
                    }
            }

            // Default video quality
            HStack {
                Image(systemName: "tv")
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Default Video Quality")
                        .font(.body)

                    Text(appState.defaultVideoQuality.displayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Menu {
                    ForEach(VideoQuality.allCases, id: \.rawValue) { quality in
                        Button(quality.displayName) {
                            appState.defaultVideoQuality = quality
                            appState.saveSettings()
                        }
                    }
                } label: {
                    Text("Change")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }

            // WiFi only streaming
            HStack {
                Image(systemName: "wifi")
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Stream on WiFi Only")
                        .font(.body)

                    Text("Use cellular data only for low-quality streaming")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("", isOn: $appState.useWiFiOnly)
                    .onChange(of: appState.useWiFiOnly) { _ in
                        appState.saveSettings()
                    }
            }
        } header: {
            Text("Video Playback")
        }
    }

    // MARK: - Subscriptions Section

    private var subscriptionsSection: some View {
        Section {
            // Manage subscriptions
            Button(action: {
                appState.navigateTo(.subscriptionManagement)
            }) {
                HStack {
                    Image(systemName: "bell")
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Manage Subscriptions")
                            .font(.body)
                            .foregroundColor(.primary)

                        Text(
                            "\(appState.subscriptionService.subscriptionCount) channels subscribed"
                        )
                        .font(.caption)
                        .foregroundColor(.secondary)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Subscription feed settings
            HStack {
                Image(systemName: "list.dash")
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Auto-refresh Feed")
                        .font(.body)

                    Text("Automatically check for new videos")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("", isOn: .constant(true))
            }
        } header: {
            Text("Subscriptions")
        } footer: {
            Text("Manage your channel subscriptions and feed preferences.")
        }
    }

    // MARK: - Data Section

    private var dataSection: some View {
        Section {
            // Clear cache
            Button(action: clearCache) {
                HStack {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                        .frame(width: 24)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Clear Cache")
                            .font(.body)
                            .foregroundColor(.primary)

                        Text("Free up storage space")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Spacer()
                }
            }

            // Storage usage
            HStack {
                Image(systemName: "internaldrive")
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Storage Used")
                        .font(.body)

                    Text("~0 MB") // Placeholder
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        } header: {
            Text("Data & Storage")
        }
    }

    // MARK: - Notifications Section

    private var notificationsSection: some View {
        Section {
            // Enable notifications
            HStack {
                Image(systemName: "bell")
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Enable Notifications")
                        .font(.body)

                    Text("Get notified about new videos from subscriptions")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Toggle("", isOn: $appState.enableNotifications)
                    .onChange(of: appState.enableNotifications) { _ in
                        appState.saveSettings()
                    }
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text(
                "You can manage notification preferences for individual channels in your subscriptions."
            )
        }
    }

    // MARK: - Appearance Section

    private var appearanceSection: some View {
        Section {
            // Color scheme
            HStack {
                Image(systemName: "paintbrush")
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Appearance")
                        .font(.body)

                    Text(colorSchemeDisplayName)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Menu {
                    Button("Automatic") {
                        appState.colorScheme = nil
                        appState.saveSettings()
                    }

                    Button("Light") {
                        appState.colorScheme = .light
                        appState.saveSettings()
                    }

                    Button("Dark") {
                        appState.colorScheme = .dark
                        appState.saveSettings()
                    }
                } label: {
                    Text("Change")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
        } header: {
            Text("Appearance")
        }
    }

    // MARK: - About Section

    private var aboutSection: some View {
        Section {
            // About this app
            Button(action: { showingAbout = true }) {
                HStack {
                    Image(systemName: "info.circle")
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    Text("About PeerTube")
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Privacy policy
            Link(destination: URL(string: "https://joinpeertube.org/")!) {
                HStack {
                    Image(systemName: "hand.raised")
                        .foregroundColor(.blue)
                        .frame(width: 24)

                    Text("Learn About PeerTube")
                        .font(.body)
                        .foregroundColor(.primary)

                    Spacer()

                    Image(systemName: "arrow.up.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            // Version info
            HStack {
                Image(systemName: "app.badge")
                    .foregroundColor(.blue)
                    .frame(width: 24)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Version")
                        .font(.body)

                    Text("1.0.0 (1)") // Placeholder
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()
            }
        } header: {
            Text("About & Support")
        }
    }

    // MARK: - Computed Properties

    private var colorSchemeDisplayName: String {
        switch appState.colorScheme {
        case .light:
            return "Light"
        case .dark:
            return "Dark"
        case nil:
            return "Automatic"
        }
    }

    // MARK: - Actions

    private func clearCache() {
        // In a real implementation, this would clear cached videos, images, etc.
        // For now, just show a confirmation
    }
}

// MARK: - About View

struct AboutView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // App icon and title
                    VStack(spacing: 16) {
                        Image(systemName: "play.rectangle.fill")
                            .font(.system(size: 80))
                            .foregroundColor(.blue)

                        VStack(spacing: 8) {
                            Text("PeerTube")
                                .font(.title)
                                .fontWeight(.bold)

                            Text("Decentralized Video Platform")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                    }

                    // Description
                    VStack(alignment: .leading, spacing: 16) {
                        Text("About PeerTube")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(
                            "PeerTube is a decentralized video hosting network, based on free/libre software. Join the federation and take back control of your videos!"
                        )
                        .font(.body)

                        Text(
                            "This app allows you to browse and watch videos from any PeerTube instance, manage your subscriptions, and enjoy decentralized video content."
                        )
                        .font(.body)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Features
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Features")
                            .font(.title2)
                            .fontWeight(.semibold)

                        VStack(alignment: .leading, spacing: 12) {
                            FeatureRow(
                                icon: "globe",
                                title: "Multi-Instance Support",
                                description: "Connect to any PeerTube instance"
                            )

                            FeatureRow(
                                icon: "heart",
                                title: "Subscriptions",
                                description: "Follow channels and get notified of new videos"
                            )

                            FeatureRow(
                                icon: "play.rectangle",
                                title: "Video Streaming",
                                description: "High-quality video playback with adaptive streaming"
                            )

                            FeatureRow(
                                icon: "magnifyingglass",
                                title: "Search & Discovery",
                                description: "Find videos and channels across the federation"
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)

                    // Links
                    VStack(spacing: 12) {
                        Link(
                            "Learn More About PeerTube",
                            destination: URL(string: "https://joinpeertube.org/")!
                        )
                        .font(.headline)
                        .foregroundColor(.blue)

                        Link(
                            "Find PeerTube Instances",
                            destination: URL(string: "https://instances.joinpeertube.org/")!
                        )
                        .font(.subheadline)
                        .foregroundColor(.blue)
                    }

                    Spacer(minLength: 32)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
            }
            .navigationTitle("About")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Feature Row

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(.blue)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)

                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
    }
}

// MARK: - Preview

#if DEBUG
    struct SettingsView_Previews: PreviewProvider {
        static var previews: some View {
            Group {
                // Settings view
                SettingsView()
                    .environmentObject(AppState())
                    .previewDisplayName("Settings")

                // About view
                AboutView()
                    .previewDisplayName("About")
            }
        }
    }
#endif
