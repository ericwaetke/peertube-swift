//
//  DisclosureGroupStyles.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 29.07.26.
//

import SwiftUI
import FontKit

struct InnerSectionDisclosureGroup: DisclosureGroupStyle {
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
                    Image(systemName: "chevron.right")
                        .font(.system(size: 13))
                        .rotationEffect(configuration.isExpanded ? .degrees(90) : .degrees(0))
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
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 16)
        .background(Color(red: 0.8823529412, green: 0.8823529412, blue: 0.8980392157))
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
                .frame(height: 10)
                .allowsHitTesting(false)
            }
    }
}

#Preview {
  ScrollView {
    VStack(alignment: .leading, spacing: 24) {
        DisclosureGroup("Continue Watching") {
            Text("Videoooo")
        }
        .disclosureGroupStyle(InnerSectionDisclosureGroup())
    }
    .padding()
  }
}
