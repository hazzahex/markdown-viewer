# Markdown Viewer

Make Markdown feel like a **native filetype** on iOS, iPadOS, and macOS — rendered
Quick Look previews, distinctive Finder/Files thumbnails, and a clean GitHub-styled
reader — with almost no app UI of its own. No vault, no subscription: just open a
`.md` and read it the way it was meant to look.

Built as a native SwiftUI app with a shared rendering engine and OS extensions.

## What it does

| Surface | iOS / iPadOS | macOS |
|---|---|---|
| **Reader app** (open a `.md`, GitHub-styled) | ✅ | ✅ |
| **Quick Look preview** (spacebar / Spotlight / Files) | ❌ *(see below)* | ✅ |
| **Thumbnails** in Files / Finder | ✅ | ✅ |

Rendering covers GitHub-Flavored Markdown: headings, tables, task lists, blockquotes,
fenced code with **syntax highlighting** (~190 languages), GitHub **alerts**
(`> [!NOTE]`, `> [!WARNING]`, …), links, and images — all native SwiftUI, dark-mode
aware, no WebView.

### The one platform quirk worth knowing

On **iOS**, a third-party Quick Look *preview* extension is **never invoked for
text-conforming types** like Markdown — iOS always uses its built-in text viewer.
This is architectural (confirmed on-device, in Apple's docs/forums, and by an App
Store validation rule). So on iOS we lean on **thumbnails + the reader app**; the
full spacebar-preview magic lives on **macOS**, where that preemption isn't enforced.
(macOS thumbnails, conversely, only register after a **reboot/relogin** — a Quick
Look quirk the app's Setup window explains to users.)

## Architecture

```
project.yml                          # XcodeGen spec — source of truth for all targets
App/Sources/                         # SwiftUI host app (iOS + macOS), DocumentGroup reader
Packages/MarkdownRenderer/           # shared SPM engine (used by app + extensions)
  MarkdownReaderView                 #   MarkdownUI + Theme.gitHub
  CodeHighlighter                    #   Highlightr (highlight.js) syntax highlighting
  GitHubAlert                        #   [!NOTE]/[!WARNING]/… callouts
  MarkdownDocument                   #   read-only FileDocument
Extensions/QuickLookPreviewMac/      # macOS Quick Look preview extension
Extensions/QuickLookThumbnail/       # iOS thumbnail extension
Extensions/QuickLookThumbnailMac/    # macOS thumbnail extension
Distribution/                        # Developer ID export options (see Distribution/README.md)
scripts/release-mac.sh               # archive → notarize → staple → zip
```

The `.xcodeproj` is **generated** by [XcodeGen](https://github.com/yonaskolb/XcodeGen),
not committed — `project.yml` is the source of truth.

## Build & run

**Prerequisites:** Xcode 26+ (built against Xcode 27 / the iOS 27 & macOS 27 SDKs),
and `brew install xcodegen`.

```sh
xcodegen generate          # regenerate the .xcodeproj after editing project.yml
```

Build the macOS app:

```sh
xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer-mac \
  -destination 'platform=macOS' build
```

Build the iOS app (Simulator):

```sh
xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  CODE_SIGNING_ALLOWED=NO build
```

> Forking this? You'll need to set your own **`DEVELOPMENT_TEAM`** and
> **bundle identifier prefix** in `project.yml` (they're currently set to the
> original author's). See `Distribution/README.md` for the macOS release flow.

## Distribution

The macOS app ships as a **notarized, Developer-ID-signed** download (not the App
Store — which avoids the `QLSupportedContentTypes` system-UTI validation
restriction). One command builds, notarizes, staples, and zips it:

```sh
scripts/release-mac.sh     # see Distribution/README.md for the one-time setup
```

## Dependencies

All MIT-licensed:
- [MarkdownUI](https://github.com/gonzalezreal/swift-markdown-ui) — native SwiftUI rendering + GitHub theme
- [Highlightr](https://github.com/raspu/Highlightr) — syntax highlighting (highlight.js)
- (transitively: swift-cmark, NetworkImage)

## License

[MIT](LICENSE).
