//
//  ViewsAndDate.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 30.07.26.
//

import FontKit
import SwiftUI

struct ViewsAndDate: View {
  let views: Int?
  let videoPublishDate: Date?
  let unitStyle: RelativeDateTimeFormatter.UnitsStyle

  var formatter: RelativeDateTimeFormatter {
    let formatter = RelativeDateTimeFormatter()
    //      if store.state.variant != .small {
    //        formatter.unitsStyle = .full
    //      } else {
    //
    //      }
    formatter.unitsStyle = unitStyle
    return formatter
  }

  var body: some View {
    HStack(spacing: 4) {
      if let views = views?.formatted(
        .number
          .locale(.autoupdatingCurrent)
          .notation(.compactName)
      ) {
        Text("\(views) Views")
          .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 13, relativeTo: .footnote))
          .lineLimit(1)
      }

      Text("·")
        .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 13, relativeTo: .footnote))

      if let publishDate = videoPublishDate {
        Text(formatter.localizedString(for: publishDate, relativeTo: Date.now))
          .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 13, relativeTo: .footnote))
          .lineLimit(1)
      }
    }
  }
}
