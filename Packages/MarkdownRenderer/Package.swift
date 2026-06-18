// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MarkdownRenderer",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "MarkdownRenderer", targets: ["MarkdownRenderer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/swift-markdown-ui", from: "2.4.0"),
        .package(url: "https://github.com/raspu/Highlightr", from: "2.2.0"),
    ],
    targets: [
        .target(
            name: "MarkdownRenderer",
            dependencies: [
                .product(name: "MarkdownUI", package: "swift-markdown-ui"),
                .product(name: "Highlightr", package: "Highlightr"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
