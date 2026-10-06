import Foundation

enum RichTextAttribute {
  /// Marks text that tags a user (`@bob`, `@bob@peertube.wtf`) so it can be highlighted.
  struct Mention: AttributedStringKey {
    static let name = "peertube.rich.mention"
    typealias Value = String
  }
}
