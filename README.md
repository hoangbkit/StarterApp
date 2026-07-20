# Demo

A lightweight iOS starter app for quickly beginning a new Hoang project.

`Demo` is meant to be cloned, renamed, and customized. It provides the shared project foundation and purchase setup, while every real app remains free to design its own features, onboarding, settings, data model, and navigation.

## What Demo includes

### Project foundation

- iOS 26+
- Swift 6 with strict concurrency
- SwiftUI and Observation
- XcodeGen 2.45.4+
- App, unit-test, and UI-test targets
- Generated Xcode project from `project.yml`
- GitHub Actions build and unit-test validation
- Privacy manifest
- String catalog structure
- App icon and asset catalog placeholders

### App structure

The app entry only assembles dependencies. Root navigation is separated into small files:

```text
Demo/App/
├── AppConfiguration.swift
├── AppLaunchState.swift
├── AppRootView.swift
├── AppRouter.swift
└── DemoApp.swift
```

The launch flow supports:

```text
Preparing
  → Onboarding
  → Main app
  → Recoverable launch error
```

### App-owned onboarding

Demo includes a simple three-page SwiftUI onboarding flow with:

- swipeable pages
- SF Symbol illustrations
- Next, Skip, and Get Started actions
- persisted completion state
- an option to show onboarding again from the main screen

Onboarding intentionally stays inside Demo and each cloned app. It is not provided by AppFoundation because real apps often need custom layouts, permissions, profile setup, initial data entry, animations, and branding.

### Purchases through AppFoundation

Demo imports `hoangbkit/AppFoundation` for shared purchase infrastructure.

AppFoundation handles:

- StoreKit product loading
- transaction verification and observation
- entitlement evaluation
- foreground entitlement refresh
- restore purchases
- pending and failure states
- Debug purchase simulation
- reusable paywall mechanics

Demo owns:

- product identifiers
- simulated product values
- paywall text and legal URLs
- when the paywall appears
- which app features require Pro

Demo contains no app-local StoreKit manager.

### Purchase testing modes

The **Demo** scheme uses `Demo/Configuration.storekit` for local StoreKit testing.

The **Demo Simulated** scheme sets:

```text
APPFOUNDATION_PURCHASE_MODE=simulated
```

Simulation is available only in Debug. AppFoundation always resolves Release builds to live StoreKit.

## Requirements

- Xcode 26+
- XcodeGen 2.45.4+
- Team ID `J458WW3452` or your own signing team

Install XcodeGen:

```bash
brew install xcodegen
```

## Generate and open

`project.yml` is the source of truth. `Demo.xcodeproj` is generated and ignored by Git.

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

## Deploy to an iPhone

Configure your Apple ID once in Xcode > Settings > Accounts.

Live StoreKit:

```bash
make devices
make deploy se2
```

Debug simulated purchases:

```bash
make deploy se2 BILLING=simulated
```

Use a device identifier directly:

```bash
make deploy DEVICE_ID=<identifier>
```

Override the signing team:

```bash
make deploy se2 TEAM_ID=<team-id>
```

`BILLING` accepts `live` or `simulated`.

## App configuration

Runtime values are collected in `Demo/App/AppConfiguration.swift`:

- display name
- App Store ID
- monthly and yearly product IDs
- support, privacy, and terms URLs
- product ordering
- simulated products
- paywall copy
- purchase service construction

Build and signing values live in `project.yml`:

- target and product names
- bundle identifiers
- deployment target
- Team ID
- version and build number
- package dependency
- shared schemes

## Starting a new app

1. Clone or duplicate this repository.
2. Rename the app and target.
3. Update bundle identifiers and signing values in `project.yml`.
4. Replace values in `AppConfiguration.swift`.
5. Replace the app icon and accent assets.
6. Customize or replace `OnboardingView.swift`.
7. Replace `ContentView.swift` with the real app experience.
8. Update settings, privacy manifest, strings, StoreKit products, and legal URLs.
9. Run `make generate`, `make build`, and `make test`.

## Current repository structure

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
README.md
```

## Before release

- Replace all `example.com` URLs.
- Replace Demo product identifiers with App Store Connect product identifiers.
- Replace the placeholder app icon.
- Review the privacy manifest for the real app and linked SDKs.
- Move real user-facing strings into the string catalog.
- Build and test both Debug and Release configurations.
