import Foundation
import SwiftUI

/// Renders PeerTube text fields (video comments and descriptions) into an `AttributedString`.
///
/// PeerTube's web client pipes comment/description text through markdown-it
/// (`linkify`, `autolink`, `emphasis`, `link`, `newline`, `entity`, `list`, `html_*`,
/// `breaks: true`) plus `markdown-it-emoji`, linkifies bare URLs and `@user@host`
/// mentions, and turns `1:23` timestamps into seek links. The stored text is that
/// markdown mixed with the HTML federated servers send (`<p>`, `<a class="u-url mention">`,
/// `<span>`, …), so this renderer does the same, in three stages:
///
/// 1. HTML tokenizing → a flat list of ``RichTextRenderer/Frag`` values.
/// 2. Markdown/emoji passes over plain text fragments.
/// 3. Assembly into an `AttributedString`, then markdown emphasis.
enum RichTextRenderer {
  enum Style: Hashable {
    case bold
    case italic
    case code
  }

  enum Mode: Hashable {
    /// Regular comment text: markdown links, URLs, mentions, timestamps and emoji apply.
    case full
    /// Text inside a link: only emoji apply.
    case label
    /// Already final text (list markers, mention handles): no processing.
    case raw
  }

  struct Frag {
    var text: String = ""
    var link: URL? = nil
    var mention: String? = nil
    var styles: Set<Style> = []
    var mode: Mode = .full
    /// When greater than zero the fragment is a line (`1`) or paragraph (`2`) break.
    var breaks: Int = 0
  }

  // MARK: - Rendering

  static func render(_ text: String) -> AttributedString {
    lock.lock()
    if let cached = cache[text] {
      lock.unlock()
      return cached
    }
    lock.unlock()

    let result = build(text)

    lock.lock()
    if cache.count >= 256 { cache.removeAll() }
    cache[text] = result
    lock.unlock()
    return result
  }

  static func build(_ raw: String) -> AttributedString {
    let normalized =
      raw
      .replacingOccurrences(of: "\r\n", with: "\n")
      .replacingOccurrences(of: "\r", with: "\n")
    let tokens = RichTextHTMLParser.tokenize(normalized)
    var frags = process(RichTextHTMLParser.fragments(from: tokens))
    while let last = frags.last, last.breaks > 0 { frags.removeLast() }
    var attributed = assemble(frags)
    applyEmphasis(&attributed)
    return attributed
  }

  private static let lock = NSLock()
  // Guarded by `lock`.
  nonisolated(unsafe) private static var cache: [String: AttributedString] = [:]

  // MARK: - Assembly

  private static func assemble(_ frags: [Frag]) -> AttributedString {
    var result = AttributedString()
    for frag in frags {
      if frag.breaks > 0 {
        guard !result.characters.isEmpty else { continue }
        result.append(AttributedString(String(repeating: "\n", count: frag.breaks)))
        continue
      }
      guard !frag.text.isEmpty else { continue }

      var piece = AttributedString(frag.text)
      let range = piece.startIndex..<piece.endIndex

      var intent: InlinePresentationIntent = []
      if frag.styles.contains(.bold) { intent.insert(.stronglyEmphasized) }
      if frag.styles.contains(.italic) { intent.insert(.emphasized) }
      if !intent.isEmpty { piece[range].inlinePresentationIntent = intent }

      if frag.styles.contains(.code) {
        piece[range].font = Font.system(.body, design: .monospaced)
      }
      if let link = frag.link {
        piece[range].link = link
      }
      if let mention = frag.mention {
        piece[range][RichTextAttribute.Mention.self] = mention
        piece[range].foregroundColor = Color.accentColor
        piece[range].backgroundColor = Color.accentColor.opacity(0.15)
      }

      result.append(piece)
    }
    return result
  }

  // MARK: - Emphasis

