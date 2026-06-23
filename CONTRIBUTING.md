# Contributing

Thanks for your interest! A few things that make this project tick.

## Project setup

The Xcode project is **generated** — `project.yml` is the source of truth and the
`.xcodeproj` is gitignored. Never edit the `.xcodeproj` directly; your changes will
be lost on the next generate.

```sh
brew install xcodegen
xcodegen generate          # run after any change to project.yml
```

Requires **Xcode 26+** (developed against Xcode 27 / iOS 27 & macOS 27 SDKs).

## Building

```sh
# macOS app
xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer-mac \
  -destination 'platform=macOS' build

# iOS app (Simulator, no signing)
xcodebuild -project MarkdownViewer.xcodeproj -scheme MarkdownViewer \
  -destination 'platform=iOS Simulator,name=iPhone 17' \
  CODE_SIGNING_ALLOWED=NO build

# The shared rendering engine on its own
cd Packages/MarkdownRenderer && swift build
```

For **signed/device** builds, set your own `DEVELOPMENT_TEAM` and bundle-identifier
prefix in `project.yml` (they default to the original author's).

## Where things live

See the architecture section in the [README](README.md). In short: the rendering
engine is the SPM package in `Packages/MarkdownRenderer/` (shared by the app and
all extensions); the app is in `App/Sources/`; the Quick Look extensions are under
`Extensions/`.

## Pull requests

- Keep `project.yml` as the source of truth — if you add files or targets, do it
  there and run `xcodegen generate`.
- Match the surrounding code style.
- Quick Look extension behavior differs by platform and is fiddly to test — note
  in your PR how you verified any change (device/OS, reboot if relevant; see the
  README's platform notes).

## A note on platform quirks

Two hard-won facts worth knowing before touching the extensions:
- **iOS** never invokes third-party Quick Look *preview* extensions for
  text-conforming types (Markdown included) — that's why iOS relies on thumbnails
  + the reader app, not a preview extension.
- **macOS** Quick Look extensions usually only register after a **reboot/relogin**,
  and `qlmanage`/`QLThumbnailGenerator` are unreliable for testing — verify in real
  Finder.
