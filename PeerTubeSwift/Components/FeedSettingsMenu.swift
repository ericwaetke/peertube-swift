//
//  FeedSettingsMenu.swift
//  PeerTubeSwift
//

import SwiftUI
import TubeSDK

// MARK: - Shared Settings Menu
/// Shared settings menu component for feed tabs
struct FeedSettingsMenu: View {
  @Binding var searchText: String
  let session: UserSession?
  let onOpenSettings: () -> Void

  var body: some View {
    Menu {
      if let session = session {
        VStack(alignment: .leading) {
          Text(session.username)
            .font(.headline)
          Text(session.host)
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        Divider()
      } else {
        Text("Not logged in")
          .font(.headline)
      }

      Divider()

      Button {
        onOpenSettings()
      } label: {
        Label("Settings", systemImage: "gear")
      }
    } label: {
      if let session = session {
        AvatarView(
          url: session.avatarUrl,
          name: session.username,
          size: 32
        )
      } else {
        Image(systemName: "person.circle.fill")
          .resizable()
          .frame(width: 32, height: 32)
          .foregroundStyle(.secondary)
      }
    }
  }
}
