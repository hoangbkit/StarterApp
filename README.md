# Demo

A reusable, production-oriented iOS starter app for Hoang's projects.

`Demo` is the app repository to clone and rename. Shared infrastructure belongs in [`hoangbkit/AppFoundation`](https://github.com/hoangbkit/AppFoundation).

## Baseline

- iOS 26+
- Swift 6 with strict concurrency
- SwiftUI
- XcodeGen 2.45.4+
- App, unit-test, and UI-test targets
- AppFoundation package dependency
- Local StoreKit configuration
- Privacy manifest and string-catalog structure
- Simulator, physical-device, and CI workflows

## Requirements

- Xcode 26+
- XcodeGen 2.45.4+
- Team ID `J458WW3452` or your own signing team

Install XcodeGen:

```bash
brew install xcodegen
```

## Generate and open

The checked-in `project.yml` is the source of truth. `Demo.xcodeproj` is generated and intentionally ignored.

```bash
make generate
make open
```

## Build and test

```bash
make build
make test
make ui-test
```

GitHub Actions regenerates the project, builds the app, and runs unit tests on every push and pull request targeting `master`.

## Deploy to a physical iPhone

Your Apple ID must be configured once in Xcode > Settings > Accounts.

```bash
make devices
make deploy se2
```

You can also use an identifier directly:

```bash
make deploy DEVICE_ID=<identifier>
```

Override the configured signing team when needed:

```bash
make deploy se2 TEAM_ID=<team-id>
```

This remains compatible with the existing `mycli deploy` workflow because project generation happens automatically before a build.

## App-specific configuration

Runtime identity values are collected in `Demo/AppConfiguration.swift`:

- display name
- App Store ID
- monthly and yearly product IDs
- support URL
- privacy URL
- terms URL

Build identity and signing values live in `project.yml`:

- target and product name
- bundle identifiers
- deployment target
- Team ID
- version and build number

## StoreKit testing

The shared `Demo` Run scheme uses `Demo/Configuration.storekit`. Its product identifiers currently preserve the existing Demo values.

CLI and physical-device builds continue to use live StoreKit unless a later phase explicitly enables AppFoundation's Debug simulator.

## Production resources

- Replace `Demo/AppIcon.icon` with the real app icon.
- Update `Demo/PrivacyInfo.xcprivacy` whenever the app or a linked SDK uses additional required-reason APIs or collects data.
- Add user-facing strings to `Demo/Localizable.xcstrings`.
- Replace all `example.com` URLs before release.

The starter currently declares UserDefaults access because onboarding completion uses `@AppStorage`.

## Current structure

```text
Demo/
├── AppConfiguration.swift
├── DemoApp.swift
├── ContentView.swift
├── OnboardingView.swift
├── PaywallView.swift
├── SettingsView.swift
├── StoreManager.swift
├── Configuration.storekit
├── PrivacyInfo.xcprivacy
├── Localizable.xcstrings
├── Assets.xcassets
└── AppIcon.icon

DemoTests/
DemoUITests/
project.yml
Makefile
PLAN.md
```

`StoreManager.swift` and the app-local purchase UI remain temporarily for Phase 1 compatibility. Phase 2 will replace them with AppFoundation's purchase implementation.
