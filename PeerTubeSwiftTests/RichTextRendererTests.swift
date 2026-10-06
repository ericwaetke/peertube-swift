import Foundation
import Testing

@testable import PeerTubeSwift

@Suite("RichTextRenderer")
struct RichTextRendererTests {
  // MARK: - Helpers

  private struct Segment {
    var text: String
    let bold: Bool
    let italic: Bool
    let link: URL?
    let mention: String?
  }

  private func segments(_ raw: String) -> [Segment] {
    let attributed = RichTextRenderer.render(raw)
    var result: [Segment] = []
    for run in attributed.runs {
      var segment = Segment(
        text: String(attributed.characters[run.range]),
        bold: attributed[run.range].inlinePresentationIntent?.contains(.stronglyEmphasized) == true,
        italic: attributed[run.range].inlinePresentationIntent?.contains(.emphasized) == true,
        link: attributed[run.range].link,
        mention: attributed[run.range][RichTextAttribute.Mention.self]
      )
      if let last = result.last,
        last.bold == segment.bold,
        last.italic == segment.italic,
        last.link == segment.link,
        last.mention == segment.mention
      {
        result[result.count - 1].text += segment.text
      } else {
        result.append(segment)
      }
    }
    return result
  }

  private func rendered(_ raw: String) -> String {
    String(RichTextRenderer.render(raw).characters)
  }

  private func links(_ raw: String) -> [(text: String, url: URL)] {
    segments(raw).compactMap { segment in
      segment.link.map { (segment.text, $0) }
    }
  }

  private func mentions(_ raw: String) -> [String] {
    segments(raw).compactMap(\.mention)
  }

  private func boldTexts(_ raw: String) -> [String] {
    segments(raw).filter(\.bold).map(\.text)
  }

  private func italicTexts(_ raw: String) -> [String] {
    segments(raw).filter(\.italic).map(\.text)
  }

  // MARK: - Plain text & structure

  @Test func plainTextPassesThrough() {
    #expect(rendered("Hello world") == "Hello world")
    #expect(links("Hello world").isEmpty)
    #expect(mentions("Hello world").isEmpty)
  }

  @Test func emptyInputRendersEmpty() {
    #expect(rendered("") == "")
  }

  @Test func htmlParagraphsBecomeBlankLineSeparated() {
    #expect(rendered("<p>one</p><p>two</p>") == "one\n\ntwo")
  }

  @Test func brBecomesLineBreak() {
    #expect(rendered("line1<br />line2") == "line1\nline2")
    #expect(rendered("line1<br>line2") == "line1\nline2")
  }

  @Test func markdownSingleNewlineStaysLineBreak() {
    #expect(rendered("a\nb") == "a\nb")
  }

  @Test func markdownBlankLineSeparatesParagraphs() {
    #expect(rendered("a\n\nb") == "a\n\nb")
  }

  @Test func trailingNewlineIsTrimmed() {
    #expect(rendered("hello\n") == "hello")
    #expect(rendered("<p>hello</p>") == "hello")
  }

  @Test func brInsideParagraphKeepsParagraphStructure() {
    #expect(rendered("<p>l1<br>l2</p><p>n</p>") == "l1\nl2\n\nn")
  }

  @Test func blockquoteAndUnknownTagsAreStripped() {
    #expect(rendered("<blockquote><p>quoted</p></blockquote>") == "quoted")
    #expect(rendered("<span class=\"h-card\">x</span> y") == "x y")
    #expect(rendered("<u>u</u>") == "u")
  }

  // MARK: - Entities

  @Test func htmlEntitiesAreDecoded() {
    #expect(rendered("a &amp; b &#39;c&#39; &lt;tag&gt;") == "a & b 'c' <tag>")
  }

  @Test func nbspEntityBecomesNonBreakingSpace() {
    #expect(rendered("a&nbsp;b") == "a\u{00A0}b")
  }

  @Test func unknownEntityStaysLiteral() {
    #expect(rendered("&notarealentity;") == "&notarealentity;")
  }

  // MARK: - Emphasis (HTML)

  @Test func htmlStrongIsBold() {
    let raw = "hello <strong>world</strong>"
    #expect(rendered(raw) == "hello world")
    #expect(boldTexts(raw) == ["world"])
  }

  @Test func htmlBoldTagIsBold() {
    let raw = "<b>bold</b>"
    #expect(boldTexts(raw) == ["bold"])
  }

  @Test func htmlEmIsItalic() {
    let raw = "say <em>loud</em> now"
    #expect(rendered(raw) == "say loud now")
    #expect(italicTexts(raw) == ["loud"])
  }

