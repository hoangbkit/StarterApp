#!/bin/sh
set -eu

ROOT_DIR="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
cd "$ROOT_DIR"

fail() {
    echo "Template validation failed: $*" >&2
    exit 1
}

required_files="
template.yml
project.yml
Makefile
StarterApp/App/StarterAppApp.swift
StarterApp/App/AppConfiguration.swift
StarterApp/Configuration.storekit
StarterApp/PrivacyInfo.xcprivacy
StarterApp/Localizable.xcstrings
StarterAppTests/StarterAppTests.swift
StarterAppUITests/StarterAppUITests.swift
.github/workflows/ios.yml
ci_scripts/ci_post_clone.sh
scripts/validate-bootstrap.sh
"

printf '%s\n' "$required_files" | while IFS= read -r path; do
    [ -z "$path" ] && continue
    [ -e "$path" ] || fail "missing $path"
done

grep -q '^name: StarterApp$' project.yml || fail "project.yml identity changed without updating template.yml"
grep -q 'exactVersion: 0.1.8' project.yml || fail "AppFoundation must use exactVersion 0.1.8"
grep -q "TARGETED_DEVICE_FAMILY: '1'" project.yml || fail "StarterApp must default to iPhone-only"
grep -q 'bundleIdentifier: com.hoangbkit.starterapp' template.yml || fail "template bundle identifier is missing"
grep -q 'minimumXcodeGenVersion: 2.46.0' project.yml || fail "XcodeGen version is not pinned"

if git ls-files '*.xcodeproj/*' '*.xcworkspace/*' | grep -q .; then
    fail "generated Xcode project or workspace files are committed"
fi

[ -x ci_scripts/ci_post_clone.sh ] || fail "ci_scripts/ci_post_clone.sh must be executable"
[ -x scripts/validate-bootstrap.sh ] || fail "scripts/validate-bootstrap.sh must be executable"

sh -n ci_scripts/ci_post_clone.sh
sh -n scripts/validate-bootstrap.sh

if command -v plutil >/dev/null 2>&1; then
    plutil -lint StarterApp/Configuration.storekit >/dev/null
    plutil -lint StarterApp/PrivacyInfo.xcprivacy >/dev/null
fi

if command -v xcodegen >/dev/null 2>&1; then
    xcodegen generate >/dev/null
    xcodebuild -list -project StarterApp.xcodeproj >/dev/null
else
    echo "XcodeGen is unavailable; skipped project generation."
fi

echo "StarterApp template contract is valid."
