# Markdown Viewer

System-level Markdown rendering for iOS, iPadOS & macOS. The goal is to make
`.md` files feel like a *native filetype*: rendered Quick Look previews (tap /
spacebar), rendered thumbnails, and a first-class "Open With" handler — with
almost no app UI of its own.

See the full design in `~/.claude/plans/i-want-to-build-prancy-bird.md`.

## Status: Spike 0 — validating the core premise

Before building the real renderer, we must prove the make-or-break assumption:
**does the iOS Files app actually invoke a third-party Quick Look preview
extension for the system markdown UTI (`net.daringfireball.markdown`)?**

The Spike 0 extension renders an unmistakable green **"✅ INVOKED"** banner above
the raw file text. If you preview a `.md` and see the banner, the extension ran.
If you see only raw text, the OS ignored our extension.

> The Simulator is **not** trustworthy for Quick Look / Files extension
> behavior — this test must be run on a physical device.

## Prerequisites

- Xcode 26/27 (this repo was built against Xcode 27, iOS 27 SDK).
- [XcodeGen](https://github.com/yonsson/XcodeGen): `brew install xcodegen`
- This environment uses Xcode-beta, so commands are prefixed with
  `DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer`. Omit if your
  selected Xcode (`xcode-select -p`) is already the one you want.

## Generate the project

The `.xcodeproj` is generated, not committed. After any change to `project.yml`:

```sh
xcodegen generate
```

## Build & run — Simulator (smoke test)

```sh
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  -derivedDataPath build CODE_SIGNING_ALLOWED=NO build
```

## Build & run — physical device (the real Spike 0 test)

1. Connect the iPhone (USB or same Wi-Fi network) and unlock it.
2. Confirm it's available:
   ```sh
   DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer xcrun devicectl list devices
   ```
3. Build & install (automatic signing, team `N85WF3D9QW`):
   ```sh
   export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
   xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer \
     -destination 'platform=iOS,name=Harry’s iPhone 17' \
     -derivedDataPath build -allowProvisioningUpdates build
   xcrun devicectl device install app --device <DEVICE_UDID> \
     build/Build/Products/Debug-iphoneos/MarkdownViewer.app
   ```
4. **Run the test:**
   - Copy `SampleContent/kitchen-sink.md` into Files (iCloud Drive or On My iPhone).
   - Tap it to preview.
   - ✅ Green banner → extension invoked → Spike 0 passes → proceed to the real renderer.
   - ❌ Raw text only → extension ignored → fall back to in-app + share-extension
     experience (documented in the plan).

## Project layout

```
project.yml                       # XcodeGen spec (source of truth for targets)
App/Sources/                      # minimal SwiftUI host app
Extensions/QuickLookPreview/      # Quick Look preview extension (Spike 0)
SampleContent/kitchen-sink.md     # GFM feature test file
Packages/MarkdownRenderer/        # (next phase) shared rendering engine — SPM
```

## Roadmap (post-spike)

1. ✅ Spike 0 — Quick Look invocation proof.
2. Shared `MarkdownRenderer` SPM package — MarkdownUI + `Theme.gitHub`, GitHub
   alerts, syntax highlighting.
3. `DocumentGroup(viewing:)` host app with a minimal reader UI.
4. Wire the real renderer into the Quick Look extension.
5. Thumbnail extension (Core Graphics).
6. macOS + iPadOS polish.
