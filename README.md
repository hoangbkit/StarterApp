# StarterApp

The canonical iOS template for Hoang's apps and the source template for `mycli new ios`.

StarterApp keeps the reusable production foundation from MiLove, Milesto, and ShotVault without copying their app-specific data models, navigation, widgets, permissions, or business logic.

## Shared baseline

- iPhone-first, iOS 26+
- Swift 6 with complete strict concurrency
- SwiftUI, Observation, and rounded typography
- XcodeGen 2.46.0+
- AppFoundation 0.1.11
- centralized `PurchaseManager` and `ThemeManager` injection
- monthly and yearly StoreKit subscriptions
- Debug purchase simulation and a local StoreKit configuration
- `ClaudePaywallView`, Pro-plan settings, and toolbar upgrade entry points
- AppFoundation theme and app-icon pickers
- four working sample app icons: Default, Midnight, Sunset, and Mint
- Debug-only Screenshot Studio and Promo Video Studio
- app-owned onboarding and launch routing
- privacy manifest and string catalog
- unit-test and UI-test targets
- GitHub Actions validation
- Xcode Cloud post-clone project generation

Widgets, SwiftData, app groups, and document types remain optional. The included alternate icons demonstrate the complete asset-catalog, XcodeGen, entitlement, and Settings flow and can be replaced during bootstrap.

## Template contract

`template.yml` is the machine-readable contract used by `mycli`. It defines:

- template and schema versions
- canonical identity values
- renameable directories, files, targets, schemes, and bundle IDs
- included and optional features
- configuration surfaces
- generated artifacts
- validation requirements

A generated app keeps its selected answers and template version in `.mycli/project.yml`. That gives a future `mycli repair ios` command enough information to detect and safely restore missing shared setup later.

See [Developing StarterApp without breaking `mycli`](docs/mycli-compatibility.md) before changing the template contract or publishing a new template tag.

## Project structure

```text
StarterApp/
├── App/
│   ├── AppConfiguration.swift
│   ├── AppLaunchState.swift
│   ├── AppRootView.swift
│   ├── AppRouter.swift
│   └── StarterAppApp.swift
├── Features/
│   └── DeveloperStudio/
│       ├── StarterScreenshotStudioView.swift
│       └── StarterPromoVideoStudioView.swift
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
- Claude paywall copy
- Pro-plan Settings copy
- purchase and theme state construction

The display name and persistence keys derive from the generated bundle where possible, reducing the number of identity values that bootstrap must replace.

Edit `project.yml` for:

- target, product, and scheme names
- bundle identifiers
- signing team
- deployment target
- version and build number
- package dependencies
- alternate app-icon asset names
- device families

## Bootstrap with `mycli`

Create a new app interactively from the stable tagged template:

```bash
mycli new ios
```

During StarterApp development, test the current checkout without creating a tag:

```bash
rm -rf ~/Developer/tmp/StarterCompat

mycli new ios StarterCompat \
  --bundle-id com.hoangbkit.startercompat \
  --template-path "$PWD" \
  --destination ~/Developer/tmp/StarterCompat \
  --no-git \
  --yes
```

Then validate the generated app on macOS:

```bash
cd ~/Developer/tmp/StarterCompat
make generate
make build
```

`master` is the actively developed template. Published version tags are immutable inputs for `mycli`; do not force-update or delete them. The full compatibility workflow, safe changes, breaking-change process, and tag checklist are documented in [`docs/mycli-compatibility.md`](docs/mycli-compatibility.md).

## Optional capabilities

Add only when required:

- **Widgets:** widget target, shared models, app group, widget snapshots, timeline reloads
- **SwiftData:** model container, migration/recovery policy, maintenance tasks
- **App groups:** shared preferences, entitlements, and extension synchronization
- **Additional alternate icons:** add app-icon sets, picker previews, and the corresponding XcodeGen names
- **Document types:** URL schemes, exported UTTypes, and backup/import flows

Milesto demonstrates widgets, app groups, and SwiftData. ShotVault demonstrates SwiftData recovery and app-specific coordinators. MiLove demonstrates a smaller domain store and a focused root flow. These remain references, not mandatory template layers.

## Before release

- Set the App Store ID so Share App becomes available.
- Replace every placeholder legal URL.
- Replace StarterApp StoreKit product identifiers.
- Replace the four sample app icons with the real app identity.
- Review the privacy manifest for the real app and linked SDKs.
- Move user-facing strings into the string catalog.
- Build and test Debug and Release configurations.
