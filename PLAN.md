# Demo Starter App Development Plan

## Purpose

Demo is the canonical iOS starter repository used to begin new Hoang apps. It should be cloned, renamed, and adapted rather than imported as a framework.

The repository must provide a small but production-ready app shell with the same engineering baseline used across MiLove, Milesto, ShotVault, MyApps, AppReel, Altself, Beforely, and future apps.

Demo owns application composition and examples. Shared infrastructure belongs in `hoangbkit/AppFoundation`.

## Core boundary

Demo should include:

- XcodeGen project generation
- iOS 26+ and Swift 6 configuration
- App entry and root routing
- App-specific configuration placeholders
- AppFoundation integration
- SwiftData setup and a disposable sample feature
- A complete starter settings screen
- Data-driven onboarding content
- Debug tools
- Logging, previews, tests, CI, privacy manifest, localization structure, and app icon placeholders
- Clear instructions for cloning and renaming the app

Demo should not duplicate:

- StoreKit transaction handling
- Entitlement evaluation
- Simulated purchase implementation
- Generic paywall mechanics
- Generic onboarding mechanics
- Generic settings components
- Generic backup file infrastructure
- Shared loading, empty, or error components already provided by AppFoundation

Demo should not contain real app-domain logic such as relationship timelines, screenshot scanning, event countdowns, notes, card design, or video editing.

## Dependency direction

```text
Demo app
  ├── App-specific configuration and composition
  ├── Sample feature and sample SwiftData model
  └── imports AppFoundation
        ├── Purchases
        ├── Paywall
        ├── Onboarding mechanics
        ├── Settings components
        └── Shared production utilities
```

Demo should track a stable tagged AppFoundation release once AppFoundation reaches 1.0. During development, a local package path may be used for fast iteration.

---

# Phase 1 — Modern project baseline

## Goal

Convert the current minimal iOS 16/Xcode project into the canonical iOS 26+ XcodeGen starter.

## Work

### Adopt XcodeGen

Add a root `project.yml` containing:

- App target
- Unit-test target
- UI-test target
- iOS 26.0 deployment target
- Swift 6 language mode
- Strict concurrency settings
- Team ID `J458WW3452`
- Placeholder bundle identifier `com.hoangbkit.demo`
- AppFoundation package dependency
- Local StoreKit configuration on the shared Run scheme
- Debug and Release configurations
- Privacy manifest and resource inclusion

Generated `.xcodeproj` files should not be treated as the primary source of project configuration.

### Add standard repository tools

Provide:

- `Makefile`
- `.gitignore`
- `.swiftformat` only if SwiftFormat is adopted
- GitHub Actions validation
- Commands for generate, open, build, test, and clean
- Compatibility with the existing `mycli deploy` workflow

Suggested commands:

```bash
make generate
make open
make build
make test
make clean
```

### Define an app configuration file

Create one obvious source of app-specific constants:

```swift
import Foundation

public enum AppConfiguration {
    public static let displayName = "Demo"
    public static let appStoreID: String? = nil

    public static let monthlyProductID = "com.hoangbkit.demo.pro.monthly"
    public static let yearlyProductID = "com.hoangbkit.demo.pro.yearly"

    public static let supportURL = URL(string: "https://example.com/contact")!
    public static let privacyURL = URL(string: "https://example.com/privacy")!
    public static let termsURL = URL(string: "https://example.com/terms")!
}
```

Only true runtime values should live here. Build settings such as bundle identifier and signing belong in XcodeGen configuration.

### Add production resources

- Placeholder app icon with documented replacement steps
- Launch screen configuration
- `PrivacyInfo.xcprivacy`
- Localization catalog or string catalog structure
- Asset catalog organization
- Development StoreKit configuration

### CI baseline

GitHub Actions should:

- Install or use a pinned XcodeGen version
- Generate the project
- Build the app for an iOS Simulator
- Run unit tests
- Fail when project generation or compilation breaks

## Completion criteria

- A fresh clone can generate and build without opening project settings manually.
- The project targets iOS 26+ and Swift 6.
- App identity values are easy to locate and replace.
- CI validates every push to `master`.

---

# Phase 2 — App shell and AppFoundation adoption

## Goal

Create a clean application root and remove duplicated StoreKit code from Demo.

## Work

### Replace the current app entry

Use a small app entry that assembles dependencies only:

```swift
@main
@MainActor
struct DemoApp: App {
    @State private var purchaseManager: PurchaseManager

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(purchaseManager)
                .managesPurchases(purchaseManager)
        }
    }
}
```

The exact AppFoundation API should follow its final Phase 1 implementation.

### Add root state and routing

Create:

```text
Demo/App/
├── DemoApp.swift
├── AppConfiguration.swift
├── AppRootView.swift
├── AppLaunchState.swift
└── AppRouter.swift
```

The root flow should handle:

