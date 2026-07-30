//
//  CategoryCard.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 30.07.26.
//

import SwiftUI

struct CategoryCard: View {
  let color: Color
  var body: some View {
    RoundedRectangle(cornerRadius: 20)
      .fill(color)
      .frame(height: 100)
  }
}

#Preview {
  CategoryCard(color: .blue)
}
