//
//  Quotations.swift
//  PeerTubeSwift
//
//  Created by Eric Wätke on 03.08.26.
//

import Foundation

extension Locale {
    var quotationMarks: (open: String, close: String) {
        switch language.languageCode?.identifier {
        case "de":
            return ("„", "“")
        case "fr":
            return ("«\u{00A0}", "\u{00A0}»")
        case "ja":
            return ("「", "」")
        default:
            return ("“", "”")
        }
    }
}

extension String {
    func quoted(locale: Locale = .current) -> String {
        let q = locale.quotationMarks
        return "\(q.open)\(self)\(q.close)"
    }
}
