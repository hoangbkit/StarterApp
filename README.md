# Demo

A minimal SwiftUI iOS app with a 3-page onboarding flow.

- `Demo/DemoApp.swift` — app entry point; shows onboarding once, then the main screen (tracked via `@AppStorage`)
- `Demo/OnboardingView.swift` — paged onboarding with Next / Get Started / Skip
- `Demo/ContentView.swift` — main screen shown after onboarding

## Requirements

- Xcode 15+
- iOS 16+ deployment target

## Build

Open `Demo.xcodeproj` in Xcode and run, or from the command line:

```bash
xcodebuild build -project Demo.xcodeproj -scheme Demo -destination 'generic/platform=iOS Simulator'
```

## Build & run on a physical iPhone, from Terminal only

```bash
make devices                          # find your iPhone's identifier
make deploy DEVICE_ID=<identifier>     # build + install + launch
```

One-time prerequisite: your Apple ID needs to be added under Xcode > Settings > Accounts
at least once (Apple requires a signing team to exist; this isn't an Xcode-project
requirement, just an account one). After that, `make deploy` handles everything —
building, installing, and launching — without opening Xcode again.

If your Apple ID has more than one team:

```bash
make deploy DEVICE_ID=<identifier> TEAM_ID=<team id>
```

Run `make help` for all available targets.

CI (GitHub Actions) builds automatically on push to `master` — see `.github/workflows/ios.yml`.
