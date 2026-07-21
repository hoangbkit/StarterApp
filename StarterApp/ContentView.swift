import AppFoundation
import SwiftUI

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
                        entitlementCard

                        Button {
                            onShowOnboarding()
                        } label: {
                            Label("Show Onboarding", systemImage: "rectangle.stack.fill")
                        }
                        .buttonStyle(StarterSecondaryButtonStyle(theme: theme))

                        #if DEBUG
                        if purchases.isUsingSimulatedPurchases {
                            Label("Debug purchase simulator", systemImage: "hammer.fill")
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
            .navigationSubtitle("A production-ready place to begin")
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
            VStack(spacing: 22) {
                HStack {
                    StarterEyebrow(
                        title: "Ready to customize",
                        systemImage: "sparkles",
                        theme: theme
                    )
                    Spacer()
                    Image(systemName: "swift")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(theme.accentColor)
                }

                ZStack {
                    Circle()
                        .fill(theme.gradient)
                        .frame(width: 104, height: 104)
                        .shadow(color: theme.accentColor.opacity(0.24), radius: 20, y: 10)

                    Image(systemName: "checkmark")
                        .font(.system(size: 42, weight: .black))
                        .foregroundStyle(theme.primaryForegroundColor)
                }

                VStack(spacing: 7) {
                    Text("You're all set!")
                        .font(.system(.largeTitle, design: .rounded, weight: .black))
                        .multilineTextAlignment(.center)

                    Text("Use this screen as the starting point for your app's real home experience.")
                        .font(.subheadline)
                        .foregroundStyle(theme.secondaryForegroundColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                }
            }
            .frame(maxWidth: .infinity)
            .foregroundStyle(theme.primaryForegroundColor)
        }
    }

    private var entitlementCard: some View {
        StarterThemeCard(theme: theme, emphasis: .quiet, padding: 18, cornerRadius: 24) {
            VStack(alignment: .leading, spacing: 16) {
                StarterEyebrow(
                    title: "Premium status",
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
                Label("Upgrade to Pro", systemImage: "crown.fill")
            }
            .buttonStyle(StarterPrimaryButtonStyle(theme: theme))

        case .active:
            Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                .font(.subheadline.weight(.bold))
                .foregroundStyle(theme.accentColor)
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
            "Open the theme-aware paywall to test monthly and yearly plans."
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
