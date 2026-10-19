// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "MarkdownRenderer",
    platforms: [.iOS(.v18), .macOS(.v15)],
    products: [
        .library(name: "MarkdownRenderer", targets: ["MarkdownRenderer"]),
    ],
    dependencies: [
        .package(url: "https://github.com/gonzalezreal/textual", from: "0.5.0"),
    ],
    targets: [
        .target(
            name: "MarkdownRenderer",
            dependencies: [
                .product(name: "Textual", package: "textual"),
            ]
        ),
    ],
    swiftLanguageModes: [.v5]
)