  @Test func unclosedHtmlTagDoesNotCrash() {
    let raw = "hello <strong>world"
    #expect(rendered(raw) == "hello world")
    #expect(boldTexts(raw) == ["world"])
  }

  // MARK: - Emphasis (markdown)

  @Test func markdownBold() {
    let raw = "this is **bold** text"
    #expect(rendered(raw) == "this is bold text")
    #expect(boldTexts(raw) == ["bold"])
  }

  @Test func markdownAsteriskItalic() {
    let raw = "this is *italic* text"
    #expect(rendered(raw) == "this is italic text")
    #expect(italicTexts(raw) == ["italic"])
  }

  @Test func markdownUnderscoreItalic() {
    let raw = "this is _italic_ text"
    #expect(rendered(raw) == "this is italic text")
    #expect(italicTexts(raw) == ["italic"])
  }

  @Test func intrawordUnderscoreIsNotItalic() {
    let raw = "snake_case_name"
    #expect(rendered(raw) == "snake_case_name")
    #expect(italicTexts(raw).isEmpty)
  }

  @Test func unterminatedEmphasisStaysLiteral() {
    #expect(rendered("**bold") == "**bold")
    #expect(boldTexts("**bold").isEmpty)
  }

  @Test func emphasisWithInnerSpacesStaysLiteral() {
    #expect(rendered("** not bold **") == "** not bold **")
    #expect(boldTexts("** not bold **").isEmpty)
  }

  @Test func multiplicationSignsAreNotItalic() {
    #expect(rendered("2 * 3 * 4") == "2 * 3 * 4")
    #expect(italicTexts("2 * 3 * 4").isEmpty)
  }

  @Test func emphasisDoesNotCrossParagraphBreak() {
    let raw = "**start\n\nend**"
    #expect(rendered(raw) == "**start\n\nend**")
    #expect(boldTexts(raw).isEmpty)
  }

  @Test func combinedBoldAndItalic() {
    let raw = "***both***"
    #expect(rendered(raw) == "both")
    #expect(boldTexts(raw) == ["both"])
    #expect(italicTexts(raw) == ["both"])
  }

  // MARK: - Links

  @Test func markdownLink() {
    let raw = "see [PeerTube](https://peertube.wtf/about) ok"
    #expect(rendered(raw) == "see PeerTube ok")
    #expect(links(raw).count == 1)
    #expect(links(raw)[0].text == "PeerTube")
    #expect(links(raw)[0].url == URL(string: "https://peertube.wtf/about"))
  }

  @Test func markdownLinkWithEmphasizedLabel() {
    let raw = "[**bold link**](https://peertube.wtf)"
    #expect(rendered(raw) == "bold link")
    #expect(boldTexts(raw) == ["bold link"])
    #expect(links(raw)[0].url == URL(string: "https://peertube.wtf"))
  }

  @Test func emphasisWrappingMarkdownLink() {
    let raw = "**[x](https://peertube.wtf)**"
    #expect(rendered(raw) == "x")
    #expect(boldTexts(raw) == ["x"])
    #expect(links(raw)[0].url == URL(string: "https://peertube.wtf"))
  }

  @Test func bareUrlIsLinked() {
    let raw = "see https://peertube.wtf/videos/watch/abc now"
    #expect(rendered(raw) == raw)
    #expect(links(raw).count == 1)
    #expect(links(raw)[0].url == URL(string: "https://peertube.wtf/videos/watch/abc"))
  }

  @Test func autolinkInAngleBrackets() {
    let raw = "<https://peertube.wtf> is the instance"
    #expect(rendered(raw) == "https://peertube.wtf is the instance")
    #expect(links(raw).count == 1)
    #expect(links(raw)[0].url == URL(string: "https://peertube.wtf"))
  }

  @Test func bareDomainIsLinked() {
    let raw = "check peertube.wtf today"
    #expect(rendered(raw) == raw)
    #expect(links(raw).count == 1)
    #expect(links(raw)[0].url == URL(string: "https://peertube.wtf"))
  }

  @Test func trailingPunctuationIsNotPartOfUrl() {
    let raw = "visit https://peertube.wtf."
    #expect(rendered(raw) == raw)
    #expect(links(raw)[0].url == URL(string: "https://peertube.wtf"))
  }

  @Test func markdownLinkDestinationWithBadSchemeIsNotLinked() {
    let raw = "[click](javascript:alert(1)) done"
    #expect(rendered(raw) == "click done")
    #expect(links(raw).isEmpty)
  }

