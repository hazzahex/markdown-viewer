import UIKit
import QuickLook

/// Spike 0 preview controller.
///
/// Its only job is to prove — unmistakably — that the iOS Files app (and macOS
/// Quick Look / the share sheet) actually invokes a third-party preview
/// extension for the system markdown UTI `net.daringfireball.markdown`.
///
/// The OS default preview for a `.md` file is plain raw text with no chrome.
/// So we render an obvious green "INVOKED" banner above the raw content: if you
/// see the banner, the extension ran; if you only see raw text, it did not.
final class PreviewViewController: UIViewController, QLPreviewingController {

    private let banner = UILabel()
    private let pathLabel = UILabel()
    private let textView = UITextView()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground

        banner.text = "✅ Quick Look preview extension INVOKED"
        banner.textColor = .white
        banner.backgroundColor = .systemGreen
        banner.textAlignment = .center
        banner.font = .systemFont(ofSize: 15, weight: .semibold)
        banner.numberOfLines = 0
        banner.translatesAutoresizingMaskIntoConstraints = false

        pathLabel.textColor = .secondaryLabel
        pathLabel.font = .monospacedSystemFont(ofSize: 11, weight: .regular)
        pathLabel.numberOfLines = 0
        pathLabel.translatesAutoresizingMaskIntoConstraints = false

        textView.isEditable = false
        textView.font = .monospacedSystemFont(ofSize: 13, weight: .regular)
        textView.textColor = .label
        textView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(banner)
        view.addSubview(pathLabel)
        view.addSubview(textView)

        NSLayoutConstraint.activate([
            banner.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            banner.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            banner.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            banner.heightAnchor.constraint(greaterThanOrEqualToConstant: 44),

            pathLabel.topAnchor.constraint(equalTo: banner.bottomAnchor, constant: 8),
            pathLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 12),
            pathLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -12),

            textView.topAnchor.constraint(equalTo: pathLabel.bottomAnchor, constant: 8),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
        ])
    }

    func preparePreviewOfFile(at url: URL, completionHandler handler: @escaping (Error?) -> Void) {
        let needsScopedAccess = url.startAccessingSecurityScopedResource()
        defer { if needsScopedAccess { url.stopAccessingSecurityScopedResource() } }

        let raw: String
        do {
            raw = try String(contentsOf: url, encoding: .utf8)
        } catch {
            raw = "⚠️ Could not read file:\n\(error.localizedDescription)"
        }

        pathLabel.text = url.lastPathComponent
        textView.text = raw
        handler(nil)
    }
}
