import Foundation

/// Turns PeerTube's comment/description text — markdown mixed with the HTML that
/// federated servers send — into a flat list of ``RichTextRenderer/Frag`` values.
///
/// Tag handling follows what PeerTube's web client renders: block tags become
/// paragraph/line breaks, `<li>` becomes a list marker, `<strong>`/`<em>` become
/// styles, mention anchors are highlighted (not linked), other anchors become
/// links, and everything else is stripped.
enum RichTextHTMLParser {
  enum Token {
    case text(String)
    case open(name: String, attributes: [String: String], isSelfClosing: Bool)
    case close(name: String)
  }

  // MARK: - Tokenizing

  static func tokenize(_ source: String) -> [Token] {
    var tokens: [Token] = []
    var text = ""
    let characters = Array(source)
    var index = 0

    func flushText() {
      if !text.isEmpty {
        tokens.append(.text(text))
        text = ""
      }
    }

    while index < characters.count {
      guard characters[index] == "<" else {
        text.append(characters[index])
        index += 1
        continue
      }

      // HTML comment: skip entirely.
      if index + 3 < characters.count, characters[index + 1] == "!",
        characters[index + 2] == "-", characters[index + 3] == "-"
      {
        if let end = find("-->", in: characters, from: index + 4) {
          flushText()
          index = end + 3
          continue
        }
      }

      // Close tag: `</name>`
      if index + 1 < characters.count, characters[index + 1] == "/",
        let parsed = parseCloseTag(characters, at: index)
      {
        flushText()
        tokens.append(.close(name: parsed.name))
        index = parsed.end
        continue
      }

      // Open tag: `<name …>` — only when the name is followed by a plausible
      // tag boundary, so `<3`, `<https://…>` stay literal text.
      if index + 1 < characters.count, isLetter(characters[index + 1]),
        let parsed = parseOpenTag(characters, at: index)
      {
        flushText()
        tokens.append(
          .open(
            name: parsed.name, attributes: parsed.attributes, isSelfClosing: parsed.isSelfClosing))
        index = parsed.end
        continue
      }

      text.append("<")
      index += 1
    }
    flushText()
    return tokens
  }

  private static func parseCloseTag(_ characters: [Character], at start: Int) -> (
    name: String, end: Int
  )? {
    var index = start + 2
    let nameStart = index
    while index < characters.count, isTagNameCharacter(characters[index]) { index += 1 }
    guard index > nameStart, index < characters.count, characters[index] == ">" else { return nil }
    let name = String(characters[nameStart..<index]).lowercased()
    return (name, index + 1)
  }

  private static func parseOpenTag(
    _ characters: [Character], at start: Int
  ) -> (name: String, attributes: [String: String], isSelfClosing: Bool, end: Int)? {
    var index = start + 1
    let nameStart = index
    while index < characters.count, isTagNameCharacter(characters[index]) { index += 1 }
    guard index > nameStart else { return nil }
    let name = String(characters[nameStart..<index]).lowercased()
    guard index < characters.count else { return nil }
    // A real tag's name is followed by `>`, `/` or whitespace — otherwise
    // (`<https://…>`, `<3`) this is not a tag at all.
    guard characters[index] == ">" || characters[index] == "/" || characters[index].isWhitespace
    else { return nil }

    var attributes: [String: String] = [:]
    var isSelfClosing = false

    while index < characters.count {
      // Skip whitespace.
      while index < characters.count, characters[index].isWhitespace { index += 1 }
      guard index < characters.count else { return nil }

      if characters[index] == ">" {
        return (name, attributes, isSelfClosing, index + 1)
      }
      if characters[index] == "/" {
        isSelfClosing = true
        index += 1
        continue
      }

      // Attribute name.
      let attributeStart = index
      while index < characters.count, !characters[index].isWhitespace,
        characters[index] != "=", characters[index] != ">", characters[index] != "/"
      {
        index += 1
      }
      guard index > attributeStart else { return nil }
      let attributeName = String(characters[attributeStart..<index]).lowercased()

      while index < characters.count, characters[index].isWhitespace { index += 1 }
      var value = ""
      if index < characters.count, characters[index] == "=" {
        index += 1
        while index < characters.count, characters[index].isWhitespace { index += 1 }
        guard index < characters.count else { return nil }
        if characters[index] == "\"" || characters[index] == "'" {
          let quote = characters[index]
          index += 1
          let valueStart = index
          while index < characters.count, characters[index] != quote { index += 1 }
          guard index < characters.count else { return nil }
          value = String(characters[valueStart..<index])
          index += 1
        } else {
          let valueStart = index
          while index < characters.count, !characters[index].isWhitespace,
            characters[index] != ">"
          {
            index += 1
          }
          value = String(characters[valueStart..<index])
        }
      }
      attributes[attributeName] = decodeEntities(value)
    }
    return nil
  }

  private static func find(_ needle: String, in characters: [Character], from start: Int) -> Int? {
    let needle = Array(needle)
    guard start < characters.count else { return nil }
    var index = start
    while index + needle.count <= characters.count {
      if Array(characters[index..<(index + needle.count)]) == needle { return index }
      index += 1
    }
    return nil
  }

