import AppFoundation
import SwiftUI

private struct StarterFeature: Identifiable {
    let id: String
    let title: String
    let message: String
    let systemImage: String
}

private let starterFeatures: [StarterFeature] = [
    StarterFeature(
        id: "app-shell",
        title: "Production app shell",
        message: "Dependency setup, launch routing, persisted state, and recoverable startup errors.",
        systemImage: "square.stack.3d.up.fill"
    ),
    StarterFeature(
        id: "themes",
        title: "Theme-aware interface",
        message: "Persistent free and Pro themes applied across navigation, cards, controls, and paywalls.",
        systemImage: "paintpalette.fill"
    ),
    StarterFeature(
        id: "purchases",
        title: "StoreKit purchases",
        message: "Monthly and yearly plans, verified entitlements, restore, offer codes, and Debug simulation.",
        systemImage: "creditcard.fill"
    ),
    StarterFeature(
        id: "onboarding",
        title: "App-owned onboarding",
        message: "Swipeable pages with Skip, Next, Get Started, completion persistence, and replay support.",
        systemImage: "rectangle.stack.fill"
    ),
    StarterFeature(
        id: "settings",
        title: "Ready-made settings",
        message: "Themes, purchase recovery, support links, review prompts, legal pages, and app version info.",
        systemImage: "gearshape.2.fill"
    ),
    StarterFeature(
        id: "tooling",
        title: "Modern project tooling",
        message: "iOS 26, Swift 6 strict concurrency, XcodeGen, StoreKit configuration, unit tests, and UI tests.",
        systemImage: "hammer.fill"
    ),
]

struct ContentView: View {
    @Environment(PurchaseManager.self) private var purchases
    @Environment(\.appFoundationTheme) private var theme

    let onShowOnboarding: () -> Void

    @State private var isShowingPaywall = false
    @State private var isShowingSettings = false

    init(onShowOnboarding: @escaping () -> Void = {}) {
        self.onShowOnboarding = onShowOnboarding
    }

