import UIKit

// `ThumbnailModel` lives in ThumbnailModel.swift (shared with the macOS thumbnail
// extension). This file is the iOS/UIKit drawing only.
enum ThumbnailRenderer {
    static func draw(_ model: ThumbnailModel, in rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        let scale = rect.height / 220.0 // design at 220pt tall, scale to fit
        func s(_ v: CGFloat) -> CGFloat { (v * scale).rounded() }

        // Page background with subtle border.
        let page = rect.insetBy(dx: s(1), dy: s(1))
        let pagePath = UIBezierPath(roundedRect: page, cornerRadius: s(8))
        UIColor.systemBackground.setFill()
        pagePath.fill()
        UIColor.separator.setStroke()
        pagePath.lineWidth = max(1, s(1))
        pagePath.stroke()

        // GitHub-ish header accent bar.
        let header = CGRect(x: page.minX, y: page.minY, width: page.width, height: s(34))
        let headerPath = UIBezierPath(
            roundedRect: header,
            byRoundingCorners: [.topLeft, .topRight],
            cornerRadii: CGSize(width: s(8), height: s(8))
        )
        UIColor(red: 0.13, green: 0.16, blue: 0.20, alpha: 1).setFill()
        headerPath.fill()

        // "M↓" badge in the header.
        let badgeAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: s(15), weight: .bold),
            .foregroundColor: UIColor.white,
        ]
        ("M↓" as NSString).draw(at: CGPoint(x: header.minX + s(10), y: header.midY - s(9)), withAttributes: badgeAttrs)

        let pad = s(12)
        var y = header.maxY + s(10)

        // Title.
        let titleAttrs: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: s(16), weight: .bold),
            .foregroundColor: UIColor.label,
        ]
        let titleRect = CGRect(x: page.minX + pad, y: y, width: page.width - pad * 2, height: s(40))
        (model.title as NSString).draw(
            with: titleRect,
            options: [.usesLineFragmentOrigin, .truncatesLastVisibleLine],
            attributes: titleAttrs,
            context: nil
        )
        y += s(40)

        // Divider under the title (GitHub h1 rule).
        ctx.setStrokeColor(UIColor.separator.cgColor)
        ctx.setLineWidth(max(1, s(1)))
        ctx.move(to: CGPoint(x: page.minX + pad, y: y))
        ctx.addLine(to: CGPoint(x: page.maxX - pad, y: y))
        ctx.strokePath()
        y += s(8)

        // Body lines as faux text rules of varying width (legible at tiny sizes).
        UIColor.secondaryLabel.withAlphaComponent(0.55).setFill()
        let widths: [CGFloat] = [1.0, 0.92, 0.78, 0.96, 0.6, 0.85]
        for (i, _) in model.bodyLines.enumerated() where y < page.maxY - s(10) {
            let w = (page.width - pad * 2) * (widths[i % widths.count])
            let bar = CGRect(x: page.minX + pad, y: y, width: w, height: s(5))
            UIBezierPath(roundedRect: bar, cornerRadius: s(2.5)).fill()
            y += s(11)
        }
    }
}
