//
//  PreferredLanguages.swift
//  PeerTubeSwift
//

import Foundation

extension Locale.Language {
  // Maps devices prefered languages to `systemLanguages` entries
  // as device-languages report as "en-US" for example, but we just
  // use the short identifier "en"
  static func defaultPreferredLanguages(
    preferred: [String] = NSLocale.preferredLanguages,
    system: [Locale.Language] = Locale.Language.systemLanguages
  ) -> [Locale.Language] {
    var result: [Locale.Language] = []
    for identifier in preferred {
      let wanted = Locale.Language(identifier: identifier)
      let match =
        system.first { $0.minimalIdentifier == wanted.minimalIdentifier }
        ?? system.first { $0.languageCode?.identifier == wanted.languageCode?.identifier }
      guard let match, !result.contains(match) else { continue }
      result.append(match)
    }
    return result
  }
}