```text
Preparing dependencies
  → onboarding when incomplete
  → main application
  → recoverable launch error when startup fails
```

Do not place all routing directly inside `DemoApp`.

### Remove duplicated purchase code

Delete the existing app-local `StoreManager.swift` after AppFoundation integration is working.

Demo should use AppFoundation for:

- Product loading
- Transaction verification
- Entitlement refresh
- `hasPro`
- Restore purchases
- Simulated Debug purchases
- Paywall presentation
- Purchase errors and pending states

Demo owns only:

- Product identifiers
- Paywall text and feature list
- When the paywall is presented
- Which sample feature is restricted

### Configure live and simulated modes

Support:

- Xcode Run with local StoreKit configuration
- CLI/device deployment with live StoreKit
- Explicit Debug simulated mode
- Guaranteed live StoreKit in Release

Show the active purchase mode in a Debug-only diagnostics screen.

### Scene-phase handling

Use one clear place to refresh app-level state when returning to foreground. Avoid duplicate entitlement observers in Demo and AppFoundation.

## Tests

- Root flow from preparation to onboarding
- Root flow when onboarding is complete
- Paywall presentation
- Pro/free sample feature authorization
- Debug simulation configuration
- Release configuration safety

## Completion criteria

- Demo contains no custom StoreKit transaction manager.
- `purchaseManager.hasPro` controls sample Pro access.
- App launch and routing are understandable from a small number of files.
- Live, local StoreKit, and simulated Debug modes are documented.

---

# Phase 3 — Onboarding, main structure, and sample feature

## Goal

Demonstrate a realistic but disposable app workflow that can be replaced when starting a new project.

## Work

### Data-driven onboarding

Demo should define app-owned page content while using AppFoundation's onboarding mechanics.

Example content:

```swift
let onboardingPages: [OnboardingPage] = [
    .init(
        systemImage: "sparkles",
        title: "Welcome to Demo",
        message: "A production-ready starting point for a new app."
    ),
    .init(
        systemImage: "lock.shield",
        title: "Private by default",
        message: "Your sample data stays on this device."
    ),
    .init(
        systemImage: "star",
        title: "Ready to build",
        message: "Replace this sample feature with your real product."
    )
]
```

Demo owns:

- Page copy
- Symbols or illustrations
- Skip policy
- Completion storage
- Post-onboarding transition

### Main app structure

Use feature-oriented folders:

```text
Demo/
├── App/
├── Features/
│   ├── Home/
│   ├── SampleFeature/
│   └── Settings/
├── Models/
├── Services/
├── Resources/
└── Support/
```

Avoid unnecessary architecture layers. The starter should be easy for AI tools and a human developer to navigate.

### Add a disposable sample feature

The sample should demonstrate:

- A list of `SampleItem` records
- Empty state
- Add flow
- Edit flow
- Delete flow
- Confirmation for destructive actions
- Basic navigation
- One Pro-gated action or limit
- Loading/error presentation where meaningful

The sample must be clearly documented as disposable and easy to remove.

### SwiftData setup

Provide:

- Production `ModelContainer`
- In-memory preview container
- In-memory unit-test container
- One simple `SampleItem` model
- A clear location for future `VersionedSchema` definitions
- A startup error path if the persistent store cannot be opened

Do not add complex migrations for the first template version. Document where migrations belong when a real app needs them.

### Preview support

Add reusable preview fixtures for:

- Empty state
- Populated state
- Free user
- Pro user
- Light mode
- Dark mode
- Large Dynamic Type

## Tests

- Sample item create, edit, and delete
- Empty and populated states
- Pro gating
- Onboarding completion persistence
- In-memory model container setup
- Navigation smoke tests

## Completion criteria

- The starter demonstrates a full local-first CRUD workflow.
- The sample feature can be deleted without damaging app infrastructure.
- SwiftData works in production, previews, and tests.
- Onboarding content is app-owned and easy to replace.

---

# Phase 4 — Settings, debug tools, and app quality baseline

## Goal

Provide the common production surfaces needed by nearly every app before TestFlight.

## Work

### Complete starter settings

Compose AppFoundation settings components into a Demo-owned screen containing:

#### Subscription

- Upgrade to Pro when free
- Pro status when entitled
- Restore purchases
- Manage subscription

#### App

- Appearance when the app supports it
- Re-show onboarding in Debug only
- Share app
- Rate app

#### Support

- Contact support
- Privacy policy
- Terms of use

#### About

- App display name
- Version and build number
- Optional copyright

Do not fill settings with unnecessary explanatory footer text.

### Debug tools

Add a Debug-only diagnostics screen containing:

- Current app version/build
- Bundle identifier
- Active purchase mode
- Current entitlement state
- Product loading state
- Open paywall
- Reset simulated purchases
- Toggle or purchase simulated Pro through supported APIs
- Reset onboarding
- Seed sample data
- Delete all sample data
- Simulate selected recoverable errors where supported