  private static func isLetter(_ character: Character) -> Bool {
    character.unicodeScalars.contains { $0.properties.isAlphabetic }
  }

  private static func isTagNameCharacter(_ character: Character) -> Bool {
    guard character.isASCII else { return false }
    return character.isLetter || character.isNumber || character == "-"
  }

  // MARK: - Fragment building

  private enum ListKind {
    case bullet
    case ordered(Int)
  }

  private enum AnchorContext {
    case mention(String)
    case link(URL)
    case plain
  }

  static func fragments(from tokens: [Token]) -> [RichTextRenderer.Frag] {
    var frags: [RichTextRenderer.Frag] = []
    var styles: Set<RichTextRenderer.Style> = []
    var styleStack: [Set<RichTextRenderer.Style>] = []
    var listStack: [ListKind] = []
    var anchorStack: [AnchorContext] = []

    func pushBreak(_ count: Int) {
      if let last = frags.last, last.breaks > 0 {
        frags[frags.count - 1].breaks = min(2, last.breaks + count)
      } else {
        frags.append(RichTextRenderer.Frag(breaks: count))
      }
    }

    func emitContent(_ text: String) {
      if case .link(let url) = anchorStack.last {
        frags.append(RichTextRenderer.Frag(text: text, link: url, styles: styles, mode: .label))
      } else {
        frags.append(RichTextRenderer.Frag(text: text, styles: styles, mode: .full))
      }
    }

    func pushText(_ string: String) {
      var segment = ""
      var iterator = string.makeIterator()
      var pending = iterator.next()
      while let character = pending {
        if character == "\n" {
          var newlines = 0
          while let next = pending, next == "\n" {
            newlines += 1
            pending = iterator.next()
          }
          if !segment.isEmpty {
            emitContent(segment)
            segment = ""
          }
          pushBreak(newlines >= 2 ? 2 : 1)
        } else {
          segment.append(character)
          pending = iterator.next()
        }
      }
      if !segment.isEmpty { emitContent(segment) }
    }

    func emitText(_ raw: String) {
      let decoded = decodeEntities(raw)
      guard !decoded.isEmpty else { return }
      if let top = anchorStack.last, case .mention(let buffer) = top {
        anchorStack[anchorStack.count - 1] = .mention(buffer + decoded)
        return
      }
      pushText(decoded)
    }

    func popAnchor() {
      guard let popped = anchorStack.popLast() else { return }
      if case .mention(let buffer) = popped, !buffer.isEmpty {
        frags.append(
          RichTextRenderer.Frag(text: buffer, mention: buffer, styles: styles, mode: .raw))
      }
    }

    for token in tokens {
      switch token {
      case .text(let text):
        emitText(text)

      case .open(let name, let attributes, _):
        switch name {
        case "br":
          pushBreak(1)
        case "p", "div", "blockquote", "section", "article", "header", "footer",
          "figure", "figcaption", "pre", "hr", "h1", "h2", "h3", "h4", "h5", "h6":
          pushBreak(2)
        case "ul":
          pushBreak(2)
          listStack.append(.bullet)
        case "ol":
          pushBreak(2)
          listStack.append(.ordered(0))
        case "li":
          pushBreak(1)
          let marker: String
          if let kind = listStack.last {
            switch kind {
            case .bullet:
              marker = "• "
            case .ordered(let number):
              let next = number + 1
              listStack[listStack.count - 1] = .ordered(next)
              marker = "\(next). "
            }
          } else {
            marker = "• "
          }
          frags.append(RichTextRenderer.Frag(text: marker, mode: .raw))
        case "strong", "b":
          styleStack.append(styles)
          styles.insert(.bold)
        case "em", "i":
          styleStack.append(styles)
          styles.insert(.italic)
        case "code":
          styleStack.append(styles)
          styles.insert(.code)
        case "a":
          let classNames = (attributes["class"] ?? "").lowercased()
          if classNames.contains("mention"), !classNames.contains("hashtag") {
            anchorStack.append(.mention(""))
          } else if let href = attributes["href"], let url = validatedLink(href) {
            anchorStack.append(.link(url))
          } else {
            anchorStack.append(.plain)
          }
        default:
          break  // Unknown/transparent tags are stripped.
        }

      case .close(let name):
        switch name {
        case "p", "div", "blockquote", "section", "article", "header", "footer",
          "figure", "figcaption", "pre", "hr", "h1", "h2", "h3", "h4", "h5", "h6":
          pushBreak(2)
        case "ul", "ol":
          if !listStack.isEmpty { listStack.removeLast() }
          pushBreak(2)
        case "li":
          break
        case "strong", "b", "em", "i", "code":
          if let previous = styleStack.popLast() { styles = previous }
        case "a":
          popAnchor()
        default:
          break
        }
      }
    }
    return frags
  }

  // MARK: - URLs & entities

  /// Absolute http(s) links only — relative and exotic-scheme `href`s are dropped.
  static func validatedLink(_ href: String) -> URL? {
    let decoded = decodeEntities(href)
    guard let url = URL(string: decoded),
      let scheme = url.scheme?.lowercased(),
      scheme == "http" || scheme == "https",
      url.host?.isEmpty == false
    else { return nil }
    return url
  }

