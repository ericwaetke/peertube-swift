//
//  CategoryCard.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 30.07.26.
//

import SwiftUI
import PeerSeekSDK
import FontKit

struct CategoryMap {
    let color: Color
    let symbol: String
}

let shownCategories: [PeerSeekSDK.Category: CategoryMap] = [
    .activism: CategoryMap(color: Color.Category.activism, symbol: "megaphone.fill"),
    .animals: CategoryMap(color: Color.Category.animals, symbol: "cat.fill"),
    .art: CategoryMap(color: Color.Category.art, symbol: "paintpalette.fill"),
    .comedy: CategoryMap(color: Color.Category.comedy, symbol: "theatermasks.fill"),
    .education: CategoryMap(color: Color.Category.education, symbol: "graduationcap.fill"),
    
        .entertainment: CategoryMap(color: Color.Category.entertainment, symbol: "popcorn.fill"),
    .films: CategoryMap(color: Color.Category.films, symbol: "film.fill"),
    .food: CategoryMap(color: Color.Category.food, symbol: "carrot.fill"),
    .gaming: CategoryMap(color: Color.Category.gaming, symbol: "gamecontroller.fill"),
    .howTo: CategoryMap(color: Color.Category.howTo, symbol: "list.bullet.clipboard.fill"),
    .kids: CategoryMap(color: Color.Category.kids, symbol: "teddybear.fill"),
    .music: CategoryMap(color: Color.Category.music, symbol: "music.note"),
    
    .newsPolitics: CategoryMap(color: Color.Category.newsPolitics, symbol: "newspaper.fill"),
    
        .people: CategoryMap(color: Color.Category.people, symbol: "person.2.fill"),
    .scienceTechnology: CategoryMap(color: Color.Category.scienceTechnology, symbol: "atom"),
    .sports: CategoryMap(color: Color.Category.sports, symbol: "figure.volleyball"),
    .travels: CategoryMap(color: Color.Category.travels, symbol: "airplane.up.forward"),
    .vehicles: CategoryMap(color: Color.Category.education, symbol: "car.fill"),
]

struct CategoryCard: View {
    let category: PeerSeekSDK.Category
    let data: CategoryMap
    
    init(category: PeerSeekSDK.Category) {
        self.category = category
        self.data = shownCategories[category] ?? CategoryMap(color: .red, symbol: "warning")
    }
    
  var body: some View {
      HStack(alignment: .bottom) {
          VStack (alignment: .trailing){
              Spacer()
              Text(category.rawValue)
                  .font(CustomFont.fjallaOne.swiftUIFont(size: 22, relativeTo: .title2))
                  .padding(.horizontal, 12)
                  .padding(.vertical, 10)
          }
          Spacer()
      }
      .frame(height: 100)
      .background {
          HStack {
              Spacer()
              Image(systemName: data.symbol)
                  .foregroundStyle(Color.Label.primary)
                  .blendMode(.overlay)
                  .font(.system(size: 72))
                  .rotationEffect(.degrees(-7))
          }
      }
      .clipShape(.rect(cornerRadius: 20))
      .background {
          RoundedRectangle(cornerRadius: 20)
              .fill(data.color.gradient
                .shadow(
                    .inner(color: Color.black.opacity(0.25), radius: 2, y: -2)
                  )
                    .blendMode(.plusDarker)
                    .shadow(.drop(color: Color.black.opacity(0.2), radius: 2, y: 2))
              )
              .stroke(.separator, lineWidth: 0.3)
      }
//      .background(data.color.gradient)
//      .overlay(alignment: .bottom) {
//          LinearGradient(
//            gradient: Gradient(stops: [
//                .init(color: .clear, location: 0),
//                .init(color: .black.opacity(0.25), location: 0.8),
//            ]),
//            startPoint: .top,
//            endPoint: .bottom
//          )
//          .frame(height: 4)
//      }
      
  }
}

#Preview {
    CategoryCard(category: .newsPolitics)
}
