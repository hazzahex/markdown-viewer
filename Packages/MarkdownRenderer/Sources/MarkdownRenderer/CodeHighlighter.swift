import SwiftUI
import MarkdownUI
import Highlightr

/// Bridges Highlightr (highlight.js, synchronous) into MarkdownUI's
/// `CodeSyntaxHighlighter`. MarkdownUI requires a synchronous `Text` result,
/// which Highlightr's JSContext-backed API satisfies (Splash is Swift-only;
/// AttributedString markdown can't do this at all).
struct HighlightrSyntaxHighlighter: CodeSyntaxHighlighter {
    private let highlightr: Highlightr?

    init(theme: String) {
        let h = Highlightr()
        h?.setTheme(to: theme)
        self.highlightr = h
    }

    func highlightCode(_ code: String, language: String?) -> Text {
        guard let highlightr else { return Text(code) }
        let attributed: NSAttributedString?
        if let language, !language.isEmpty {
            attributed = highlightr.highlight(code, as: language) ?? highlightr.highlight(code)
        } else {
            attributed = highlightr.highlight(code)
        }
        guard let attributed else { return Text(code) }
        return Text(AttributedString(attributed))
    }
}

extension CodeSyntaxHighlighter where Self == HighlightrSyntaxHighlighter {
    /// Vivid-but-tasteful highlight.js themes (more colorful than GitHub's muted
    /// default). atom-one is a well-balanced, high-contrast pairing.
    static func gitHub(colorScheme: ColorScheme) -> HighlightrSyntaxHighlighter {
        HighlightrSyntaxHighlighter(theme: colorScheme == .dark ? "atom-one-dark" : "atom-one-light")
    }
}
