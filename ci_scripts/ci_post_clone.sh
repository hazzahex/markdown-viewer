#!/bin/sh
# Xcode Cloud runs this after cloning. The .xcodeproj is gitignored, so
# generate it from project.yml before Xcode Cloud resolves the scheme.
set -e

brew install xcodegen
cd "$CI_PRIMARY_REPOSITORY_PATH"
xcodegen generate
