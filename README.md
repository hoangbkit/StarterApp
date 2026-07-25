# StarterApp

The canonical iOS template for Hoang's apps and the source template for `mycli new ios`.

StarterApp keeps the reusable production foundation from MiLove, Milesto, and ShotVault without copying their app-specific data models, navigation, widgets, permissions, or business logic.

## Shared baseline

- iPhone-first, iOS 26+
- Swift 6 with complete strict concurrency
- SwiftUI, Observation, and rounded typography
- XcodeGen 2.46.0+
- AppFoundation 0.1.8
- centralized `PurchaseManager` and `ThemeManager` injection
- monthly and yearly StoreKit subscriptions
- Debug purchase simulation and a local StoreKit configuration
- theme-aware paywall and settings
- app-owned onboarding and launch routing
- privacy manifest and string catalog
- unit-test and UI-test targets
- GitHub Actions validation
- Xcode Cloud post-clone project generation

Widgets, SwiftData, app groups, alternate icons, and document types are deliberately optional. `mycli` can add them when an app needs them rather than forcing every app to carry them.

## Template contract

`template.yml` is the machine-readable contract used by `mycli`. It defines:

- template and schema versions
- canonical identity values
- renameable directories, files, targets, schemes, and bundle IDs
- included and optional features
- configuration surfaces
- files removed after bootstrap
- validation requirements

A generated app should keep its selected answers and template version in `.mycli/project.yml`. That gives `mycli repair ios` enough information to detect and safely restore missing shared setup later.

## Project structure

```text
StarterApp/
├── App/
│   ├── AppConfiguration.swift
│   ├── AppLaunchState.swift
│   ├── AppRootView.swift
│   ├── AppRouter.swift
│   └── StarterAppApp.swift
├── ContentView.swift
├── OnboardingView.swift
├── SettingsView.swift
├── Configuration.storekit
├── PrivacyInfo.xcprivacy
├── Localizable.xcstrings
└── Assets.xcassets

StarterAppTests/
StarterAppUITests/
ci_scripts/ci_post_clone.sh
scripts/validate-template.sh
scripts/validate-bootstrap.sh
template.yml
project.yml
Makefile
```

## Generate, build, and test

`project.yml` is the source of truth. Generated Xcode projects and workspaces are ignored by Git.

```bash
make validate-template
make generate
make build
make test
make ui-test
```

Install XcodeGen when needed:

```bash
brew install xcodegen
```

## Xcode Cloud

`ci_scripts/ci_post_clone.sh` installs the pinned XcodeGen version, generates the project, and verifies that Xcode can list it. This allows repositories to omit the generated `.xcodeproj` while remaining compatible with Xcode Cloud.

## Purchase testing

The **StarterApp** scheme uses `StarterApp/Configuration.storekit`.

The **StarterApp Simulated** scheme sets:

```text
APPFOUNDATION_PURCHASE_MODE=simulated
```

Simulation is Debug-only. Release builds resolve to live StoreKit.

## Runtime configuration

Edit `StarterApp/App/AppConfiguration.swift` for:

- App Store ID
- monthly and yearly product IDs
- support, privacy, and terms URLs
- simulated products and prices
- paywall copy
- purchase and theme state construction

The display name and persistence keys derive from the generated bundle where possible, reducing the number of identity values that bootstrap must replace.

Edit `project.yml` for:

- target, product, and scheme names
- bundle identifiers
- signing team
- deployment target
- version and build number
- package dependencies
- device families

## Manual bootstrap

`mycli new ios` should be the preferred path. Until that command is implemented:

1. Duplicate the repository without its Git history.
2. Rename app, test, UI-test directories, files, targets, and schemes.
3. Replace `StarterApp`, `com.hoangbkit.starterapp`, and the signing team using `template.yml` as the contract.
4. Update StoreKit product identifiers and legal URLs.
5. Replace the icon and sample app content.
6. Rewrite `README.md` for the generated app.
7. Remove `template.yml` and `scripts/validate-template.sh`.
8. Write `.mycli/project.yml` with the applied template version and choices.
9. Validate the result using the module/target name:

```bash
scripts/validate-bootstrap.sh /path/to/App AppName com.hoangbkit.appname --build
```

The validator rejects unresolved StarterApp names, placeholder bundle IDs, `example.com` URLs, missing targets, failed project generation, and missing shared schemes.

## Optional capabilities

Add only when required:

- **Widgets:** widget target, shared models, app group, widget snapshots, timeline reloads
- **SwiftData:** model container, migration/recovery policy, maintenance tasks
- **App groups:** shared preferences, entitlements, and extension synchronization
- **Alternate icons:** icon assets and Pro access policy
- **Document types:** URL schemes, exported UTTypes, and backup/import flows

Milesto demonstrates widgets, app groups, and SwiftData. ShotVault demonstrates SwiftData recovery and app-specific coordinators. MiLove demonstrates a smaller domain store and a focused root flow. These remain references, not mandatory template layers.

## Before release

- Set the App Store ID so Share App becomes available.
- Replace every `example.com` URL.
- Replace StarterApp StoreKit product identifiers.
- Replace the placeholder app icon.
- Review the privacy manifest for the real app and linked SDKs.
- Move user-facing strings into the string catalog.
- Build and test Debug and Release configurations.
