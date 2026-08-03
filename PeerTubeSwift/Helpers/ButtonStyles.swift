//
//  ButtonStyles.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 28.07.26.
//

import SwiftUI

struct RiverTinted: ButtonStyle {
  func makeBody(configuration: ButtonStyleConfiguration) -> some View {
    configuration.label
      .padding()
      .background(Color(red: 0, green: 0, blue: 0.5))
      .foregroundStyle(Color.white)
      .clipShape(Capsule())
  }
}

struct RiverTertiary: ButtonStyle {
  func makeBody(configuration: ButtonStyleConfiguration) -> some View {
    configuration.label
          .padding(.horizontal, 10)
          .padding(.vertical, 4)
          .frame(height: 28)
      .background(Color(uiColor: .secondarySystemFill))
      .foregroundStyle(Color.labelSecondary)
      .clipShape(Capsule())
  }
}

#Preview {
  ScrollView {
      VStack(alignment: .leading, spacing: 24) {
        Text("RiverTertiary").font(.headline)
        Button("Press Me") {}
          .buttonStyle(RiverTertiary())
          Button {

          } label: {
            Image(systemName: "ellipsis")
          }
            .buttonStyle(RiverTertiary())
      }
      .padding()
    VStack(alignment: .leading, spacing: 24) {
      Text("RiverTinted").font(.headline)
      Button("Press Me") {}
        .buttonStyle(RiverTinted())
    }
    .padding()
  }
}
