import AppFoundation
import SwiftUI

struct ContentView: View {
    @Environment(PurchaseController.self) private var purchases

    let onShowOnboarding: () -> Void

    @State private var isShowingPaywall = false
    @State private var isShowingSettings = false

    init(onShowOnboarding: @escaping () -> Void = {}) {
        self.onShowOnboarding = onShowOnboarding
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 72, height: 72)
                    .foregroundStyle(.green)

                Text("You're all set!")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("This is the main app screen.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)

                entitlementContent

                Button("Show Onboarding") {
                    onShowOnboarding()
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)

                #if DEBUG
                if purchases.isUsingSimulatedPurchases {
                    Label("Debug purchase simulator", systemImage: "hammer.fill")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.top, 4)
                }
                #endif
            }
            .padding()
            .navigationTitle(AppConfiguration.displayName)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isShowingSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                    .accessibilityLabel("Settings")
                }
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            ClaudePaywallView(
                purchases: purchases,
                configuration: AppConfiguration.paywallConfiguration
            )
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
    }

    @ViewBuilder
    private var entitlementContent: some View {
        switch purchases.entitlementState {
        case .checking:
            ProgressView("Checking Pro access…")
                .padding(.top, 8)

        case .inactive:
            Button("Upgrade to Pro") {
                isShowingPaywall = true
            }
            .buttonStyle(.borderedProminent)
            .tint(.black)
            .padding(.top, 8)

        case .active:
            Label("Pro unlocked", systemImage: "star.fill")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(.orange)
                .padding(.top, 8)
        }
    }
}

#Preview {
    ContentView()
        .environment(AppConfiguration.makePreviewPurchaseController())
}
