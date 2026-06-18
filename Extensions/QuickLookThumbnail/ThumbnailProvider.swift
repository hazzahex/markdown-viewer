import UIKit
import QuickLookThumbnailing

/// Renders a distinctive, GitHub-flavoured thumbnail for `.md` files so they
/// stand out in the Files browser. Unlike the preview extension, a thumbnail
/// extension DOES fire on iOS for text-conforming types (Spike 0 finding), so
/// this is our real lever on the Files UI.
///
/// Drawing is pure UIKit/Core Graphics (no WebView/SwiftUI snapshotting) to stay
/// comfortably inside the Quick Look memory/time budget. The drawing itself
/// lives in `ThumbnailRenderer` (shared with the host app for live preview).
final class ThumbnailProvider: QLThumbnailProvider {

    override func provideThumbnail(
        for request: QLFileThumbnailRequest,
        _ handler: @escaping (QLThumbnailReply?, Error?) -> Void
    ) {
        let text = (try? String(contentsOf: request.fileURL, encoding: .utf8)) ?? ""
        let model = ThumbnailModel(markdown: text)

        // Fit a portrait "page" inside the requested maximum size.
        let maxSize = request.maximumSize
        let pageAspect: CGFloat = 0.773 // ~ISO 216 page ratio
        var size = maxSize
        if maxSize.width / maxSize.height > pageAspect {
            size.width = (maxSize.height * pageAspect).rounded(.down)
        } else {
            size.height = (maxSize.width / pageAspect).rounded(.down)
        }
        size.width = max(size.width, 16)
        size.height = max(size.height, 16)

        let reply = QLThumbnailReply(contextSize: size) {
            ThumbnailRenderer.draw(model, in: CGRect(origin: .zero, size: size))
            return true
        }
        handler(reply, nil)
    }
}
