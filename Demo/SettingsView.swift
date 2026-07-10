import SwiftUI
import StoreKit

struct SettingsView: View {
    @EnvironmentObject private var store: StoreManager
    @Environment(\.dismiss) private var dismiss
    @Environment(\.requestReview) private var requestReview

    @State private var isRestoring = false
    @State private var isShowingOfferCodeSheet = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        Task { await restore() }
                    } label: {
                        HStack {
                            Label("Restore Purchases", systemImage: "arrow.clockwise")
                            Spacer()
                            if isRestoring {
                                ProgressView()
                            }
                        }
                    }
                    .disabled(isRestoring)

                    Button {
                        isShowingOfferCodeSheet = true
                    } label: {
                        Label("Redeem Code", systemImage: "gift")
                    }
                }

                Section {
                    Link(destination: URL(string: "https://example.com/support")!) {
                        Label("Contact Support", systemImage: "questionmark.circle")
                    }

                    Button {
                        requestReview()
                    } label: {
                        Label("Rate the App", systemImage: "star")
                    }

                    ShareLink(item: URL(string: "https://example.com")!) {
                        Label("Share App", systemImage: "square.and.arrow.up")
                    }
                }

                Section {
                    Link(destination: URL(string: "https://example.com/privacy")!) {
                        Label("Privacy Policy", systemImage: "hand.raised")
                    }

                    Link(destination: URL(string: "https://example.com/terms")!) {
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
                    Button("Done") { dismiss() }
                }
            }
            .offerCodeRedemption(isPresented: $isShowingOfferCodeSheet)
            .alert("Restore Purchases", isPresented: Binding(
                get: { restoreMessage != nil },
                set: { if !$0 { restoreMessage = nil } }
            )) {
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
        isRestoring = true
        await store.restorePurchases()
        isRestoring = false
        restoreMessage = store.isPro ? "Your purchases have been restored." : "No previous purchases were found."
    }
}

#Preview {
    SettingsView()
        .environmentObject(StoreManager())
}
