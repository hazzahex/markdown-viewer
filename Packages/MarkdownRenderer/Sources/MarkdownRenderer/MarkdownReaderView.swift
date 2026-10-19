import SwiftUI
import MarkdownUI

/// The shared reading surface: GitHub-styled, natively rendered markdown.
/// Used by the host app's document reader (and, on macOS, the Quick Look
/// preview extension). Rendering is native SwiftUI (MarkdownUI), not a WebView.
public struct MarkdownReaderView: View {
    @Environment(\.colorScheme) private var colorScheme
    private let segments: [MarkdownSegment]

    public init(_ markdown: String) {
        self.segments = MarkdownSegment.parse(markdown)
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                    switch segment {
                    case .markdown(let text):
                        styled(Markdown(text))
                    case .alert(let kind, let body):
                        GitHubAlertView(kind: kind, text: body) { styled(Markdown($0)) }
                    }
                }
            }
            .textSelection(.enabled)
            .padding(16)
            .frame(maxWidth: 760, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.markdownPage)
    }

    private func styled(_ markdown: Markdown) -> some View {
        markdown
            .markdownTheme(.gitHub)
            .markdownCodeSyntaxHighlighter(.gitHub(colorScheme: colorScheme))
    }
}

/// A GitHub-style alert callout: colored left bar, icon + colored title, and
/// the alert body rendered with the same markdown styling as the document.
struct GitHubAlertView<Content: View>: View {
    let kind: AlertKind
    let text: String
    @ViewBuilder let content: (String) -> Content

    var body: some View {
        HStack(alignment: .top, spacing: 0) {
            RoundedRectangle(cornerRadius: 1.5)
                .fill(kind.color)
                .frame(width: 3)
            VStack(alignment: .leading, spacing: 6) {
                Label(kind.title, systemImage: kind.systemImage)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(kind.color)
                content(text)
            }
            .padding(.leading, 12)
        }
    }
}

extension Color {
    /// Reading background. Must match `Theme.gitHub`'s text background, which
    /// MarkdownUI paints behind the rendered blocks — otherwise the content
    /// column shows up as a differently-colored panel inside the page.
    static var markdownPage: Color {
        #if canImport(UIKit)
        Color(uiColor: UIColor { traits in
            traits.userInterfaceStyle == .dark ? githubDark : .white
        })
        #else
        Color(nsColor: NSColor(name: nil) { appearance in
            appearance.bestMatch(from: [.aqua, .darkAqua]) == .darkAqua ? githubDark : .white
        })
        #endif
    }

    #if canImport(UIKit)
    private static let githubDark = UIColor(red: 0x18 / 255, green: 0x19 / 255, blue: 0x1D / 255, alpha: 1)
    #else
    private static let githubDark = NSColor(srgbRed: 0x18 / 255, green: 0x19 / 255, blue: 0x1D / 255, alpha: 1)
    #endif
}
