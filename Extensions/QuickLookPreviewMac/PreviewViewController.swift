import Cocoa
import QuickLookUI
import SwiftUI
import os
import MarkdownRenderer

private let log = Logger(subsystem: "com.hazzahex.MarkdownViewer", category: "qlpreview")

/// macOS Quick Look preview extension. Unlike iOS, macOS does NOT preempt
/// third-party preview extensions for text-conforming types — so this actually
/// renders formatted Markdown on Finder spacebar, in Spotlight, and in Get Info.
/// It hosts the shared `MarkdownReaderView` via an `NSHostingView`.
final class PreviewViewController: NSViewController, QLPreviewingController {

    override func loadView() {
        self.view = NSView()
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        log.notice("QLPREVIEW invoked for \(url.lastPathComponent, privacy: .public)")
        let text: String
        do {
            text = try String(contentsOf: url, encoding: .utf8)
        } catch {
            log.error("QLPREVIEW read failed: \(error.localizedDescription, privacy: .public)")
            handler(error)
            return
        }
        log.notice("QLPREVIEW rendering \(text.count) chars")

        let hosting = NSHostingView(rootView: MarkdownReaderView(text))
        hosting.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(hosting)
        NSLayoutConstraint.activate([
            hosting.topAnchor.constraint(equalTo: view.topAnchor),
            hosting.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hosting.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hosting.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])

        handler(nil)
    }
}
