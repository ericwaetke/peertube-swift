//
//  04_Topics.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 21.09.26.
//

import ComposableArchitecture
import FontKit
import PeerSeekSDK
import SwiftUI

@Reducer
struct OnboardingTopicsFeature {
  @ObservableState
  struct State: Equatable {
    var selectedCategories: Set<PeerSeekSDK.Category> = []
  }

  enum Action {
    case tappedOnCategoryCard(PeerSeekSDK.Category)
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .tappedOnCategoryCard(let category):
        if state.selectedCategories.contains(category) {
          state.selectedCategories.remove(category)
          return .run { _ in
            await UIImpactFeedbackGenerator(style: .soft).impactOccurred()
          }
        } else {
          state.selectedCategories.insert(category)
          return .run { _ in
            await UIImpactFeedbackGenerator(style: .medium).impactOccurred()
          }
        }
      }
    }
  }
}

struct OnboardingTopicsView: View {
  let store: StoreOf<OnboardingTopicsFeature>

  var body: some View {
    ScrollView {
      //        Text(store.state.selectedCategories.count)
      LazyVGrid(columns: [GridItem(.adaptive(minimum: 170))]) {
        ForEach(Array(shownCategories.keys), id: \.self) { category in
          CategoryCard(category: category)
            .onTapGesture {
              store.send(.tappedOnCategoryCard(category))
            }
            .overlay(alignment: .topLeading) {
              ZStack {
                Circle()
                  .stroke(
                    Color.Label.secondary,
                    lineWidth: store.selectedCategories.contains(category) ? 0 : 1.5
                  )
                  .fill(
                    store.selectedCategories.contains(category)
                      ? Color.Label.action
                      : Color(uiColor: .tertiaryLabel)
                  )
                  .frame(height: 22)
                if store.selectedCategories.contains(category) {
                  Image(systemName: "checkmark")
                    .font(.system(size: 14.5))
                    .fontWeight(.semibold)
                    .foregroundStyle(.white)
                }
              }
              .padding(12)
            }
        }
      }
      .padding()
    }
  }

}

#Preview {
  NavigationStack {
    OnboardingTopicsView(
      store: Store(initialState: OnboardingTopicsFeature.State()) {
        OnboardingTopicsFeature()
      }
    )
  }
}