  @Test func htmlAnchorWithClassBecomesLink() {
    let raw = "<p>read <a href=\"https://peertube.wtf/about\" target=\"_blank\">about</a></p>"
    #expect(rendered(raw) == "read about")
    #expect(links(raw)[0].url == URL(string: "https://peertube.wtf/about"))
  }

  @Test func federatedTruncatedLinkRendersFullUrlText() {
    let raw =
      "<p><a href=\"https://chaos.social/@andy/117327837703195780\" target=\"_blank\" rel=\"nofollow noopener\">"
      + "<span class=\"invisible\">https://</span><span class=\"ellipsis\">chaos.social/@andy/1173</span>"
      + "<span class=\"invisible\">27837703195780</span></a></p>"
    #expect(rendered(raw) == "https://chaos.social/@andy/117327837703195780")
    #expect(links(raw).count == 1)
    #expect(links(raw)[0].url == URL(string: "https://chaos.social/@andy/117327837703195780"))
  }

  @Test func relativeOrInvalidHrefIsNotLinked() {
    let raw = "<a href=\"/accounts/bob\">@bob</a>"
    #expect(rendered(raw) == "@bob")
    #expect(links(raw).isEmpty)
  }

  // MARK: - Mentions

  @Test func mentionAnchorIsHighlightedNotLinked() {
    let raw =
      "<p><span class=\"h-card\" translate=\"no\"><a href=\"https://tube.example/a/bob/video-channels\" "
      + "class=\"u-url mention\">@<span>bob</span></a></span> hello</p>"
    #expect(rendered(raw) == "@bob hello")
    #expect(mentions(raw) == ["@bob"])
    #expect(links(raw).isEmpty)
  }

  @Test func hashtagAnchorIsLinkedNotHighlighted() {
    let raw =
      "<a href=\"https://framapiaf.org/tags/swift\" class=\"mention hashtag\" rel=\"tag\">#<span>swift</span></a>"
    #expect(rendered(raw) == "#swift")
    #expect(links(raw).count == 1)
    #expect(links(raw)[0].url == URL(string: "https://framapiaf.org/tags/swift"))
    #expect(mentions(raw).isEmpty)
  }

  @Test func bareMentionIsHighlighted() {
    let raw = "thanks @chocobozzz for the upload"
    #expect(rendered(raw) == raw)
    #expect(mentions(raw) == ["@chocobozzz"])
    #expect(links(raw).isEmpty)
  }

  @Test func bareMentionWithHostIsHighlighted() {
    let raw = "ping @bob@peertube.wtf now"
    #expect(rendered(raw) == raw)
    #expect(mentions(raw) == ["@bob@peertube.wtf"])
    #expect(links(raw).isEmpty)
  }

  @Test func mentionAtStartOfComment() {
    #expect(mentions("@bob hello") == ["@bob"])
  }

  @Test func mentionAfterPunctuation() {
    #expect(mentions("(@bob) hi") == ["@bob"])
  }

  @Test func mentionFollowedByExclamation() {
    #expect(mentions("thanks @bob!") == ["@bob"])
  }

  @Test func emailIsNotAMention() {
    let raw = "contact foo@bar.com for details"
    #expect(mentions(raw).isEmpty)
    #expect(rendered(raw) == raw)
  }

  @Test func mentionInsideUrlIsNotHighlighted() {
    #expect(mentions("see https://peertube.wtf/@bob/videos").isEmpty)
  }

  @Test func bareHashtagStaysPlainText() {
    let raw = "I love #swift a lot"
    #expect(rendered(raw) == raw)
    #expect(links(raw).isEmpty)
    #expect(mentions(raw).isEmpty)
  }

  // MARK: - Timestamps

  @Test func timestampBecomesSeekLink() {
    let raw = "see 1:23 for the good part"
    #expect(rendered(raw) == raw)
    #expect(links(raw).count == 1)
    #expect(links(raw)[0].url == URL(string: "peertube://seek/83"))
  }

  @Test func timestampWithHoursBecomesSeekLink() {
    #expect(links("skip to 1:02:03")[0].url == URL(string: "peertube://seek/3723"))
  }

  @Test func timestampInsideUrlIsNotConverted() {
    let raw = "https://peertube.wtf/videos/watch/1:23"
    #expect(links(raw).count == 1)
    #expect(links(raw)[0].url == URL(string: raw))
  }

  // MARK: - Emoji

  @Test func emojiShortcodeIsReplaced() {
    #expect(rendered("yay :smile: done") == "yay \u{1F604} done")
  }

