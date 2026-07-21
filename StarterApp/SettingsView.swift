import AppFoundation
import StoreKit
import SwiftUI

struct SettingsView: View {
    @Environment(PurchaseController.self) private var purchases
    @Environment(ThemeManager.self) private var themes
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    @State private var isShowingOfferCodeSheet = false
    @State private var isShowingPaywall = false
    @State private var restoreMessage: String?

    #if DEBUG
    @AppStorage(AppConfiguration.simulatedPurchaseModeDefaultsKey)
    private var simulatedPurchasesEnabled = AppConfiguration.isSimulatedPurchaseModeEnabled
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

                Section {
                    Button {
                        Task { await restore() }
                    } label: {
                        HStack {
                            Label("Restore Purchases", systemImage: "arrow.clockwise")
                            Spacer()
                            if purchases.isBusy {
                                ProgressView()
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

                #if DEBUG
                Section {
                    Toggle(isOn: $simulatedPurchasesEnabled) {
                        Label("Simulated Purchases", systemImage: "hammer.fill")
                    }
                    .disabled(purchases.isBusy)

                    if purchases.isUsingSimulatedPurchases {
                        Button("Reset Simulated Purchases", role: .destructive) {
                            Task {
                                await purchases.resetSimulatedPurchases()
                                restoreMessage = "Simulated purchases were reset."
                            }
                        }
                        .disabled(purchases.isBusy)
                    }
                } header: {
                    Text("Developer")
                } footer: {
                    Text("Switches between live StoreKit and AppFoundation's in-process purchase simulator. The change applies immediately.")
                }
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

                Section {
                    Link(destination: AppConfiguration.privacyURL) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: AppConfiguration.termsURL) {
                        Label("Terms of Service", systemImage: "doc.text")
                    }
                }

                Section {
                    HStack {
                        Label("Version", systemImage: "info.circle")
                        Spacer()
                        Text(appVersion)
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .offerCodeRedemption(isPresented: $isShowingOfferCodeSheet)
            .sheet(isPresented: $isShowingPaywall) {
                ClaudePaywallView(
                    purchases: purchases,
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
}

#Preview {
    SettingsView()
        .environment(AppConfiguration.makePreviewPurchaseController())
        .environment(ThemeManager(catalog: .foundationDefaults))
}
