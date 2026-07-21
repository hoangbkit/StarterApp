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
    @AppStorage(AppConfiguration.simulatedPurchaseModeDefaultsKey)
    private var simulatedPurchasesEnabled = false
    @State private var isChangingPurchaseMode = false
    #endif

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
                    Text("Appearance")
                }
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

                #if DEBUG
                Section {
                    Toggle(isOn: $simulatedPurchasesEnabled) {
                        Label("Simulated Purchases", systemImage: "hammer.fill")
                    }
                    .disabled(purchases.isBusy || isChangingPurchaseMode)
                    .onChange(of: simulatedPurchasesEnabled) { _, enabled in
                        Task {
                            await changePurchaseMode(simulated: enabled)
                        }
                    }

                    LabeledContent(
                        "Current Mode",
                        value: purchases.isUsingSimulatedPurchases ? "Simulated" : "Live StoreKit"
                    )

                    if isChangingPurchaseMode {
                        HStack {
                            ProgressView()
                                .tint(theme.accentColor)
                            Text("Changing purchase mode…")
                                .foregroundStyle(theme.secondaryForegroundColor)
                        }
                    }

                    if purchases.isUsingSimulatedPurchases {
                        Button("Reset Simulated Purchases", role: .destructive) {
                            Task {
                                await purchases.resetSimulatedPurchases()
                                restoreMessage = "Simulated purchases were reset."
                            }
                        }
                        .disabled(purchases.isBusy || isChangingPurchaseMode)
                    }
                } header: {
                    Text("Developer")
                } footer: {
                    Text("Uses AppFoundation's configurable in-process purchase simulator. Release builds always use live StoreKit.")
                }
                .listRowBackground(theme.surfaceColor)
                #endif

                Section {
                    Link(destination: AppConfiguration.supportURL) {
                        Label("Contact Support", systemImage: "questionmark.circle")
                    }

                    Button {
                        requestReview()
                    } label: {
                        Label("Rate the App", systemImage: "star")
                    }

                    ShareLink(item: AppConfiguration.supportURL) {
                        Label("Share App", systemImage: "square.and.arrow.up")
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
            }
            .scrollContentBackground(.hidden)
            .background(StarterThemeBackground(theme: theme))
            .listSectionSpacing(18)
            .listSectionSeparatorTint(theme.borderColor)
            .foregroundStyle(theme.primaryForegroundColor)
            .navigationTitle("Settings")
            .navigationSubtitle("Make StarterApp feel like yours")
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

    #if DEBUG
    private func changePurchaseMode(simulated: Bool) async {
        isChangingPurchaseMode = true
        await purchases.setSimulatedPurchasesEnabled(simulated)
        isChangingPurchaseMode = false
    }
    #endif
}

#Preview {
    SettingsView()
        .environment(AppConfiguration.makePreviewPurchaseManager())
        .environment(ThemeManager(catalog: .foundationDefaults))
}