Debug tools must not compile into or appear in Release builds.

### Common app-quality patterns

Demonstrate:

- User-safe errors
- Loading state
- Empty state
- Retry action
- Confirmation dialog
- Haptics for important actions
- Structured logging
- Keyboard-safe forms
- Correct sheet dismissal
- Task cancellation on view disappearance where appropriate

### Accessibility

Validate:

- VoiceOver labels
- Dynamic Type
- Button hit targets
- Color contrast
- Reduced Motion
- No information conveyed only through color

### Localization readiness

- Move user-facing strings into a string catalog.
- Keep placeholder English text.
- Avoid concatenated localized sentences.
- Verify layouts with longer test strings.

## Tests

- Settings action visibility for free and Pro states
- Restore result handling
- Debug tools excluded from Release
- Accessibility identifiers
- Large-text UI smoke test
- URL actions with valid and invalid configuration

## Completion criteria

- A cloned app already has a professional baseline settings experience.
- Debugging purchase and local-state issues requires no temporary UI edits.
- Release builds contain no debug purchase or reset controls.
- Core screens remain usable with VoiceOver and large text.

---

# Phase 5 — Clone workflow, validation, and template release

## Goal

Make starting a new app predictable, fast, and resistant to forgotten placeholder values.

## Work

### Add a clone checklist

Document a single ordered workflow:

1. Clone or duplicate the repository.
2. Rename the repository folder.
3. Update app name and target name.
4. Update bundle identifier.
5. Confirm Team ID.
6. Replace product identifiers.
7. Replace support, privacy, and terms URLs.
8. Replace app icon and accent/theme assets.
9. Replace onboarding content.
10. Delete or replace `SampleFeature` and `SampleItem`.
11. Update privacy manifest for real APIs and SDKs.
12. Configure App Store ID when available.
13. Configure StoreKit testing.
14. Run rename validation.
15. Build Debug and Release configurations.

### Add placeholder validation

Create a script or Make target that fails when common starter placeholders remain, for example:

```bash
make validate-template
```

Check for values such as:

- `com.hoangbkit.demo`
- `Demo` target/display name where inappropriate
- `example.com`
- Demo product IDs
- Placeholder app icon markers
- Sample feature references when the app is expected to have replaced them

Allow the canonical Demo repository itself to run validation in template mode.

### Improve README

The README should explain:

- What belongs in Demo versus AppFoundation
- Required tools
- Project generation
- Simulator and device builds
- Purchase modes
- Test commands
- Starter architecture
- Clone-and-rename workflow
- What to delete first
- Production checklist

Remove the temporary repository-integration test text after the template work begins.

### Validation matrix

Before tagging the first stable starter version, verify:

- Clean clone
- Project generation
- Simulator build
- Physical-device Debug build
- Release build
- Unit tests
- UI smoke tests
- Local StoreKit purchase
- Simulated Debug purchase
- Restore
- Onboarding reset
- SwiftData persistence across launches
- Dark mode
- Large Dynamic Type
- No placeholder secrets or private credentials

### Template versioning

- Tag stable starter versions.
- Keep a changelog.
- Record which AppFoundation version each Demo tag expects.
- Avoid silently updating Demo to an incompatible AppFoundation branch.

## Completion criteria

- A new project can be created from Demo without manual Xcode project reconstruction.
- Placeholder validation catches the most dangerous forgotten values.
- The clone workflow is documented and repeatable.
- Debug, Release, StoreKit, persistence, accessibility, and CI paths are verified.

---

# Recommended implementation order

1. Complete AppFoundation Phase 1 purchase API cleanup.
2. Complete Demo Phase 1 modern project baseline.
3. Complete Demo Phase 2 and remove `StoreManager.swift`.
4. Build the sample feature and SwiftData setup in Demo Phase 3.
5. Complete AppFoundation onboarding/settings work and adopt it in Demo Phase 4.
6. Add clone validation and tag the first stable Demo template.

# Definition of done for Demo 1.0

Demo 1.0 is ready when:

- It uses XcodeGen, iOS 26+, and Swift 6 strict concurrency.
- A clean clone builds and tests without manual project repair.
- AppFoundation is the only purchase implementation.
- `PurchaseManager.hasPro` gates the sample Pro behavior.
- Live StoreKit, local StoreKit configuration, and Debug simulation are supported.
- Root routing cleanly handles startup, onboarding, and the main app.
- SwiftData works in the app, previews, and tests.
- The disposable sample feature demonstrates CRUD, navigation, empty states, errors, and Pro gating.
- Settings, legal links, support, app information, restore, and manage-subscription actions exist.
- Debug diagnostics support rapid AI-assisted iteration.
- Release builds contain no simulated-purchase or destructive debug tools.
- Privacy manifest, localization structure, accessibility baseline, CI, tests, and placeholder validation are present.
- The README provides a complete clone-and-rename workflow.
