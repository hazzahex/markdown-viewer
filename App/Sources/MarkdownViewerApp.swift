import SwiftUI
import MarkdownRenderer

@main
struct MarkdownViewerApp: App {
    var body: some Scene {
        // Read-only document viewer: the system provides the file browser, the
        // document title, and Open-With/share routing. We just render.
        DocumentGroup(viewing: MarkdownDocument.self) { configuration in
            ReaderView(
                text: configuration.document.text,
                title: configuration.fileURL?.lastPathComponent ?? ""
            )
        }
    }
}
