# Distribution (macOS)

Markdown Viewer is distributed for macOS as a **notarized, Developer-ID-signed**
`.zip` — direct download, outside the Mac App Store. (Going direct sidesteps the
App Store rule that rejects system-supported UTIs like `net.daringfireball.markdown`
in `QLSupportedContentTypes`.)

## One-time setup

You need a paid Apple Developer Program account, then:

1. **Developer ID Application certificate**
   Xcode → Settings → Accounts → select your team → Manage Certificates →
   **+ → Developer ID Application**.

2. **Notary credentials** (stored in your keychain as a profile named `MV-notary`):
   ```sh
   xcrun notarytool store-credentials MV-notary \
     --apple-id <your-apple-id> \
     --team-id <YOUR_TEAM_ID> \
     --password <app-specific-password>
   ```
   Create the app-specific password at <https://appleid.apple.com> →
   Sign-In and Security → App-Specific Passwords.

3. Set `teamID` in `Distribution/ExportOptions-DeveloperID.plist` and
   `DEVELOPMENT_TEAM` in `project.yml` to your team.

## Release

```sh
scripts/release-mac.sh
```

This will: generate the project → archive → export (Developer ID) → zip →
**notarize** (waits on Apple) → **staple** → produce
`build/MarkdownViewer-notarized.zip`.

Verify before sending:

```sh
spctl -a -vvv --type execute build/export/MarkdownViewer.app   # expect: accepted / Notarized Developer ID
xcrun stapler validate build/export/MarkdownViewer.app
```

## Instructions for testers

Requires **macOS 15 or later**.

1. Unzip and drag **MarkdownViewer.app** to **/Applications**.
2. Open it once. (It's notarized, so no Gatekeeper warning.) A **Setup** window
   explains the rest — in short:
3. **System Settings → General → Login Items & Extensions → Extensions →
   Quick Look** → enable **Markdown Preview** and **Markdown Thumbnail**.
4. **Log out and back in (or restart).** macOS only registers Quick Look
   extensions at login — previews/thumbnails usually won't appear until you do.
5. Try it: select a `.md` in Finder and press **Space** for a rendered preview;
   switch Finder to icon view (**⌘1**) to see Markdown thumbnails.

The Setup window is reachable any time from the app's **Help** menu.
