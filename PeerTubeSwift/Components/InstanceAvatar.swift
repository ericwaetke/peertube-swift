//
//  InstanceAvatar.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 30.10.26.
//

import SwiftUI

struct InstanceAvatar: View {
  let url: URL
  let size: CGFloat

  var body: some View {
    AsyncImage(url: url) { image in
      image.resizable()
    } placeholder: {
      ProgressView()
        .frame(width: 12, height: 12)
    }
    .frame(width: size, height: size)
    .foregroundStyle(.black)
    .frame(width: size, height: size)
    .background(.white)
    .clipShape(.rect(cornerRadius: 7))
    .rotationEffect(Angle(degrees: -3))
    .shadow(radius: 2)
  }
}

#Preview {
  InstanceAvatar(
    url: URL(
      string: "https://peertube.wtf/lazy-static/avatars/c8d8d77d-6761-4fcc-a83c-32dfea8c7777.png")!,
    size: 32
  )
  InstanceAvatar(
    url: URL(
      string: "https://peertube.wtf/lazy-static/avatars/c8d8d77d-6761-4fcc-a83c-32dfea8c7777.png")!,
    size: 20
  )
}
