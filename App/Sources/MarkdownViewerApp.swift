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

        #if os(macOS)
        // Setup/Help window: shown at first launch, reopenable from Help.
        Window("Markdown Viewer Setup", id: "setup") {
            SetupView()
        }
        .windowResizability(.contentSize)
        .defaultLaunchBehavior(.presented)
        .commands {
            CommandGroup(replacing: .help) {
                SetupHelpButton()
            }
        }
        #endif
    }
}

#if os(macOS)
private struct SetupHelpButton: View {
    @Environment(\.openWindow) private var openWindow
    var body: some View {
        Button("Markdown Viewer Setup") { openWindow(id: "setup") }
    }
}
#endif