  static let entityRegex = try? NSRegularExpression(
    pattern: "&(?:#(?:x[0-9a-fA-F]+|[0-9]+)|[a-zA-Z][a-zA-Z0-9]*);")

  static func decodeEntities(_ string: String) -> String {
    guard string.contains("&"), let regex = entityRegex else { return string }
    let results = regex.matches(in: string, range: NSRange(location: 0, length: string.utf16.count))
    guard !results.isEmpty else { return string }

    var output = ""
    var cursor = string.startIndex
    for result in results {
      guard let range = Range(result.range, in: string) else { continue }
      guard let decoded = decodeEntity(String(string[range])) else { continue }
      output += string[cursor..<range.lowerBound]
      output += decoded
      cursor = range.upperBound
    }
    output += string[cursor...]
    return output
  }

  private static func decodeEntity(_ entity: String) -> String? {
    let body = entity.dropFirst().dropLast()  // strip `&` and `;`
    guard body.hasPrefix("#") else { return namedEntities[String(body)] }

    let digits = body.dropFirst()
    let value: UInt32?
    if let first = digits.first, first == "x" || first == "X" {
      value = UInt32(digits.dropFirst(), radix: 16)
    } else {
      value = UInt32(digits)
    }
    guard let value, value > 0, let scalar = Unicode.Scalar(value) else { return nil }
    return String(Character(scalar))
  }

  private static let namedEntities: [String: String] = [
    "amp": "&", "lt": "<", "gt": ">", "quot": "\"", "apos": "'", "nbsp": "\u{00A0}",
    "shy": "\u{00AD}", "macr": "¯", "deg": "°", "plusmn": "±", "times": "×",
    "divide": "÷", "frac12": "½", "frac14": "¼", "frac34": "¾", "micro": "µ",
    "sup1": "¹", "sup2": "²", "sup3": "³", "ordf": "ª", "ordm": "º", "not": "¬",
    "sect": "§", "para": "¶", "middot": "·", "bull": "•", "hellip": "…",
    "prime": "′", "Prime": "″", "permil": "‰", "lsaquo": "‹", "rsaquo": "›",
    "copy": "©", "reg": "®", "trade": "™",
    "ensp": "\u{2002}", "emsp": "\u{2003}", "thinsp": "\u{2009}",
    "zwnj": "\u{200C}", "zwj": "\u{200D}", "lrm": "\u{200E}", "rlm": "\u{200F}",
    "ndash": "–", "mdash": "—", "lsquo": "‘", "rsquo": "’", "sbquo": "‚",
    "ldquo": "“", "rdquo": "”", "bdquo": "„",
    "laquo": "«", "raquo": "»", "iexcl": "¡", "iquest": "¿", "cent": "¢",
    "pound": "£", "curren": "¤", "yen": "¥", "euro": "€",
    "larr": "←", "uarr": "↑", "rarr": "→", "darr": "↓",
    "lArr": "⇐", "uArr": "⇑", "rArr": "⇒", "dArr": "⇓",
    "harr": "↔", "hArr": "⇔", "crarr": "↵",
    "forall": "∀", "part": "∂", "exist": "∃", "empty": "∅",
    "nabla": "∇", "isin": "∈", "notin": "∉", "ni": "∋",
    "prod": "∏", "sum": "∑", "minus": "−", "lowast": "∗",
    "radic": "√", "prop": "∝", "infin": "∞", "ang": "∠",
    "and": "∧", "or": "∨", "cap": "∩", "cup": "∪",
    "int": "∫", "there4": "∴", "sim": "∼", "cong": "≅",
    "asymp": "≈", "ne": "≠", "equiv": "≡", "le": "≤", "ge": "≥",
    "sub": "⊂", "sup": "⊃", "sube": "⊆", "supe": "⊇",
    "oplus": "⊕", "otimes": "⊗", "perp": "⊥", "sdot": "⋅",
    "alpha": "α", "beta": "β", "gamma": "γ", "delta": "δ",
    "epsilon": "ε", "zeta": "ζ", "eta": "η", "theta": "θ",
    "lambda": "λ", "mu": "μ", "pi": "π", "rho": "ρ",
    "sigma": "σ", "tau": "τ", "phi": "φ", "chi": "χ",
    "psi": "ψ", "omega": "ω",
    "Gamma": "Γ", "Delta": "Δ", "Theta": "Θ", "Lambda": "Λ",
    "Pi": "Π", "Sigma": "Σ", "Phi": "Φ", "Psi": "Ψ", "Omega": "Ω",
    "sigmaf": "ς", "upsih": "ϒ", "thetasym": "ϑ",
    "piv": "ϖ", "oline": "‾",
    "frasl": "⁄", "weierp": "℘", "image": "ℑ", "real": "ℜ",
    "alefsym": "ℵ", "loz": "◊", "spades": "♠", "clubs": "♣",
    "hearts": "♥", "diams": "♦", "check": "✓", "cross": "✗",
    "star": "☆", "starf": "★",
  ]
}
