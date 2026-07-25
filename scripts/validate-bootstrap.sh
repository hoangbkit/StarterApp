#!/bin/sh
set -eu

usage() {
    echo "Usage: $0 <project-root> <module-name> <bundle-id> [--build]" >&2
    exit 64
}

[ "$#" -ge 3 ] || usage

PROJECT_ROOT="$1"
MODULE_NAME="$2"
BUNDLE_ID="$3"
BUILD_MODE="${4:-}"

[ "$BUILD_MODE" = "" ] || [ "$BUILD_MODE" = "--build" ] || usage
cd "$PROJECT_ROOT"

fail() {
    echo "Bootstrap validation failed: $*" >&2
    exit 1
}

[ -f project.yml ] || fail "project.yml is missing"
[ -d "$MODULE_NAME" ] || fail "source directory $MODULE_NAME is missing"
[ -d "${MODULE_NAME}Tests" ] || fail "unit-test directory ${MODULE_NAME}Tests is missing"
[ -d "${MODULE_NAME}UITests" ] || fail "UI-test directory ${MODULE_NAME}UITests is missing"

grep -Fqx "name: ${MODULE_NAME}" project.yml || fail "project name does not match $MODULE_NAME"
grep -Fq "PRODUCT_BUNDLE_IDENTIFIER: ${BUNDLE_ID}" project.yml || fail "bundle identifier does not match $BUNDLE_ID"

search_paths="README.md project.yml Makefile $MODULE_NAME ${MODULE_NAME}Tests ${MODULE_NAME}UITests .github/workflows ci_scripts"
for forbidden in StarterApp com.hoangbkit.starterapp https://example.com; do
    if grep -R --exclude-dir=.git --exclude-dir=build --exclude-dir=DerivedData -- "$forbidden" $search_paths >/dev/null 2>&1; then
        fail "found unresolved template value: $forbidden"
    fi
done

if find . -maxdepth 2 -type d \( -name 'StarterApp' -o -name 'StarterAppTests' -o -name 'StarterAppUITests' \) | grep -q .; then
    fail "found an unresolved StarterApp directory"
fi

command -v xcodegen >/dev/null 2>&1 || fail "XcodeGen is required"
xcodegen generate >/dev/null

PROJECT_PATH="${MODULE_NAME}.xcodeproj"
[ -d "$PROJECT_PATH" ] || fail "$PROJECT_PATH was not generated"
xcodebuild -list -project "$PROJECT_PATH" | grep -Fq "$MODULE_NAME" || fail "shared app scheme was not generated"

if [ "$BUILD_MODE" = "--build" ]; then
    xcodebuild build \
        -project "$PROJECT_PATH" \
        -scheme "$MODULE_NAME" \
        -destination 'generic/platform=iOS Simulator' \
        -derivedDataPath build/bootstrap-validation \
        CODE_SIGNING_ALLOWED=NO
fi

echo "$MODULE_NAME passed bootstrap validation."
