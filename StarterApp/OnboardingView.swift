import AppFoundation
import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemImage: String
    let eyebrow: String
    let title: String
    let subtitle: String
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        systemImage: "hand.wave.fill",
        eyebrow: "Welcome",
        title: "A polished place to begin",
        subtitle: "StarterApp includes the shared foundation your next app needs, without locking in its identity."
    ),
    OnboardingPage(
        systemImage: "paintpalette.fill",
        eyebrow: "Theme aware",
        title: "Every screen follows your style",
        subtitle: "Backgrounds, surfaces, controls, settings, and paywalls update together when the active theme changes."
    ),
    OnboardingPage(
        systemImage: "checkmark.seal.fill",
        eyebrow: "Ready",
        title: "Make it yours",
        subtitle: "Replace the sample content with your feature while keeping the production-ready app shell."
    ),
]

struct OnboardingView: View {
    @Environment(\.appFoundationTheme) private var theme

    let onComplete: () -> Void

    @State private var pageIndex = 0

    var body: some View {
        ZStack {
            StarterThemeBackground(theme: theme)

            VStack(spacing: 12) {
                HStack {
                    Spacer()
                    Button("Skip", action: onComplete)
                        .buttonStyle(StarterSecondaryButtonStyle(theme: theme))
                        .opacity(pageIndex < onboardingPages.count - 1 ? 1 : 0)
                        .disabled(pageIndex >= onboardingPages.count - 1)
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)

                TabView(selection: $pageIndex) {
                    ForEach(Array(onboardingPages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page, theme: theme)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .indexViewStyle(.page(backgroundDisplayMode: .interactive))

                Button(action: advance) {
                    HStack(spacing: 9) {
                        Text(pageIndex == onboardingPages.count - 1 ? "Get Started" : "Continue")
                        Image(systemName: pageIndex == onboardingPages.count - 1 ? "checkmark" : "arrow.right")
                    }
                }
                .buttonStyle(StarterPrimaryButtonStyle(theme: theme))
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
        }
        .foregroundStyle(theme.primaryForegroundColor)
        .animation(.smooth, value: theme.id)
    }

    private func advance() {
        if pageIndex < onboardingPages.count - 1 {
            withAnimation(.snappy) {
                pageIndex += 1
            }
        } else {
            onComplete()
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage
    let theme: AppTheme

    var body: some View {
        StarterThemeCard(
            theme: theme,
            emphasis: .prominent,
            padding: 26,
            cornerRadius: 34
        ) {
            VStack(spacing: 24) {
                Spacer(minLength: 8)

                ZStack {
                    Circle()
                        .fill(theme.gradient)
                        .frame(width: 124, height: 124)
                        .shadow(color: theme.accentColor.opacity(0.28), radius: 24, y: 12)

                    Image(systemName: page.systemImage)
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(theme.primaryForegroundColor)
                }

                VStack(spacing: 11) {
                    StarterEyebrow(
                        title: page.eyebrow,
                        systemImage: "sparkles",
                        theme: theme
                    )

                    Text(page.title)
                        .font(.system(.title, design: .rounded, weight: .black))
                        .multilineTextAlignment(.center)

                    Text(page.subtitle)
                        .font(.body)
                        .foregroundStyle(theme.secondaryForegroundColor)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }

                Spacer(minLength: 8)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .foregroundStyle(theme.primaryForegroundColor)
        }
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
