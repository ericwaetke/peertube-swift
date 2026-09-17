//
//  DisclosureGroupStyles.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 29.07.26.
//

import FontKit
import SwiftUI

struct ContentHeightKey: PreferenceKey {
  static let defaultValue: CGFloat = 0
  static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
    value = nextValue()
  }
}

struct InnerSectionDisclosureGroup: DisclosureGroupStyle {
  @State private var contentHeight: CGFloat = 0

  func makeBody(configuration: DisclosureGroupStyleConfiguration) -> some View {
    VStack {
      Button {
        withAnimation {
          configuration.isExpanded.toggle()
        }
      } label: {
        HStack(alignment: .center) {
          configuration.label
            .font(CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote))
            .textCase(.uppercase)
            .foregroundStyle(Color("Label/Secondary"))
          Image(systemName: "chevron.right")
            .font(.system(size: 13))
            .rotationEffect(configuration.isExpanded ? .degrees(90) : .degrees(0))
            .foregroundStyle(Color("Label/Secondary"))
          Spacer()
        }
        .padding(.horizontal, 16)
        .padding(.top, 8)
        .padding(8)
        .contentShape(Rectangle())
      }
      .buttonStyle(.plain)
      if configuration.isExpanded {
        configuration.content
          .transition(.blurReplace)
      }
    }
    .padding(.top, 8)
    .padding(.bottom, 16)
    .background(Color(uiColor: UIColor.systemFill).opacity(0.5))
    .overlay(alignment: .top) {
      // Top inset shadow
      LinearGradient(
        gradient: Gradient(stops: [
          .init(color: .black.opacity(0.10), location: 0),
          .init(color: .clear, location: 1),
        ]),
        startPoint: .top,
        endPoint: .bottom
      )
      .opacity(configuration.isExpanded ? 1 : 0)
      //      .animation(.smooth, value: configuration.isExpanded)
      .frame(height: 10)
      .allowsHitTesting(false)
    }
    .overlay(alignment: .bottom) {
      // Bottom inset shadow
      LinearGradient(
        gradient: Gradient(stops: [
          .init(color: .clear, location: 0),
          .init(color: .black.opacity(0.10), location: 1),
        ]),
        startPoint: .top,
        endPoint: .bottom
      )
      .opacity(configuration.isExpanded ? 1 : 0)
      //      .animation(.smooth, value: configuration.isExpanded)
      .frame(height: 10)
      .allowsHitTesting(false)
    }
  }
}

#Preview {
  ScrollView {
    VStack(alignment: .leading, spacing: 24) {
      DisclosureGroup("Continue Watching") {
        VStack {
          Text("Videoooo")
          Text("Hier ist dann ein weiteres Video mit ganz langem Titel")
          Text("Hier ist dann ein weiteres Video mit ganz langem Titel")
          Text("Hier ist dann ein weiteres Video mit ganz langem Titel")
          Text("Hier ist dann ein weiteres Video mit ganz langem Titel")
        }
      }
      .disclosureGroupStyle(InnerSectionDisclosureGroup())
    }
    .padding()
  }
}
