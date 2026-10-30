//
//  ClearTextButton.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 30.10.26.
//

import SwiftUI

struct ClearButtonModifier: ViewModifier {
  @Binding var text: String

  func body(content: Content) -> some View {
    ZStack(alignment: .trailing) {
      content

      if !text.isEmpty {
        Button(action: {
          self.text = ""
        }) {
          Image(systemName: "xmark.circle.fill")
            .foregroundColor(Color(UIColor.opaqueSeparator))
        }
        .padding(.trailing, 8)  // Adjust so it's not glued to the edge
        // Prevent the button from taking focus unexpectedly on macOS/tvOS
        .buttonStyle(PlainButtonStyle())
      }
    }
  }
}

extension View {
  /// Adds a clear button to any view that contains bound text (Binding).
  func clearButton(text: Binding<String>) -> some View {
    self.modifier(ClearButtonModifier(text: text))
  }
}
