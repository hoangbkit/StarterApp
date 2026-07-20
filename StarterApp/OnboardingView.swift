import SwiftUI

private struct OnboardingPage: Identifiable {
    let id = UUID()
    let systemImage: String
    let title: String
    let subtitle: String
}

private let onboardingPages: [OnboardingPage] = [
    OnboardingPage(
        systemImage: "hand.wave.fill",
        title: "Welcome",
        subtitle: "Glad to have you here. Let's take a quick look around."
    ),
    OnboardingPage(
        systemImage: "sparkles",
        title: "Do more, faster",
        subtitle: "This starter app shows a simple, reusable onboarding flow you can adapt for any app."
    ),
    OnboardingPage(
        systemImage: "checkmark.seal.fill",
        title: "You're ready",
        subtitle: "Tap Get Started to jump into the app."
    ),
]

struct OnboardingView: View {
    let onComplete: () -> Void

    @State private var pageIndex = 0

    var body: some View {
        VStack {
            TabView(selection: $pageIndex) {
                ForEach(Array(onboardingPages.enumerated()), id: \.element.id) { index, page in
                    OnboardingPageView(page: page)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .indexViewStyle(.page(backgroundDisplayMode: .always))

            Button(action: advance) {
                Text(pageIndex == onboardingPages.count - 1 ? "Get Started" : "Next")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 14))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
        }
        .safeAreaInset(edge: .top) {
            HStack {
                Spacer()
                Button("Skip", action: onComplete)
                    .padding(.trailing, 20)
                    .padding(.top, 12)
                    .opacity(pageIndex < onboardingPages.count - 1 ? 1 : 0)
                    .disabled(pageIndex >= onboardingPages.count - 1)
            }
        }
    }

    private func advance() {
        if pageIndex < onboardingPages.count - 1 {
            withAnimation {
                pageIndex += 1
            }
        } else {
            onComplete()
        }
    }
}

private struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: 20) {
            Spacer()

            Image(systemName: page.systemImage)
                .resizable()
                .scaledToFit()
                .frame(width: 96, height: 96)
                .foregroundStyle(Color.accentColor)

            Text(page.title)
                .font(.title)
                .fontWeight(.bold)

            Text(page.subtitle)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    OnboardingView(onComplete: {})
}
