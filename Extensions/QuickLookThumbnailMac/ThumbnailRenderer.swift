import AppKit

/// AppKit port of the thumbnail drawing (iOS uses UIKit). Draws into a flipped
/// (top-left origin) context so the layout math matches the iOS code. Shares
/// `ThumbnailModel` (parsing) with the iOS extension.
enum ThumbnailRenderer {
    static func draw(_ model: ThumbnailModel, in rect: CGRect) {
        guard let cg = NSGraphicsContext.current?.cgContext else { return }
        let scale = rect.height / 220.0
        func s(_ v: CGFloat) -> CGFloat { (v * scale).rounded() }

        let page = rect.insetBy(dx: s(1), dy: s(1))
        let pagePath = NSBezierPath(roundedRect: page, xRadius: s(8), yRadius: s(8))
        NSColor.textBackgroundColor.setFill()
        pagePath.fill()
        NSColor.separatorColor.setStroke()
        pagePath.lineWidth = max(1, s(1))
        pagePath.stroke()

        NSGraphicsContext.saveGraphicsState()
        pagePath.addClip()
        let header = CGRect(x: page.minX, y: page.minY, width: page.width, height: s(34))
        NSColor(red: 0.13, green: 0.16, blue: 0.20, alpha: 1).setFill()
        NSBezierPath(rect: header).fill()
        NSGraphicsContext.restoreGraphicsState()

        let badgeAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: s(15), weight: .bold),
            .foregroundColor: NSColor.white,
        ]
        ("M↓" as NSString).draw(at: CGPoint(x: header.minX + s(10), y: header.minY + s(8)), withAttributes: badgeAttrs)

        let pad = s(12)
        var y = header.maxY + s(10)

        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: NSFont.systemFont(ofSize: s(16), weight: .bold),
            .foregroundColor: NSColor.labelColor,
        ]
        let titleRect = CGRect(x: page.minX + pad, y: y, width: page.width - pad * 2, height: s(40))
        (model.title as NSString).draw(
            with: titleRect,
            options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
            attributes: titleAttrs
        )
        y += s(40)

        cg.setStrokeColor(NSColor.separatorColor.cgColor)
        cg.setLineWidth(max(1, s(1)))
        cg.move(to: CGPoint(x: page.minX + pad, y: y))
        cg.addLine(to: CGPoint(x: page.maxX - pad, y: y))
        cg.strokePath()
        y += s(8)

        NSColor.secondaryLabelColor.withAlphaComponent(0.55).setFill()
        let widths: [CGFloat] = [1.0, 0.92, 0.78, 0.96, 0.6, 0.85]
        for (i, _) in model.bodyLines.enumerated() where y < page.maxY - s(10) {
            let w = (page.width - pad * 2) * widths[i % widths.count]
            let bar = CGRect(x: page.minX + pad, y: y, width: w, height: s(5))
            NSBezierPath(roundedRect: bar, xRadius: s(2.5), yRadius: s(2.5)).fill()
            y += s(11)
        }
    }
}
