import SwiftUI

/// GitHub-flavored alert/admonition kinds (`> [!NOTE]`, `> [!WARNING]`, …).
/// MarkdownUI doesn't render these natively, so we detect them and draw a
/// GitHub-style callout (icon + colored left bar + colored title).
enum AlertKind: String, CaseIterable {
    case note, tip, important, warning, caution

    var title: String { rawValue.capitalized }

    var systemImage: String {
        switch self {
        case .note: return "info.circle.fill"
        case .tip: return "lightbulb.fill"
        case .important: return "exclamationmark.bubble.fill"
        case .warning: return "exclamationmark.triangle.fill"
        case .caution: return "exclamationmark.octagon.fill"
        }
    }

    var color: Color {
        switch self {
        case .note: return Color(red: 0.20, green: 0.50, blue: 0.95)
        case .tip: return Color(red: 0.13, green: 0.66, blue: 0.30)
        case .important: return Color(red: 0.55, green: 0.35, blue: 0.90)
        case .warning: return Color(red: 0.84, green: 0.60, blue: 0.10)
        case .caution: return Color(red: 0.90, green: 0.25, blue: 0.22)
        }
    }
}

/// A document split into plain-markdown runs and GitHub alert callouts.
enum MarkdownSegment {
    case markdown(String)
    case alert(AlertKind, String)

    static func parse(_ text: String) -> [MarkdownSegment] {
        var segments: [MarkdownSegment] = []
        var buffer: [String] = []

        func flush() {
            let joined = buffer.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
            if !joined.isEmpty { segments.append(.markdown(joined)) }
            buffer.removeAll()
        }

        let lines = text.components(separatedBy: "\n")
        var i = 0
        while i < lines.count {
            if let kind = alertHeader(lines[i]) {
                flush()
                var body: [String] = []
                i += 1
                while i < lines.count, let content = blockquoteContent(lines[i]) {
                    body.append(content)
                    i += 1
                }
                let joined = body.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                segments.append(.alert(kind, joined))
            } else {
                buffer.append(lines[i])
                i += 1
            }
        }
        flush()
        return segments
    }

    /// Returns the alert kind if `line` is a `> [!TYPE]` header.
    private static func alertHeader(_ line: String) -> AlertKind? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix(">") else { return nil }
        let inner = trimmed.dropFirst().trimmingCharacters(in: .whitespaces)
        guard inner.hasPrefix("[!"), inner.hasSuffix("]") else { return nil }
        return AlertKind(rawValue: inner.dropFirst(2).dropLast().lowercased())
    }

    /// Returns the content of a blockquote line (after `>`), or nil if not one.
    private static func blockquoteContent(_ line: String) -> String? {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        guard trimmed.hasPrefix(">") else { return nil }
        var content = String(trimmed.dropFirst())
        if content.hasPrefix(" ") { content.removeFirst() }
        return content
    }
}
