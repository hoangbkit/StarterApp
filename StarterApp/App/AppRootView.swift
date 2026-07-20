import SwiftUI

@MainActor
struct AppRootView: View {
    @State private var router: AppRouter

    init(router: AppRouter = AppRouter()) {
        _router = State(initialValue: router)
    }

    var body: some View {
        Group {
            switch router.launchState {
            case .preparing:
                ProgressView("Preparing \(AppConfiguration.displayName)…")
                    .accessibilityIdentifier("app.preparing")

            case .onboarding:
                OnboardingView {
                    router.completeOnboarding()
                }

            case .main:
                ContentView {
                    router.showOnboarding()
                }

            case .failed(let message):
                ContentUnavailableView {
                    Label("Unable to Start", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try Again") {
                        router.prepare()
                    }
                }
            }
        }
        .task {
            if router.launchState == .preparing {
                router.prepare()
            }
        }
    }
}

#Preview {
    AppRootView()
        .environment(AppConfiguration.makePreviewPurchaseController())
}
