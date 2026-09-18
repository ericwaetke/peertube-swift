//
//  03_LanguageList.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.09.26.
//

import ComposableArchitecture
import FontKit
import SwiftUI

@Reducer
struct OnboardingLanguageListFeature {
  @ObservableState
  struct State: Equatable {
    var alreadySelectedLanguages: [Locale.Language] = []
    var preferedLanguages: [Locale.Language]
    var availableLanguages: [Locale.Language]

    init(alreadySelectedLanguages: [Locale.Language] = []) {
      self.preferedLanguages = Locale.Language.systemLanguages.filter { language in
        NSLocale.preferredLanguages.contains { preferedLanguage in
          language.minimalIdentifier == preferedLanguage
            && !alreadySelectedLanguages.contains(where: { $0 == language })
        }
      }
      self.availableLanguages = Locale.Language.systemLanguages.filter { language in
        !alreadySelectedLanguages.contains(where: { $0 == language })
      }
    }
  }

  enum Action {
    case dismissButtonTapped
    case languageTapped(Locale.Language)
  }

  var body: some Reducer<State, Action> {
    Reduce { state, action in
      switch action {

      case .dismissButtonTapped:
        return .none
      case .languageTapped(_):
        return .none
      }
    }
  }
}

struct OnboardingLanguageListView: View {
  let store: StoreOf<OnboardingLanguageListFeature>
  let locale: Locale = .current

  var body: some View {

    NavigationStack {
      VStack {
        Form {
          if store.state.preferedLanguages.count > 0 {
            Section {
              List {
                ForEach(store.state.preferedLanguages, id: \.maximalIdentifier) { language in
                  Button {
                    store.send(.languageTapped(language))
                  } label: {
                    HStack {
                      VStack(alignment: .leading) {
                        Text(
                          locale.localizedString(forIdentifier: language.minimalIdentifier)
                            ?? "Unknown Language"
                        )
                        .font(
                          CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body)
                        )
                        .foregroundStyle(Color.Label.primary)
                      }
                      Spacer()
                      Image(systemName: "plus")
                    }
                  }
                }
              }
            } header: {
              HStack {
                Text("Recommended Languages")
                  .font(
                    CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
                  )
                  .textCase(.uppercase)
                  .foregroundStyle(Color("Label/Secondary"))
                Spacer()
              }
            }
          }
          Section {
            List {
              ForEach(store.state.availableLanguages, id: \.maximalIdentifier) { language in
                Button {
                  store.send(.languageTapped(language))
                } label: {
                  HStack {
                    VStack(alignment: .leading) {
                      Text(
                        locale.localizedString(forIdentifier: language.minimalIdentifier)
                          ?? "Unknown Language"
                      )
                      .font(
                        CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body)
                      )
                      .foregroundStyle(Color.Label.primary)
                    }
                    Spacer()
                    Image(systemName: "plus")
                  }
                }
              }
            }
          } header: {
            HStack {
              Text("Available Languages")
                .font(
                  CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
                )
                .textCase(.uppercase)
                .foregroundStyle(Color("Label/Secondary"))
              Spacer()
            }
          }
        }
      }
      .toolbar {
        if #available(iOS 26.0, *) {
          ToolbarItem(placement: .topBarLeading) {
            dismissButton
          }
          .sharedBackgroundVisibility(.hidden)
        } else {
          ToolbarItem(placement: .topBarLeading) {
            dismissButton
          }
        }
      }
      .navigationTitle("Select a Language")
      .navigationBarTitleDisplayMode(.inline)
    }
  }

  @ViewBuilder
  var dismissButton: some View {
    Button {
      store.send(.dismissButtonTapped)
    } label: {
      Image(systemName: "xmark")
    }
    .buttonStyle(RiverButtonToolbar(type: .gray))
  }
}

#Preview {
  NavigationStack {
    OnboardingLanguageListView(
      store: Store(initialState: OnboardingLanguageListFeature.State()) {
        OnboardingLanguageListFeature()
      }
    )
  }
}
