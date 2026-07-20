import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: StoreManager
    @State private var isShowingPaywall = false
    @State private var isShowingOnboarding = false
    @State private var isShowingSettings = false

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

                if store.isPro {
                    Label("Pro unlocked", systemImage: "star.fill")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.orange)
                        .padding(.top, 8)
                } else {
                    Button("Upgrade to Pro") {
                        isShowingPaywall = true
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.black)
                    .padding(.top, 8)
                }

                Button("Show Onboarding") {
                    isShowingOnboarding = true
                }
                .buttonStyle(.bordered)
                .padding(.top, 8)
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
                }
            }
        }
        .sheet(isPresented: $isShowingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $isShowingSettings) {
            SettingsView()
        }
        .fullScreenCover(isPresented: $isShowingOnboarding) {
            OnboardingView(hasCompletedOnboarding: Binding(
                get: { !isShowingOnboarding },
                set: { isShowingOnboarding = !$0 }
            ))
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(StoreManager())
}
