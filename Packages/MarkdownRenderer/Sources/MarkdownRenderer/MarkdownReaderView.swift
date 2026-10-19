import SwiftUI
import Textual

/// The shared reading surface: GitHub-styled, natively rendered markdown.
/// Used by the host app's document reader (and, on macOS, the Quick Look
/// preview extension). Rendering is native SwiftUI (Textual), not a WebView.
///
/// Textual is used over MarkdownUI because its `StructuredText` supports a
/// single selection spanning every block (headings, paragraphs, lists, tables).
/// MarkdownUI renders each block as a separate `Text`, and SwiftUI's
/// `.textSelection` can't select across `Text` views.
public struct MarkdownReaderView: View {
    private let segments: [MarkdownSegment]

    public init(_ markdown: String) {
        self.segments = MarkdownSegment.parse(TaskListMarkers.replace(in: markdown))
    }

    public var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                    switch segment {
                    case .markdown(let text):
                        StructuredText(markdown: text)
                    case .alert(let kind, let body):
                        GitHubAlertView(kind: kind, text: body) { StructuredText(markdown: $0) }
                    }
                }
            }
            .font(.system(size: 16))
            .textual.structuredTextStyle(.gitHub)
            .textual.textSelection(.enabled)
            .padding(16)
            .frame(maxWidth: 760, alignment: .leading)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background(Color.markdownPage)
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
    /// GitHub-like reading background (white in light, near-black in dark).
    static var markdownPage: Color {
        #if canImport(UIKit)
        Color(uiColor: .systemBackground)
        #else
        Color(nsColor: .textBackgroundColor)
        #endif
    }
}
