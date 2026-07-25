#!/bin/sh
set -eu

ROOT_DIR="${CI_PRIMARY_REPOSITORY_PATH:-$(pwd)}"
cd "$ROOT_DIR"

if ! command -v xcodegen >/dev/null 2>&1; then
    if ! command -v brew >/dev/null 2>&1; then
        echo "XcodeGen is missing and Homebrew is unavailable." >&2
        exit 1
    fi
    brew install xcodegen
fi

xcodegen generate

PROJECT_NAME="$(awk -F': ' '/^name:/{print $2; exit}' project.yml | tr -d "'\"")"
if [ -z "$PROJECT_NAME" ]; then
    echo "Could not determine the project name from project.yml." >&2
    exit 1
fi

xcodebuild -list -project "${PROJECT_NAME}.xcodeproj" >/dev/null
echo "Generated ${PROJECT_NAME}.xcodeproj for Xcode Cloud."
