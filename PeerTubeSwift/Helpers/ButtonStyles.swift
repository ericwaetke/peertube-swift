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

#Preview {
  ScrollView {
    VStack(alignment: .leading, spacing: 24) {
      Text("RiverTinted").font(.headline)
      Button("Press Me") {}
        .buttonStyle(RiverTinted())
    }
    .padding()
  }
}