  @Test func unknownEmojiShortcodeStaysLiteral() {
    #expect(rendered(":notanemoji:") == ":notanemoji:")
  }

  @Test func emoticonSmileyIsReplaced() {
    #expect(rendered("hi :)") == "hi \u{1F603}")
  }

  @Test func emoticonHeartIsReplaced() {
    #expect(rendered("I <3 you") == "I \u{2764}\u{FE0F} you")
  }

  @Test func emoticonNotReplacedWhenAttachedToWord() {
    #expect(rendered("abc:)") == "abc:)")
    #expect(rendered("12:)") == "12:)")
  }

  @Test func emoticonNotReplacedInsideUrl() {
    #expect(rendered("https://peertube.wtf/:)") == "https://peertube.wtf/:)")
  }

  @Test func emojiShortcodeNotReplacedInsideUrl() {
    let raw = "https://peertube.wtf/:smile:"
    #expect(rendered(raw) == raw)
    #expect(links(raw).count == 1)
  }

  @Test func emojiShortcodeInsideLinkLabelIsReplaced() {
    let raw = "[happy :smile:](https://peertube.wtf)"
    #expect(rendered(raw) == "happy \u{1F604}")
    #expect(links(raw)[0].url == URL(string: "https://peertube.wtf"))
  }

  // MARK: - Lists

  @Test func markdownBulletList() {
    let raw = "- one\n- two"
    #expect(rendered(raw) == "\u{2022} one\n\u{2022} two")
  }

  @Test func markdownBulletListAfterParagraph() {
    let raw = "intro\n\n- one\n- two"
    #expect(rendered(raw) == "intro\n\n\u{2022} one\n\u{2022} two")
  }

  @Test func markdownNumberedList() {
    let raw = "1. first\n2. second"
    #expect(rendered(raw) == "1. first\n2. second")
  }

  @Test func htmlBulletList() {
    let raw = "<ul><li>one<li>two</ul>"
    #expect(rendered(raw) == "\u{2022} one\n\u{2022} two")
  }

  @Test func htmlOrderedList() {
    let raw = "<ol><li>one<li>two</ol>"
    #expect(rendered(raw) == "1. one\n2. two")
  }

  @Test func listContentKeepsEmphasis() {
    let raw = "- **bold item**"
    #expect(rendered(raw) == "\u{2022} bold item")
    #expect(boldTexts(raw) == ["bold item"])
  }

  // MARK: - Real world fixtures

  @Test func mastodonCommentFixture() {
    let raw =
      "<p><span class=\"h-card\" translate=\"no\"><a href=\"https://tube.funfacts.de/a/funfacts/video-channels\" "
      + "class=\"u-url mention\">@<span>funfacts</span></a></span> Arte hatte eine tolle Doku. "
      + "Sieh dir <a href=\"https://peertube.wtf/videos/watch/abc\" target=\"_blank\" rel=\"nofollow noopener\">"
      + "das Video</a> an.</p><p>Sehr zu empfehlen :)</p>"

    let expected =
      "@funfacts Arte hatte eine tolle Doku. Sieh dir das Video an.\n\n"
      + "Sehr zu empfehlen \u{1F603}"
    #expect(rendered(raw) == expected)
    #expect(mentions(raw) == ["@funfacts"])
    #expect(links(raw).count == 1)
    #expect(links(raw)[0].url == URL(string: "https://peertube.wtf/videos/watch/abc"))
  }

  @Test func markdownCommentWithEverything() {
    let raw =
      "Hey @bob check **this** :smile:\n\n"
      + "- first item\n"
      + "- second item\n\n"
      + "Link: https://peertube.wtf and 1:23"

    let expected =
      "Hey @bob check this \u{1F604}\n\n"
      + "\u{2022} first item\n"
      + "\u{2022} second item\n\n"
      + "Link: https://peertube.wtf and 1:23"

    #expect(rendered(raw) == expected)
    #expect(mentions(raw) == ["@bob"])
    #expect(boldTexts(raw) == ["this"])

    let linkUrls = links(raw).map(\.url)
    #expect(linkUrls.contains(URL(string: "https://peertube.wtf")!))
    #expect(linkUrls.contains(URL(string: "peertube://seek/83")!))
  }

  @Test func mentionAttributeSurvivesEmphasis() {
    let raw = "**@bob** hello"
    #expect(rendered(raw) == "@bob hello")
    #expect(mentions(raw) == ["@bob"])
    #expect(boldTexts(raw) == ["@bob"])
  }
}
