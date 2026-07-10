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

CI (GitHub Actions) builds automatically on push to `master` — see `.github/workflows/ios.yml`.
