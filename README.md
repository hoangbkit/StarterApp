# Demo

A reusable, production-oriented iOS starter app for Hoang's projects.

`Demo` is the app repository to clone and rename. Shared infrastructure belongs in [`hoangbkit/AppFoundation`](https://github.com/hoangbkit/AppFoundation).

## Baseline

- iOS 26+
- Swift 6 with strict concurrency
- SwiftUI and Observation
- XcodeGen 2.45.4+
- App, unit-test, and UI-test targets
- AppFoundation-backed StoreKit 2 purchases
- Live, local StoreKit, and Debug simulation modes
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

Use live StoreKit:

```bash
make devices
make deploy se2
```

Use AppFoundation's in-process simulator in a Debug build:

```bash
make deploy se2 BILLING=simulated
```

You can also use an identifier directly:

```bash
make deploy DEVICE_ID=<identifier> BILLING=simulated
```

Override the configured signing team when needed:

```bash
make deploy se2 TEAM_ID=<team-id>
```

`BILLING` accepts `live` or `simulated`. AppFoundation forces Release builds to use live StoreKit even if simulation is requested.

This remains compatible with the existing `mycli deploy` workflow because project generation happens automatically before a build.

## Purchase modes

### Xcode: local StoreKit

Select the **Demo** scheme. It uses `Demo/Configuration.storekit` while AppFoundation runs its live StoreKit service.

### Xcode: in-process simulation

Select the **Demo Simulated** scheme. It sets:

```text
APPFOUNDATION_PURCHASE_MODE=simulated
```

This mode works only in Debug and persists simulated entitlement state locally.

### CLI and device deployment

A normal deployment uses live StoreKit:

```bash
make deploy se2
```

An explicit simulated deployment passes the purchase mode to the launched app:

```bash
make deploy se2 BILLING=simulated
```

### Release safety

`PurchaseServiceFactory` always resolves to live StoreKit in Release builds. Simulated purchase code is not used as the release entitlement source.

## App-specific configuration

Runtime identity and purchase values are collected in `Demo/App/AppConfiguration.swift`:

- display name
- App Store ID
- monthly and yearly product IDs
- support, privacy, and terms URLs
- purchase product ordering
- simulated products
- paywall copy
- purchase service construction

Build identity and signing values live in `project.yml`:

- target and product name
- bundle identifiers
- deployment target
- Team ID
- version and build number
- package dependency
- shared schemes

## App launch flow

`DemoApp` only assembles dependencies. `AppRootView` and `AppRouter` own application routing:

```text
Preparing
  → Onboarding
  → Main app
  → Recoverable launch error
```

Onboarding completion is persisted in `UserDefaults`. Re-showing onboarding from the main screen does not erase the completion flag.

## Purchase ownership

Demo owns:

- product identifiers
- simulated catalog values
- paywall text and legal URLs
- when the paywall appears
- which app features require Pro

AppFoundation owns:

- StoreKit product loading
- transaction verification
- transaction observation
- entitlement evaluation
- foreground refresh
- restore behavior
- pending and failure states
- Debug simulation
- paywall mechanics

Demo intentionally contains no app-local StoreKit manager.

## Production resources

- Replace `Demo/AppIcon.icon` with the real app icon.
- Update `Demo/PrivacyInfo.xcprivacy` whenever the app or a linked SDK uses additional required-reason APIs or collects data.
- Add user-facing strings to `Demo/Localizable.xcstrings`.
- Replace all `example.com` URLs before release.
- Replace Demo product identifiers with App Store Connect product identifiers.

The starter declares UserDefaults access because onboarding completion and Debug purchase simulation persist local state.

## Current structure

```text
Demo/
├── App/
│   ├── AppConfiguration.swift
│   ├── AppLaunchState.swift
│   ├── AppRootView.swift
│   ├── AppRouter.swift
│   └── DemoApp.swift
├── ContentView.swift
├── OnboardingView.swift
├── SettingsView.swift
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

## Phase status

- Phase 1: modern XcodeGen project baseline — complete
- Phase 2: app shell and AppFoundation purchase adoption — complete
- Phase 3: onboarding, SwiftData, and disposable sample feature — next
