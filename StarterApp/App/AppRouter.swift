import Foundation
import Observation

@MainActor
@Observable
final class AppRouter {
    static let onboardingCompletionKey = "hasCompletedOnboarding"

    private(set) var launchState: AppLaunchState = .preparing

    @ObservationIgnored
    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func prepare() {
        launchState = defaults.bool(forKey: Self.onboardingCompletionKey)
            ? .main
            : .onboarding
    }

    func completeOnboarding() {
        defaults.set(true, forKey: Self.onboardingCompletionKey)
        launchState = .main
    }

    func showOnboarding() {
        launchState = .onboarding
    }

    func failLaunch(with message: String) {
        launchState = .failed(message: message)
    }

    #if DEBUG
    func resetOnboarding() {
        defaults.removeObject(forKey: Self.onboardingCompletionKey)
        launchState = .onboarding
    }
    #endif
}