  /// Applies `**bold**` / `*italic*` style markdown, deleting the delimiters.
  ///
  /// Runs last, over the assembled text, so emphasis can wrap links and mentions.
  /// Candidates are accepted in priority order and may never share delimiter
  /// characters, which keeps `**a *b* c**` and `***both***` from colliding.
  private static func applyEmphasis(_ attributed: inout AttributedString) {
    let source = String(attributed.characters)
    guard !source.isEmpty else { return }

    struct Candidate {
      let content: Range<Int>
      let delimiters: [Range<Int>]
      let intent: InlinePresentationIntent
    }

    let patterns: [(String, InlinePresentationIntent)] = [
      (
        #"(?<![*\w])\*\*\*(?![\s*])([\s\S]+?)(?<![\s*])\*\*\*(?![*\w])"#,
        [.stronglyEmphasized, .emphasized]
      ),
      (
        #"(?<![\w])___(?![\s_])([\s\S]+?)(?<![\s_])___(?![\w])"#,
        [.stronglyEmphasized, .emphasized]
      ),
      (#"\*\*(?![\s*])([\s\S]+?)(?<![\s*])\*\*"#, [.stronglyEmphasized]),
      (#"(?<![\w])__(?![\s_])([\s\S]+?)(?<![\s_])__(?![\w])"#, [.stronglyEmphasized]),
      (#"(?<![*])\*(?![\s*])([\s\S]+?)(?<![\s*])\*(?!\*)"#, [.emphasized]),
      (#"(?<![\w])_(?![\s_])([\s\S]+?)(?<![\s_])_(?![\w])"#, [.emphasized]),
    ]

    var candidates: [Candidate] = []
    var occupied: [Range<Int>] = []

    for (pattern, intent) in patterns {
      for match in matchRanges(pattern: pattern, in: source) {
        guard !substring(match.content, in: source).contains("\n\n") else { continue }
        let delimiters = [
          match.full.lowerBound..<match.content.lowerBound,
          match.content.upperBound..<match.full.upperBound,
        ]
        guard delimiters.allSatisfy({ !$0.isEmpty }) else { continue }
        let collides = delimiters.contains { range in
          occupied.contains { $0.lowerBound < range.upperBound && range.lowerBound < $0.upperBound }
        }
        guard !collides else { continue }
        occupied.append(contentsOf: delimiters)
        candidates.append(Candidate(content: match.content, delimiters: delimiters, intent: intent))
      }
    }
    guard !candidates.isEmpty else { return }

    let deletions = candidates.flatMap(\.delimiters).sorted { $0.lowerBound > $1.lowerBound }
    for deletion in deletions {
      guard let lower = charIndex(deletion.lowerBound, in: attributed),
        let upper = charIndex(deletion.upperBound, in: attributed),
        lower < upper
      else { continue }
      attributed.removeSubrange(lower..<upper)
    }

    var kept = Array(repeating: true, count: source.count)
    for range in candidates.flatMap(\.delimiters) {
      guard range.upperBound <= kept.count else { continue }
      for offset in range { kept[offset] = false }
    }
    var newOffsets = [Int](repeating: 0, count: source.count + 1)
    var position = 0
    for offset in 0..<source.count {
      newOffsets[offset] = position
      if kept[offset] { position += 1 }
    }
    newOffsets[source.count] = position

    for candidate in candidates {
      let lower = newOffsets[candidate.content.lowerBound]
      let upper = newOffsets[candidate.content.upperBound]
      guard lower < upper,
        let lowerIndex = charIndex(lower, in: attributed),
        let upperIndex = charIndex(upper, in: attributed)
      else { continue }
      var intent = attributed[lowerIndex..<upperIndex].inlinePresentationIntent ?? []
      intent.formUnion(candidate.intent)
      attributed[lowerIndex..<upperIndex].inlinePresentationIntent = intent
    }
  }

  private struct TextMatch {
    let full: Range<Int>
    let content: Range<Int>
  }

  private static func matchRanges(pattern: String, in source: String) -> [TextMatch] {
    guard let regex = try? NSRegularExpression(pattern: pattern) else { return [] }
    let results = regex.matches(
      in: source, range: NSRange(location: 0, length: source.utf16.count))
    return results.compactMap { result in
      guard result.numberOfRanges > 1,
        let full = Range(result.range, in: source),
        let content = Range(result.range(at: 1), in: source)
      else { return nil }
      let fullStart = offset(of: full.lowerBound, in: source)
      let fullEnd = offset(of: full.upperBound, in: source)
      let contentStart = offset(of: content.lowerBound, in: source)
      let contentEnd = offset(of: content.upperBound, in: source)
      return TextMatch(
        full: fullStart..<fullEnd,
        content: contentStart..<contentEnd)
    }
  }

  private static func offset(of index: String.Index, in source: String) -> Int {
    source.distance(from: source.startIndex, to: index)
  }

  private static func substring(_ range: Range<Int>, in source: String) -> String {
    var index = source.startIndex
    var walked = 0
    while walked < range.lowerBound, index < source.endIndex {
      index = source.index(after: index)
      walked += 1
    }
    let start = index
    while walked < range.upperBound, index < source.endIndex {
      index = source.index(after: index)
      walked += 1
    }
    return String(source[start..<index])
  }

  private static func charIndex(_ offset: Int, in attributed: AttributedString)
    -> AttributedString.Index?
  {
    var index = attributed.startIndex
    var walked = 0
    while walked < offset {
      guard index < attributed.endIndex else { return nil }
      index = attributed.characters.index(after: index)
      walked += 1
    }
    return index
  }

  // MARK: - Emoji

  static func replaceEmoji(_ text: String) -> String {
    guard !text.isEmpty else { return text }
    return replaceEmoticons(replaceShortcodes(text))
  }

  private static let shortcodeRegex = try? NSRegularExpression(pattern: #":[A-Za-z0-9_+-]+:"#)

  private static let emoticonRegex: NSRegularExpression? = {
    let alternatives = EmojiShortcodes.emoticons.keys
      .sorted { $0.count > $1.count }
      .map { NSRegularExpression.escapedPattern(for: $0) }
    return try? NSRegularExpression(pattern: alternatives.joined(separator: "|"))
  }()

  private static func replaceShortcodes(_ text: String) -> String {
    guard let regex = shortcodeRegex else { return text }
    return replacing(text, with: regex) { match in
      let name = String(match.dropFirst().dropLast())
      return EmojiShortcodes.shortcodes[name]
    }
  }

  private static func replaceEmoticons(_ text: String) -> String {
    guard let regex = emoticonRegex else { return text }
    return replacing(text, with: regex) { match in
      guard let name = EmojiShortcodes.emoticons[match],
        let emoji = EmojiShortcodes.shortcodes[name]
      else { return nil }
      return emoji
    } validate: { match in
      // markdown-it-emoji only converts emoticons surrounded by whitespace,
      // punctuation or control characters — never inside words (`abc:)`,
      // `12:)`) or URLs.
      isEmoticonBoundary(in: text, at: match)
    }
  }

  private static func isEmoticonBoundary(in text: String, at range: Range<String.Index>) -> Bool {
    if range.lowerBound > text.startIndex {
      let previous = text[text.index(before: range.lowerBound)]
      guard isEmoticonBoundaryCharacter(previous) else { return false }
    }
    if range.upperBound < text.endIndex {
      let next = text[range.upperBound]
      guard isEmoticonBoundaryCharacter(next) else { return false }
    }
    return true
  }

  /// Unicode general categories Z (separator), P (punctuation) and Cc (control),
  /// mirroring markdown-it's `ucmicro` boundary data.
  private static func isEmoticonBoundaryCharacter(_ character: Character) -> Bool {
    guard let scalar = character.unicodeScalars.first else { return false }
    switch scalar.properties.generalCategory {
    case .spaceSeparator, .lineSeparator, .paragraphSeparator, .control,
      .connectorPunctuation, .dashPunctuation, .openPunctuation, .closePunctuation,
      .initialPunctuation, .finalPunctuation, .otherPunctuation:
      return true
    default:
      return false
    }
  }

  private static func replacing(
    _ text: String,
    with regex: NSRegularExpression,
    lookup: (String) -> String?,
    validate: ((Range<String.Index>) -> Bool)? = nil
  ) -> String {
    let results = regex.matches(in: text, range: NSRange(location: 0, length: text.utf16.count))
    guard !results.isEmpty else { return text }

    var output = ""
    var cursor = text.startIndex
    for result in results {
      guard let range = Range(result.range, in: text) else { continue }
      if let validate, !validate(range) { continue }
      guard let replacement = lookup(String(text[range])) else { continue }
      output += text[cursor..<range.lowerBound]
      output += replacement
      cursor = range.upperBound
    }
    output += text[cursor...]
    return output
  }
}
