import Foundation

/// Markdown/URL/mention/timestamp/emoji passes over the fragments produced by
/// ``RichTextHTMLParser``, mirroring PeerTube's web pipeline:
/// markdown links and autolinks first, then bare URLs (linkify), then `@mentions`,
/// then `1:23` seek timestamps, then emoji — emphasis is applied later, over the
/// assembled text.
extension RichTextRenderer {
  static func process(_ frags: [Frag]) -> [Frag] {
    var out: [Frag] = []
    var atLineStart = true
    for frag in frags {
      if frag.breaks > 0 {
        out.append(frag)
        atLineStart = true
        continue
      }
      switch frag.mode {
      case .raw:
        out.append(frag)
        atLineStart = false
      case .label:
        var piece = frag
        piece.text = replaceEmoji(frag.text)
        out.append(piece)
        atLineStart = false
      case .full:
        var pieces = [frag]
        if atLineStart { pieces = splitListMarker(pieces) }
        pieces = splitMarkdownLinks(pieces)
        pieces = splitAutolinks(pieces)
        pieces = splitURLs(pieces)
        pieces = splitMentions(pieces)
        pieces = splitTimestamps(pieces)
        out.append(contentsOf: applyEmoji(pieces))
        atLineStart = false
      }
    }
    return out
  }

  // MARK: - Slicing helper

  /// Splits `.full` fragments around accepted regex matches. Rejected matches stay
  /// in the surrounding plain text (so `[x](javascript:…)` still unwraps its label,
  /// while a bad autolink stays literal).
  private static func splitFull(
    _ frags: [Frag],
    using regex: NSRegularExpression?,
    accept: (NSTextCheckingResult, String) -> Bool,
    produce: (NSTextCheckingResult, String, Frag) -> [Frag]
  ) -> [Frag] {
    guard let regex else { return frags }
    var out: [Frag] = []
    for frag in frags {
      guard frag.mode == .full, !frag.text.isEmpty else {
        out.append(frag)
        continue
      }
      let text = frag.text
      let results = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
      var cursor = text.startIndex
      var acceptedAny = false
      for result in results {
        guard let matchRange = Range(result.range, in: text), matchRange.lowerBound >= cursor
        else { continue }
        guard accept(result, text) else { continue }
        if matchRange.lowerBound > cursor {
          var chunk = frag
          chunk.text = String(text[cursor..<matchRange.lowerBound])
          out.append(chunk)
        }
        out.append(contentsOf: produce(result, text, frag))
        cursor = matchRange.upperBound
        acceptedAny = true
      }
      guard acceptedAny else {
        out.append(frag)
        continue
      }
      if cursor < text.endIndex {
        var chunk = frag
        chunk.text = String(text[cursor...])
        out.append(chunk)
      }
    }
    return out
  }

  // MARK: - Lists