    var body: some View {
        NavigationStack {
            ZStack {
                StarterThemeBackground(theme: theme)

                ScrollView {
                    VStack(spacing: 18) {
                        heroCard
                        featuresCard
                        entitlementCard

                        Button {
                            onShowOnboarding()
                        } label: {
                            Label("Replay Onboarding", systemImage: "rectangle.stack.fill")
                        }
                        .buttonStyle(StarterSecondaryButtonStyle(theme: theme))

                        #if DEBUG
                        if purchases.isUsingSimulatedPurchases {
                            Label("Debug purchase simulator is active", systemImage: "hammer.fill")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(theme.secondaryForegroundColor)
                        }
                        #endif
                    }
                    .padding(18)
                    .padding(.bottom, 24)
                }
                .scrollIndicators(.hidden)
            }
            .navigationTitle(AppConfiguration.displayName)
            .navigationSubtitle("Everything needed to start building")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                    }
                    .foregroundStyle(theme.primaryForegroundColor)
                    .accessibilityLabel("Settings")
                }
            }
        }
        .tint(theme.accentColor)
        .animation(.smooth, value: theme.id)
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView(
                purchaseManager: purchases,
                configuration: AppConfiguration.paywallConfiguration
            )
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
    }

    private var heroCard: some View {
        StarterThemeCard(
            theme: theme,
            emphasis: .prominent,
            padding: 24,
            cornerRadius: 34
        ) {
            VStack(alignment: .leading, spacing: 22) {
                HStack {
                    StarterEyebrow(
                        title: "Production foundation",
                        systemImage: "sparkles",
                        theme: theme
                    )
                    Spacer()
                    Image(systemName: "swift")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(theme.accentColor)
                }

                HStack(alignment: .center, spacing: 18) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Start with the hard parts already handled.")
                            .font(.system(.title, design: .rounded, weight: .black))
                            .foregroundStyle(theme.primaryForegroundColor)

                        Text("Clone the project, replace the identity and content, then focus on the feature that makes your app unique.")
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryForegroundColor)
                            .lineSpacing(3)
                    }

                    Image(systemName: "shippingbox.fill")
                        .font(.system(size: 38, weight: .bold))
                        .foregroundStyle(theme.primaryForegroundColor)
                        .frame(width: 78, height: 78)
                        .background(theme.gradient, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
                        .overlay {
                            RoundedRectangle(cornerRadius: 24, style: .continuous)
                                .stroke(theme.borderColor, lineWidth: 1)
                        }
                        .shadow(color: theme.accentColor.opacity(0.22), radius: 16, y: 9)
                        .accessibilityHidden(true)
                }

                HStack(spacing: 8) {
                    technologyBadge("iOS 26", systemImage: "iphone")
                    technologyBadge("Swift 6", systemImage: "swift")
                    technologyBadge("XcodeGen", systemImage: "hammer.fill")
                }
            }
        }
    }

    private var featuresCard: some View {
        StarterThemeCard(theme: theme, emphasis: .standard, padding: 18, cornerRadius: 26) {
            VStack(alignment: .leading, spacing: 0) {
                HStack(alignment: .firstTextBaseline) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Included in StarterApp")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(theme.primaryForegroundColor)
                        Text("The reusable foundation already wired into this project.")
                            .font(.caption)
                            .foregroundStyle(theme.secondaryForegroundColor)
                    }

                    Spacer(minLength: 12)

                    Text("\(starterFeatures.count) systems")
                        .font(.caption2.weight(.black))
                        .foregroundStyle(theme.accentColor)
                        .padding(.horizontal, 9)
                        .padding(.vertical, 6)
                        .background(theme.accentColor.opacity(0.12), in: Capsule())
                }
                .padding(.bottom, 10)

                ForEach(Array(starterFeatures.enumerated()), id: \.element.id) { index, feature in
                    featureRow(feature)

                    if index < starterFeatures.count - 1 {
                        Divider()
                            .overlay(theme.borderColor)
                            .padding(.leading, 58)
                    }
                }
            }
        }
    }

    private func featureRow(_ feature: StarterFeature) -> some View {
        HStack(alignment: .top, spacing: 14) {
            StarterSymbolBadge(
                systemImage: feature.systemImage,
                theme: theme,
                size: 44
            )

            VStack(alignment: .leading, spacing: 4) {
                Text(feature.title)
                    .font(.headline)
                    .foregroundStyle(theme.primaryForegroundColor)

                Text(feature.message)
                    .font(.subheadline)
                    .foregroundStyle(theme.secondaryForegroundColor)
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 4)

            Image(systemName: "checkmark.circle.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(theme.accentColor)
                .padding(.top, 2)
                .accessibilityHidden(true)
        }
        .padding(.vertical, 11)
        .accessibilityElement(children: .combine)
    }

    private var entitlementCard: some View {
        StarterThemeCard(theme: theme, emphasis: .quiet, padding: 18, cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 16) {
                StarterEyebrow(
                    title: "StoreKit status",
                    systemImage: entitlementIcon,
                    theme: theme
                )

                HStack(spacing: 13) {
                    StarterSymbolBadge(
                        systemImage: entitlementIcon,
                        theme: theme,
                        size: 48
                    )

                    VStack(alignment: .leading, spacing: 3) {
                        Text(entitlementTitle)
                            .font(.headline)
                            .foregroundStyle(theme.primaryForegroundColor)
                        Text(entitlementMessage)
                            .font(.subheadline)
                            .foregroundStyle(theme.secondaryForegroundColor)
                    }

                    Spacer(minLength: 0)
                }

                entitlementAction
            }
        }
    }

    @ViewBuilder
    private var entitlementAction: some View {
        switch purchases.entitlementState {
        case .checking:
            HStack(spacing: 10) {
                ProgressView()
                    .tint(theme.accentColor)
                Text("Checking Pro access…")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(theme.secondaryForegroundColor)
            }

        case .inactive:
            Button {
                isShowingPaywall = true
            } label: {
                Label("Open Theme-Aware Paywall", systemImage: "crown.fill")
            }
            .buttonStyle(StarterPrimaryButtonStyle(theme: theme))

        case .active:
            Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(theme.accentColor)
        }
    }

    private func technologyBadge(_ title: String, systemImage: String) -> some View {
        Label(title, systemImage: systemImage)
            .font(.caption2.weight(.bold))
            .foregroundStyle(theme.primaryForegroundColor)
            .padding(.horizontal, 10)
            .padding(.vertical, 7)
            .background(theme.elevatedSurfaceColor.opacity(0.9), in: Capsule())
            .overlay {
                Capsule().stroke(theme.borderColor, lineWidth: 1)
            }
    }

    private var entitlementTitle: String {
        switch purchases.entitlementState {
        case .checking: "Checking premium access"
        case .inactive: "Free plan"
        case .active: "StarterApp Pro is active"
        }
    }

    private var entitlementMessage: String {
        switch purchases.entitlementState {
        case .checking:
            "Verifying your current App Store entitlement."
        case .inactive:
            "Test monthly and yearly plans using StoreKit or the Debug purchase simulator."
        case .active:
            "Every premium feature and Pro theme is available."
        }
    }

    private var entitlementIcon: String {
        switch purchases.entitlementState {
        case .checking: "clock.arrow.circlepath"
        case .inactive: "lock.fill"
        case .active: "crown.fill"
        }
    }
}

#Preview {
    ContentView()
        .environment(AppConfiguration.makePreviewPurchaseManager())
}
