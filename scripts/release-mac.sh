#!/usr/bin/env bash
#
# Build, Developer-ID sign, notarize, and staple the macOS app for direct
# (non-App-Store) distribution to testers.
#
# Prerequisites (one-time):
#   1. A "Developer ID Application" certificate in your keychain
#      (Xcode > Settings > Accounts > Manage Certificates > + > Developer ID Application).
#   2. A stored notarytool credential profile named "MV-notary":
#      xcrun notarytool store-credentials MV-notary \
#        --apple-id <your-apple-id> --team-id 3Z822A3R56 --password <app-specific-password>
#
# Usage: scripts/release-mac.sh
set -euo pipefail

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode-beta.app/Contents/Developer}"
export PATH="/opt/homebrew/bin:$PATH"

SCHEME="MarkdownViewer-mac"
NOTARY_PROFILE="${NOTARY_PROFILE:-MV-notary}"
ARCHIVE="build/MarkdownViewer.xcarchive"
EXPORT_DIR="build/export"
APP_NAME="MarkdownViewer.app"
DIST_ZIP="build/MarkdownViewer-notarized.zip"

cd "$(dirname "$0")/.."

echo "==> Generating project"
xcodegen generate

echo "==> Archiving"
xcodebuild -project MarkdownViewer.xcodeproj -scheme "$SCHEME" \
  -destination 'generic/platform=macOS' -archivePath "$ARCHIVE" \
  archive -allowProvisioningUpdates

echo "==> Exporting (Developer ID)"
rm -rf "$EXPORT_DIR"
xcodebuild -exportArchive -archivePath "$ARCHIVE" -exportPath "$EXPORT_DIR" \
  -exportOptionsPlist Distribution/ExportOptions-DeveloperID.plist \
  -allowProvisioningUpdates

APP="$EXPORT_DIR/$APP_NAME"

echo "==> Zipping for notarization"
NOTARIZE_ZIP="build/MarkdownViewer-submit.zip"
ditto -c -k --keepParent "$APP" "$NOTARIZE_ZIP"

echo "==> Submitting to notary service (waits for result)"
xcrun notarytool submit "$NOTARIZE_ZIP" --keychain-profile "$NOTARY_PROFILE" --wait

echo "==> Stapling ticket"
xcrun stapler staple "$APP"
xcrun stapler validate "$APP"

echo "==> Packaging stapled app for distribution"
ditto -c -k --keepParent "$APP" "$DIST_ZIP"

echo ""
echo "Done. Send testers: $DIST_ZIP"
echo "(They unzip, drag MarkdownViewer.app to /Applications, then follow the in-app Setup window.)"
