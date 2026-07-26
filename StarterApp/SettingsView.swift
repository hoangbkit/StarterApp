import AppFoundation
import StoreKit
import SwiftUI

struct SettingsView: View {
    @Environment(PurchaseManager.self) private var purchases
    @Environment(ThemeManager.self) private var themes
    @Environment(\.appFoundationTheme) private var theme
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    @State private var isShowingOfferCodeSheet = false
    @State private var isShowingPaywall = false
    @State private var restoreMessage: String?

    #if DEBUG
    @State private var isChangingPurchaseMode = false
    #endif

    private var appIcons: [AppIconOption] {
        [
            AppIconOption(
                title: "Default",
                alternateIconName: nil,
                previewImageName: "AppIcon",
                accentColor: theme.accentColor
            )
        ]
    }

    var body: some View {
        NavigationStack {
            List {
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
                } footer: {
                    Text("Choose the theme used throughout the app.")
                }
                .listRowBackground(theme.surfaceColor)

                AppIconPickerSection(
                    icons: appIcons,
                    footer: "Add alternate icon assets and AppIconOption entries when this app needs more choices.",
                    isLocked: { icon in
                        icon.requiresUnlock && !purchases.hasPro
                    },
                    onRequestUnlock: { _ in
                        isShowingPaywall = true
                    }
                )
                .listRowBackground(theme.surfaceColor)

                Section {
                    Button {
                        Task { await restore() }
                    } label: {
                        HStack {
                            Label("Restore Purchases", systemImage: "arrow.clockwise")
                            Spacer()
                            if purchases.isBusy {
                                ProgressView()
                                    .tint(theme.accentColor)
                            }
                        }
                    }
                    .disabled(purchases.isBusy)

                    Button {
                        isShowingOfferCodeSheet = true
                    } label: {
                        Label("Redeem Code", systemImage: "gift")
                    }
                } header: {
                    Text("Purchases")
                }
                .listRowBackground(theme.surfaceColor)

                Section {
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
                }
                .listRowBackground(theme.surfaceColor)

                Section {
                    Link(destination: AppConfiguration.privacyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: AppConfiguration.termsURL) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }
                .listRowBackground(theme.surfaceColor)

                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(theme.secondaryForegroundColor)
                    }
                }
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
            .offerCodeRedemption(isPresented: $isShowingOfferCodeSheet)
            .sheet(isPresented: $isShowingPaywall) {
                PaywallView(
                    purchaseManager: purchases,
                    configuration: AppConfiguration.paywallConfiguration
                )
            }
            .alert(
                "Restore Purchases",
                isPresented: Binding(
                    get: { restoreMessage != nil },
                    set: { if !$0 { restoreMessage = nil } }
                )
            ) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(restoreMessage ?? "")
            }
        }
        .tint(theme.accentColor)
        .animation(.smooth, value: theme.id)
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

            LabeledContent("Purchase mode", value: purchases.isUsingSimulatedPurchases ? "Simulated" : "Live StoreKit")
            LabeledContent("Pro entitlement", value: developerEntitlementTitle)

            Button("Reset Simulated Purchases", systemImage: "arrow.counterclockwise") {
                Task {
                    await purchases.resetSimulatedPurchases()
                    restoreMessage = "Simulated purchases were reset."
                }
            }
            .disabled(!purchases.isUsingSimulatedPurchases || purchases.isBusy || isChangingPurchaseMode)

            Button("Show Paywall", systemImage: "creditcard.fill") {
                isShowingPaywall = true
            }
        } header: {
            Text("Developer")
        } footer: {
            Text("Debug-only AppFoundation purchase controls and presentation previews. Release builds always use live StoreKit.")
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

    private func restore() async {
        switch await purchases.restorePurchases() {
        case .restored:
            restoreMessage = "Your purchases have been restored."
        case .nothingToRestore:
            restoreMessage = "No previous purchases were found."
        case .failed(let failure):
            restoreMessage = failure.message
            purchases.clearActivity()
        }
    }
}

#Preview {
    SettingsView()
        .environment(AppConfiguration.makePreviewPurchaseManager())
        .environment(AppConfiguration.makeThemeManager())
}
