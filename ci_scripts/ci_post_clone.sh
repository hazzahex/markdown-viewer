#!/bin/sh
# Xcode Cloud runs this after cloning. The .xcodeproj is gitignored, so
# generate it from project.yml before Xcode Cloud resolves the scheme.
#
# XcodeGen comes from its pinned GitHub release rather than Homebrew: brew
# downloads (its portable Ruby and the bottle) from ghcr.io, which is
# unreliable from Xcode Cloud. To upgrade, bump the version and the checksum
# (`shasum -a 256 xcodegen.zip`).
set -e

XCODEGEN_VERSION=2.46.0
XCODEGEN_SHA256=4d9e34b62172d645eed6457cac13fc222569974098ef4ee9c3368bedf0196806

TOOLS_DIR=$(mktemp -d)
curl -fsSL --retry 5 --retry-all-errors -o "$TOOLS_DIR/xcodegen.zip" \
  "https://github.com/yonaskolb/XcodeGen/releases/download/$XCODEGEN_VERSION/xcodegen.zip"
echo "$XCODEGEN_SHA256  $TOOLS_DIR/xcodegen.zip" | shasum -a 256 -c -
unzip -q "$TOOLS_DIR/xcodegen.zip" -d "$TOOLS_DIR"

cd "$CI_PRIMARY_REPOSITORY_PATH"
"$TOOLS_DIR/xcodegen/bin/xcodegen" generate
