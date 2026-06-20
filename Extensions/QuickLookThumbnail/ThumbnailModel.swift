import Foundation

/// Minimal parse of the markdown into the few elements a thumbnail shows.
/// Platform-agnostic (no UIKit/AppKit) so it is shared by the iOS and macOS
/// thumbnail extensions; each provides its own drawing code.
struct ThumbnailModel {
    var title: String
    var bodyLines: [String]

    init(markdown: String) {
        var title = ""
        var body: [String] = []
        for rawLine in markdown.components(separatedBy: .newlines) {
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            if line.isEmpty { continue }
            if title.isEmpty, line.hasPrefix("#") {
                title = line.drop(while: { $0 == "#" }).trimmingCharacters(in: .whitespaces)
                continue
            }
            if title.isEmpty {
                title = ThumbnailModel.strip(line)
                continue
            }
            body.append(ThumbnailModel.strip(line))
            if body.count >= 6 { break }
        }
        self.title = title.isEmpty ? "Markdown" : title
        self.bodyLines = body
    }

    /// Strip the most common inline markdown tokens for a clean preview line.
    static func strip(_ s: String) -> String {
        var out = s
        for token in ["**", "*", "`", "~~", "#", ">"] {
            out = out.replacingOccurrences(of: token, with: "")
        }
        return out.trimmingCharacters(in: .whitespaces)
    }
}
