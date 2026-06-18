import SwiftUI
import UniformTypeIdentifiers

public extension UTType {
    /// Imported (not owned) markdown type — backed by the host app's
    /// UTImportedTypeDeclarations entry. There is no system `UTType.markdown`.
    static var markdown: UTType { UTType(importedAs: "net.daringfireball.markdown") }
}

/// Read-only markdown document for `DocumentGroup(viewing:)`. The viewer
/// initializer never calls `fileWrapper`, but `FileDocument` requires it, so it
/// throws to make the read-only intent explicit.
public struct MarkdownDocument: FileDocument {
    public static var readableContentTypes: [UTType] { [.markdown, .plainText, .text] }

    public var text: String

    public init(text: String = "") {
        self.text = text
    }

    public init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents,
              let string = String(data: data, encoding: .utf8) else {
            throw CocoaError(.fileReadCorruptFile)
        }
        self.text = string
    }

    public func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        throw CocoaError(.fileWriteNoPermission) // read-only viewer
    }
}
