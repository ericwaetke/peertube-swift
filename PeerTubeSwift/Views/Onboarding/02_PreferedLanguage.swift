//
//  02_PreferedLanguage.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 18.09.26.
//

import ComposableArchitecture
import FontKit
import SwiftUI

@Reducer
struct OnboardingPreferedLanguageFeature {
  @ObservableState
  struct State: Equatable {
    var languages: [Locale.Language] = Locale.Language.systemLanguages.filter { language in
      NSLocale.preferredLanguages.contains { preferedLanguage in
        language.minimalIdentifier == preferedLanguage
      }
    }

    @Presents var addLanguageSheet: OnboardingLanguageListFeature.State?
  }

  enum Action {
    case addLanguageButtonTapped
    case removeLanguageTapped(Locale.Language)
    case addLanguageSheet(PresentationAction<OnboardingLanguageListFeature.Action>)
    case dismissSheet
  }

  var body: some ReducerOf<Self> {
    Reduce { state, action in
      switch action {
      case .addLanguageButtonTapped:
        state.addLanguageSheet = OnboardingLanguageListFeature.State(
          alreadySelectedLanguages: state.languages)
        return .none
      case .removeLanguageTapped(let language):
        withAnimation {
          state.languages.removeAll { languageInArray in
            languageInArray == language
          }
        }
        return .none
      case .addLanguageSheet(.presented(.dismissButtonTapped)):
        return .send(.dismissSheet)
      case .addLanguageSheet(.presented(.languageTapped(let language))):
        // Check if the language is already in the selected languages array
        if !state.languages.contains(where: { $0 == language }) {
          // Add the language with an animation
          withAnimation {
            state.languages.append(language)
          }
        }
        return .send(.dismissSheet)
      case .addLanguageSheet(_):
        return .none
      case .dismissSheet:
        state.addLanguageSheet = nil
        return .none
      }
    }
    .ifLet(\.$addLanguageSheet, action: \.addLanguageSheet) {
      OnboardingLanguageListFeature()
    }
  }
}

struct OnboardingPreferedLanguageView: View {
  @Bindable var store: StoreOf<OnboardingPreferedLanguageFeature>

  var body: some View {
    VStack {
      Form {
        selectedLanguages
      }
    }
    .sheet(item: $store.scope(state: \.addLanguageSheet, action: \.addLanguageSheet)) {
      addLanguageSheet in
      OnboardingLanguageListView(store: addLanguageSheet)
        .presentationDetents([.large])
    }
    .navigationTitle("Select Your Preferred Languages")
  }

  let locale: Locale = .current
  @ViewBuilder
  var selectedLanguages: some View {
    Section {
      List {
        ForEach(store.state.languages, id: \.maximalIdentifier) { language in
          Button {
            store.send(.removeLanguageTapped(language))
          } label: {
            HStack {
              VStack(alignment: .leading) {
                Text(
                  locale.localizedString(forIdentifier: language.minimalIdentifier)
                    ?? "Unknown Language"
                )
                .font(CustomFont.inclusiveSansRegular.swiftUIFont(size: 17, relativeTo: .body))
                .foregroundStyle(Color.Label.primary)
              }
              Spacer()
              Text("Remove")
                .tint(Color.Label.destructive)
            }
          }
        }

        Button("Add Language …") {
          store.send(.addLanguageButtonTapped)
        }
      }
    } header: {
      VStack(alignment: .leading, spacing: 4) {
        if store.state.languages.count == 0 {
          sectionHeader
          Text(
            "There are no preferred languages selected. Content in all languages will be recommended."
          )
          .font(
            CustomFont.inclusiveSansRegular.swiftUIFont(size: 15, relativeTo: .subheadline)
          )
          .foregroundStyle(Color("Label/Secondary"))
          .transition(.blurReplace)
        } else {
          sectionHeader
        }
      }
    } footer: {
      Text(
        "Your video recommendations will be based on these languages. Videos in other languages will still be available."
      )
      .font(
        CustomFont.inclusiveSansRegular.swiftUIFont(size: 15, relativeTo: .subheadline)
      )
      .foregroundStyle(Color("Label/Secondary"))
    }

  }

  @ViewBuilder
  var sectionHeader: some View {
    HStack {
      Text("Selected Languages")
        .font(
          CustomFont.inclusiveSansSemiBold.swiftUIFont(size: 13, relativeTo: .footnote)
        )
        .textCase(.uppercase)
        .foregroundStyle(Color("Label/Secondary"))
      Spacer()
    }
  }
}

#Preview {
  NavigationStack {
    OnboardingPreferedLanguageView(
      store: Store(initialState: OnboardingPreferedLanguageFeature.State()) {
        OnboardingPreferedLanguageFeature()
      }
    )
  }
}
