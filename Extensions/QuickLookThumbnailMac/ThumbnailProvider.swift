import AppKit
import QuickLookThumbnailing
import os

private let log = Logger(subsystem: "com.hazzahex.MarkdownViewer", category: "qlthumb")

/// macOS thumbnail extension — renders a distinctive `.md` icon for Finder.
/// Draws into the provided CGContext via a flipped NSGraphicsContext so the
/// shared layout math matches the iOS renderer.
final class ThumbnailProvider: QLThumbnailProvider {

    override func provideThumbnail(
        for request: QLFileThumbnailRequest,
        _ handler: @escaping (QLThumbnailReply?, Error?) -> Void
    ) {
        log.notice("QLTHUMB invoked for \(request.fileURL.lastPathComponent, privacy: .public)")
        let text = (try? String(contentsOf: request.fileURL, encoding: .utf8)) ?? ""
        let model = ThumbnailModel(markdown: text)

        let maxSize = request.maximumSize
        let pageAspect: CGFloat = 0.773
        var size = maxSize
        if maxSize.width / maxSize.height > pageAspect {
            size.width = (maxSize.height * pageAspect).rounded(.down)
        } else {
            size.height = (maxSize.width / pageAspect).rounded(.down)
        }
        size.width = max(size.width, 16)
        size.height = max(size.height, 16)

        let reply = QLThumbnailReply(contextSize: size) { (cgContext: CGContext) -> Bool in
            // The context has an identity CTM whose backing is `size * scale`
            // PIXELS, so draw into its actual reported pixel bounds rather than
            // the point-size (which would fill only a 1/scale corner on Retina).
            let pxRect = CGRect(x: 0, y: 0, width: CGFloat(cgContext.width), height: CGFloat(cgContext.height))
            let nsContext = NSGraphicsContext(cgContext: cgContext, flipped: true)
            NSGraphicsContext.saveGraphicsState()
            NSGraphicsContext.current = nsContext
            // Flip the CTM so the top-left-origin layout positions correctly.
            cgContext.translateBy(x: 0, y: pxRect.height)
            cgContext.scaleBy(x: 1, y: -1)
            ThumbnailRenderer.draw(model, in: pxRect)
            NSGraphicsContext.restoreGraphicsState()
            return true
        }
        handler(reply, nil)
    }
}
