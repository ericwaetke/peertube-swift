//
//  ListInfoPrimary.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 30.10.26.
//

import FontKit
import SwiftUI

struct ListInfoPrimary<LeadingImage: View, TrailingAction: View>: View {
  let leadingImage: LeadingImage?

  let topLine: String
  let bottomLine: String

  let trailingAction: TrailingAction

  var tapAction: () -> Void

  init(
    topLine: String,
    bottomLine: String,
    tapAction: @escaping () -> Void,
    @ViewBuilder leadingImage: () -> LeadingImage,
    @ViewBuilder trailingAction: () -> TrailingAction
  ) {
    self.topLine = topLine
    self.bottomLine = bottomLine
    self.leadingImage = leadingImage()
    self.trailingAction = trailingAction()
    self.tapAction = tapAction
  }

  init(
    topLine: String,
    bottomLine: String,
    tapAction: @escaping () -> Void,
    @ViewBuilder trailingAction: () -> TrailingAction
  ) {
    self.topLine = topLine
    self.bottomLine = bottomLine
    self.leadingImage = nil
    self.trailingAction = trailingAction()
    self.tapAction = tapAction
  }

  var body: some View {
    Button {
      tapAction()
    } label: {
      HStack(spacing: 8) {
        if let leadingImage = leadingImage {
          leadingImage
        }
        VStack(alignment: .leading) {
          Text(topLine)
            .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
            .lineLimit(1)
            .foregroundStyle(Color(uiColor: .label))
          Text(bottomLine)
            .font(
              CustomFont.inclusiveSansRegular.swiftUIFont(size: 15, relativeTo: .subheadline)
            )
            .scaledToFit()
            .lineLimit(1)
            .foregroundStyle(Color(uiColor: .secondaryLabel))
        }
        Spacer()
        trailingAction
      }
    }
  }
}

#Preview {
  ListInfoPrimary(topLine: "Top Line", bottomLine: "Bottom Line") {

  } leadingImage: {
    Text(")")
  } trailingAction: {
    Image(systemName: "chevron.right")
      .foregroundStyle(Color(uiColor: .tertiaryLabel))
  }
}