  private static let listMarkerRegex = try? NSRegularExpression(
    pattern: #"^[ \t]*([-*+]|\d{1,9}\.)[ \t]+"#)

  private static func splitListMarker(_ frags: [Frag]) -> [Frag] {
    guard let regex = listMarkerRegex, let first = frags.first, first.mode == .full,
      !first.text.isEmpty
    else { return frags }
    let text = first.text
    guard
      let match = regex.firstMatch(
        in: text, range: NSRange(location: 0, length: text.utf16.count)),
      let matchRange = Range(match.range, in: text),
      let tokenRange = Range(match.range(at: 1), in: text)
    else { return frags }

    let token = String(text[tokenRange])
    let marker = token.hasSuffix(".") ? "\(token) " : "• "
    var rest = first
    rest.text = String(text[matchRange.upperBound...])
    var pieces = [Frag(text: marker, mode: .raw)]
    if !rest.text.isEmpty { pieces.append(rest) }
    return pieces
  }

  // MARK: - Markdown links

  private static let markdownLinkRegex = try? NSRegularExpression(
    pattern: #"\[([^\]]*)\]\(\s*((?:[^()]|\([^()]*\))*)\s*\)"#)

  private static func splitMarkdownLinks(_ frags: [Frag]) -> [Frag] {
    splitFull(frags, using: markdownLinkRegex, accept: { _, _ in true }) { result, text, frag in
      guard let labelRange = Range(result.range(at: 1), in: text) else { return [] }
      let destination: String
      if let destRange = Range(result.range(at: 2), in: text) {
        destination = String(text[destRange]).trimmingCharacters(in: .whitespacesAndNewlines)
      } else {
        destination = ""
      }
      var label = frag
      label.text = String(text[labelRange])
      label.mode = .label
      label.link = RichTextHTMLParser.validatedLink(destination)
      label.mention = nil
      return [label]
    }
  }

  // MARK: - Autolinks (`<https://…>`)

  private static let autolinkRegex = try? NSRegularExpression(
    pattern: #"<([a-zA-Z][a-zA-Z0-9+.\-]*:[^<>\s]+)>"#)

  private static func splitAutolinks(_ frags: [Frag]) -> [Frag] {
    splitFull(
      frags, using: autolinkRegex,
      accept: { result, text in
        guard let range = Range(result.range(at: 1), in: text) else { return false }
        return RichTextHTMLParser.validatedLink(String(text[range])) != nil
      }
    ) { result, text, frag in
      let range = Range(result.range(at: 1), in: text)!
      let inner = String(text[range])
      var link = frag
      link.text = inner
      link.mode = .raw
      link.link = RichTextHTMLParser.validatedLink(inner)
      link.mention = nil
      return [link]
    }
  }

  // MARK: - Bare URLs (linkify)

  private static let urlRegex = try? NSRegularExpression(
    pattern:
      #"(?i)(https?://[^\s<>"'`]+|(?<![\w@/.])(?:[a-z0-9](?:[-a-z0-9]*[a-z0-9])?\.)+[a-z]{2,}(?::\d{1,5})?(?:/[^\s<>"'`]*)?)"#
  )

  private static let trailingURLPunctuation = CharacterSet(charactersIn: ".,;:!?)]}'\"*")

  /// The display text keeps the original match; only the link target drops
  /// trailing punctuation (and gains `https://` for bare domains).
  private static func linkURL(from matched: String) -> URL? {
    var candidate = matched
    while let last = candidate.unicodeScalars.last, trailingURLPunctuation.contains(last) {
      candidate.removeLast()
    }
    guard !candidate.isEmpty else { return nil }
    let lowered = candidate.lowercased()
    if !(lowered.hasPrefix("http://") || lowered.hasPrefix("https://")) {
      candidate = "https://" + candidate
    }
    return URL(string: candidate)
  }

  private static func splitURLs(_ frags: [Frag]) -> [Frag] {
    splitFull(
      frags, using: urlRegex,
      accept: { result, text in
        guard let range = Range(result.range, in: text) else { return false }
        return linkURL(from: String(text[range])) != nil
      }
    ) { result, text, frag in
      let range = Range(result.range, in: text)!
      let matched = String(text[range])
      var link = frag
      link.text = matched
      link.mode = .raw
      link.link = linkURL(from: matched)
      link.mention = nil
      return [link]
    }
  }

  // MARK: - Mentions

  private static let mentionRegex = try? NSRegularExpression(
    pattern: #"(?i)(?<![\w@])@([a-z0-9._-]+(?:@[a-z0-9.-]+)?)(?![a-z0-9._-])"#)

  private static func splitMentions(_ frags: [Frag]) -> [Frag] {
    splitFull(frags, using: mentionRegex, accept: { _, _ in true }) { result, text, frag in
      guard let range = Range(result.range, in: text) else { return [] }
      let handle = String(text[range])
      var piece = frag
      piece.text = handle
      piece.mode = .raw
      piece.link = nil
      piece.mention = handle
      return [piece]
    }
  }

  // MARK: - Timestamps (`1:23` → seek link)

  private static let timestampRegex = try? NSRegularExpression(
    pattern: #"(?<![\w])(?:(\d{1,2}):)?([0-5]?\d):([0-5]\d)(?![\w])"#)

  private static func splitTimestamps(_ frags: [Frag]) -> [Frag] {
    splitFull(frags, using: timestampRegex, accept: { _, _ in true }) { result, text, frag in
      guard let range = Range(result.range, in: text) else { return [] }
      func group(_ index: Int) -> Int {
        let groupRange = result.range(at: index)
        guard groupRange.location != NSNotFound,
          let swiftRange = Range(groupRange, in: text)
        else { return 0 }
        return Int(text[swiftRange]) ?? 0
      }
      let seconds = group(1) * 3600 + group(2) * 60 + group(3)
      var piece = frag
      piece.text = String(text[range])
      piece.mode = .raw
      piece.link = URL(string: "peertube://seek/\(seconds)")
      piece.mention = nil
      return [piece]
    }
  }

  // MARK: - Emoji

  private static func applyEmoji(_ frags: [Frag]) -> [Frag] {
    frags.map { frag in
      guard frag.mode == .full || frag.mode == .label else { return frag }
      var piece = frag
      piece.text = replaceEmoji(frag.text)
      return piece
    }
  }
}
