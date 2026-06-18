import SwiftUI
import MarkdownRenderer

/// The document reading surface. On iOS 26+, `DocumentGroup` already presents
/// documents immersively (no nav bar, just a floating back affordance), which
/// matches the "UI hidden, content front-and-centre" goal — so we simply render
/// the content and let the system own the minimal chrome.
struct ReaderView: View {
    let text: String
    let title: String

    init(text: String, title: String = "") {
        self.text = text
        self.title = title
    }

    var body: some View {
        MarkdownReaderView(text)
            #if os(iOS)
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
            #endif
    }
}
