import AppFoundation
import StoreKit
import SwiftUI

struct SettingsView: View {
    @Environment(PurchaseManager.self) private var purchases
    @Environment(ThemeManager.self) private var themes
    @Environment(\.appFoundationTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    @State private var isShowingPaywall = false
    @State private var statusMessage: String?

    #if DEBUG
    @State private var isChangingPurchaseMode = false
    #endif

    private var appIcons: [AppIconOption] {
        [
            AppIconOption(
                id: "default",
                title: "Default",
                alternateIconName: nil,
                previewImageName: "AppIconDefaultPreview",
                accentColor: theme.accentColor
            ),
            AppIconOption(
                id: "midnight",
                title: "Midnight",
                alternateIconName: "AppIconMidnight",
                previewImageName: "AppIconMidnightPreview",
                accentColor: .indigo,
                requiresUnlock: true
            ),
            AppIconOption(
                id: "sunset",
                title: "Sunset",
                alternateIconName: "AppIconSunset",
                previewImageName: "AppIconSunsetPreview",
                accentColor: .orange,
                requiresUnlock: true
            ),
            AppIconOption(
                id: "mint",
                title: "Mint",
                alternateIconName: "AppIconMint",
                previewImageName: "AppIconMintPreview",
                accentColor: .mint,
                requiresUnlock: true
            ),
        ]
    }

    var body: some View {
        NavigationStack {
            List {
                ProPlanSettingsSection(
                    purchaseManager: purchases,
                    configuration: AppConfiguration.proPlanSettingsConfiguration,
                    onUpgrade: { isShowingPaywall = true }
                )
                .listRowBackground(theme.surfaceColor)

                Section {
                    ThemePickerView(
                        manager: themes,
                        title: nil,
                        onRequestUpgrade: {
                            isShowingPaywall = true
                        }
                    )
                    .padding(.vertical, 4)
                } header: {
                    Text("App Theme")
                }
                .listRowBackground(theme.surfaceColor)

                AppIconPickerSection(
                    icons: appIcons,
                    footer: nil,
                    isLocked: { icon in
                        icon.requiresUnlock && !purchases.hasPro
                    },
                    onRequestUnlock: { _ in
                        isShowingPaywall = true
                    }
                )
                .listRowBackground(theme.surfaceColor)

                aboutSection
                    .listRowBackground(theme.surfaceColor)

                #if DEBUG
                developerSection
                    .listRowBackground(theme.surfaceColor)
                #endif
            }
            .scrollContentBackground(.hidden)
            .background(StarterThemeBackground(theme: theme))
            .listSectionSpacing(18)
            .listSectionSeparatorTint(theme.borderColor)
            .foregroundStyle(theme.primaryForegroundColor)
            .navigationTitle("Settings")
            .navigationSubtitle("Make \(AppConfiguration.displayName) feel like yours")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $isShowingPaywall) {
                ClaudePaywallView(
                    purchases: purchases,
                    configuration: AppConfiguration.claudePaywallConfiguration
                )
            }
            .alert(
                AppConfiguration.displayName,
                isPresented: Binding(
                    get: { statusMessage != nil },
                    set: { if !$0 { statusMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(statusMessage ?? "")
            }
        }
        .tint(theme.accentColor)
        .animation(.smooth, value: theme.id)
    }

    private var aboutSection: some View {
        Section("About") {
            Link(destination: AppConfiguration.supportURL) {
                Label("Contact Support", systemImage: "questionmark.circle")
            }

            Button {
                requestReview()
            } label: {
                Label("Rate the App", systemImage: "star")
            }

            if let appStoreURL = AppConfiguration.appStoreURL {
                ShareLink(item: appStoreURL) {
                    Label("Share App", systemImage: "square.and.arrow.up")
                }
            }

            Link(destination: AppConfiguration.privacyURL) {
                Label("Privacy Policy", systemImage: "hand.raised")
            }

            Link(destination: AppConfiguration.termsURL) {
                Label("Terms of Service", systemImage: "doc.text")
            }

            LabeledContent("Version", value: appVersion)
        }
    }

    #if DEBUG
    private var developerSection: some View {
        Section {
            Toggle(
                "Use Simulated Purchases",
                isOn: Binding(
                    get: { purchases.isUsingSimulatedPurchases },
                    set: { enabled in
                        Task {
                            isChangingPurchaseMode = true
                            await purchases.setSimulatedPurchasesEnabled(enabled)
                            isChangingPurchaseMode = false
                        }
                    }
                )
            )
            .disabled(purchases.isBusy || isChangingPurchaseMode)

            LabeledContent(
                "Purchase mode",
                value: purchases.isUsingSimulatedPurchases ? "Simulated" : "Live StoreKit"
            )
            LabeledContent("Pro entitlement", value: developerEntitlementTitle)

            Button("Reset Simulated Purchases", systemImage: "arrow.counterclockwise") {
                Task {
                    await purchases.resetSimulatedPurchases()
                    statusMessage = "Simulated purchases were reset."
                }
            }
            .disabled(!purchases.isUsingSimulatedPurchases || purchases.isBusy || isChangingPurchaseMode)

            Button("Show Claude Paywall", systemImage: "creditcard.fill") {
                isShowingPaywall = true
            }

            NavigationLink {
                StarterScreenshotStudioView()
            } label: {
                Label("Screenshot Studio", systemImage: "photo.stack.fill")
            }

            NavigationLink {
                StarterPromoVideoStudioView()
            } label: {
                Label("Promo Video Studio", systemImage: "film.stack.fill")
            }

            LabeledContent("Built with", value: "AppFoundation 0.1.11")
        } header: {
            Text("Developer")
        }
    }

    private var developerEntitlementTitle: String {
        switch purchases.entitlementState {
        case .checking: "Checking"
        case .inactive: "Free"
        case .active: "Pro"
        }
    }
    #endif

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }
}

#Preview {
    SettingsView()
        .environment(AppConfiguration.makePreviewPurchaseManager())
        .environment(AppConfiguration.makeThemeManager())
}
