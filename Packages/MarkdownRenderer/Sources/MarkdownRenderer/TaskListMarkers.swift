import Foundation

/// GFM task-list items (`- [ ]` / `- [x]`). Foundation's markdown parser, which
/// Textual builds on, has no task-list support and would show the brackets
/// literally, so the markers are swapped for ballot-box glyphs before parsing.
/// Fenced code blocks are left untouched.
enum TaskListMarkers {
    private static let item = try! NSRegularExpression(
        pattern: #"^(\s*(?:[-*+]|\d+[.)])\s+)\[([ xX])\](?=\s)"#
    )

    static func replace(in text: String) -> String {
        var fence: String?
        let lines = text.components(separatedBy: "\n").map { line -> String in
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if let open = fence {
                if trimmed.hasPrefix(open) { fence = nil }
                return line
            }
            if trimmed.hasPrefix("```") || trimmed.hasPrefix("~~~") {
                fence = String(trimmed.prefix(3))
                return line
            }
            let range = NSRange(line.startIndex..., in: line)
            guard let match = item.firstMatch(in: line, range: range),
                  let prefix = Range(match.range(at: 1), in: line),
                  let state = Range(match.range(at: 2), in: line),
                  let whole = Range(match.range, in: line) else { return line }
            let box = line[state] == " " ? "☐" : "☑"
            return String(line[prefix]) + box + String(line[whole.upperBound...])
        }
        return lines.joined(separator: "\n")
    }
}
