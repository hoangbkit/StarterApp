import AppFoundation
import SwiftUI

@MainActor
struct AppRootView: View {
    @Environment(\.appFoundationTheme) private var theme
    @State private var router: AppRouter

    init(router: AppRouter = AppRouter()) {
        _router = State(initialValue: router)
    }

    var body: some View {
        ZStack {
            StarterThemeBackground(theme: theme)

            Group {
                switch router.launchState {
                case .preparing:
                    StarterThemeCard(theme: theme, emphasis: .quiet) {
                        HStack(spacing: 12) {
                            ProgressView()
                                .tint(theme.accentColor)
                            Text("Preparing \(AppConfiguration.displayName)…")
                                .foregroundStyle(theme.primaryForegroundColor)
                        }
                    }
                    .padding(24)
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
                    StarterThemeCard(theme: theme, emphasis: .prominent, padding: 24) {
                        VStack(spacing: 18) {
                            StarterSymbolBadge(
                                systemImage: "exclamationmark.triangle.fill",
                                theme: theme,
                                size: 58
                            )

                            VStack(spacing: 7) {
                                Text("Unable to Start")
                                    .font(.title2.weight(.bold))
                                Text(message)
                                    .font(.subheadline)
                                    .foregroundStyle(theme.secondaryForegroundColor)
                                    .multilineTextAlignment(.center)
                            }

                            Button("Try Again") {
                                router.prepare()
                            }
                            .buttonStyle(StarterPrimaryButtonStyle(theme: theme))
                        }
                        .foregroundStyle(theme.primaryForegroundColor)
                    }
                    .padding(24)
                }
            }
        }
        .animation(.smooth, value: theme.id)
        .task {
            if router.launchState == .preparing {
                router.prepare()
            }
        }
    }
}

#Preview {
    AppRootView()
        .environment(AppConfiguration.makePreviewPurchaseManager())
}
