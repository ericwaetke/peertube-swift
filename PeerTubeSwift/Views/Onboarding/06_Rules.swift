//
//  06_Rules.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 02.10.26.
//

import ComposableArchitecture
import FontKit
import PeerSeekSDK
import SwiftUI
import TubeSDK

@Reducer
struct OnboardingRulesFeature {
  @ObservableState
  struct State: Equatable {
    var acceptedGuidelines = false
    var acceptedPrivacyPolicy = false
  }

  enum Action {
    case acceptGuidelinesToggleTapped(Bool)
    case acceptPrivacyPolicyToggleTapped(Bool)
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {
      case .acceptGuidelinesToggleTapped(let newValue):
        state.acceptedGuidelines = newValue
        return .none
      case .acceptPrivacyPolicyToggleTapped(let newValue):
        state.acceptedPrivacyPolicy = newValue
        return .none
      }
    }
  }
}

struct OnboardingRulesView: View {
  @Bindable var store: StoreOf<OnboardingRulesFeature>

  @State var isOn = false

  var body: some View {
    Form {
      Section {
        ScrollView(.horizontal) {
          HStack {
            ForEach(1..<5) { i in
              VStack(alignment: .leading) {
                Text("\(i)")
                  .font(CustomFont.fjallaOne.swiftUIFont(size: 34, relativeTo: .largeTitle))
                Text(
                  "No bigotry - including racism, sexism, ableism, homophobia, transphobia, or xenophobia."
                )
                .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
                .foregroundStyle(Color.Label.primary)
              }
              .padding(.top, 44)
              .padding(.horizontal, 16)
              .padding(.bottom, 20)
              .containerRelativeFrame(.horizontal, count: 3, span: 2, spacing: 10)
              .background(
                RoundedRectangle(cornerRadius: 21)
                  .fill(.white)
                  .stroke(.separator, lineWidth: 0.33)
              )
            }
          }
        }
      } footer: {
        Text("If you see something against the rules, please report it.")
          .padding(.horizontal, 16)  // TODO: replace with something not hardcoded
          .font(
            CustomFont.inclusiveSansRegular.swiftUIFont(size: 15, relativeTo: .subheadline)
          )
          .foregroundStyle(Color("Label/Secondary"))
      }
      .listRowInsets(
        .init(
          top: 0,
          leading: 0,
          bottom: 8,
          trailing: 0)
      )
      .listRowBackground(Color.clear)

      Toggle(isOn: $store.acceptedGuidelines.sending(\.acceptGuidelinesToggleTapped)) {
        Text("Accept Guidelines")
      }

      Section {
        Toggle(isOn: $isOn) {
          Text("Privacy Policy")
        }
        Toggle(isOn: $store.acceptedPrivacyPolicy.sending(\.acceptPrivacyPolicyToggleTapped)) {
          Text("Taken Note Of")
        }
      } header: {
        Text("Data Privacy")
          .textCase(.uppercase)
          .font(
            CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
          )
          .foregroundStyle(Color.Label.secondary)
      }
    }
  }
}

#Preview {
  OnboardingRulesView(
    store: Store(initialState: OnboardingRulesFeature.State()) {
      OnboardingRulesFeature()
    }
  )
}
