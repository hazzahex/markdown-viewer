# Resume here — current state

**Repo:** https://github.com/hazzahex/markdown-ios (private). Initial commit pushed
to `main`. Deployment target iOS 18 (device on 27). Reader is the immersive
iOS 26 DocumentGroup presentation (no nav bar by design).


## Done
- **Spike 0 (complete):** iOS Files Quick Look PREVIEW extension for `.md` is
  architecturally impossible (text-conforming types always use the built-in
  viewer). Confirmed on-device + by Apple docs/forums. **Thumbnail extension
  works** — verified rendering custom `.md` thumbnails in the real Files app.
- **Core reader engine (working, verified on device):**
  - `Packages/MarkdownRenderer` SPM package: `MarkdownReaderView` (MarkdownUI +
    `Theme.gitHub`), `CodeHighlighter` (Highlightr, github/github-dark themes),
    `GitHubAlert` (note/tip/important/warning/caution callouts), `MarkdownDocument`
    (read-only FileDocument), `UTType.markdown`.
  - App is now a `DocumentGroup(viewing:)` reader. Browser shows our thumbnails;
    opening a `.md` renders headings, code+highlighting, tables, task lists,
    alerts, blockquotes — all GitHub-faithful, dark-mode aware.
  - `Extensions/QuickLookThumbnail` (works on iOS), `Extensions/QuickLookPreview`
    (inert on iOS — kept for macOS).
- **macOS (working, verified on this Mac):**
  - `MarkdownViewer-mac` app (DocumentGroup reader) + `QuickLookPreviewMac`
    extension (`Extensions/QuickLookPreviewMac/PreviewViewController.swift`,
    AppKit `QLPreviewingController` hosting `MarkdownReaderView` via NSHostingView).
  - **Finder spacebar / Quick Look renders full Markdown** (impossible on iOS) —
    confirmed visually. Same shared engine as iOS.
  - Build: `xcodebuild -scheme MarkdownViewer-mac -destination 'platform=macOS' -derivedDataPath build-mac build`.
    Register for QL: `open -g <app>` then `pluginkit -a <app>/Contents/PlugIns/QuickLookPreviewMac.appex`.
  - `screencapture` works for the agent now (Screen Recording granted to Terminal).

## Build/deploy (unchanged)
```sh
export DEVELOPER_DIR=/Applications/Xcode-beta.app/Contents/Developer
cd /Users/harry/Projects/markdown-ios
xcodegen generate    # only after editing project.yml
xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer \
  -destination 'platform=iOS,name=Harry’s iPhone 17' \
  -derivedDataPath build -allowProvisioningUpdates build
xcrun devicectl device install app --device 129BA488-3FCC-550C-A749-B2748CE0309A \
  build/Build/Products/Debug-iphoneos/MarkdownViewer.app
xcrun devicectl device capture screenshot --device 129BA488-3FCC-550C-A749-B2748CE0309A --destination /tmp/x.png
```

## Open items / next candidates
- **Minimal reading chrome** (hide nav on scroll, reading width on iPad).
- **macOS target** — where the full Quick Look spacebar preview actually works.
- **App Store risk:** the iOS QuickLookPreview extension lists the markdown UTI in
  `QLSupportedContentTypes`; Apple rejects system-supported UTIs there. Make that
  extension macOS-only before shipping.
- Image loading in alerts/body, very large files, theme polish.
- Nothing is committed to git yet.
