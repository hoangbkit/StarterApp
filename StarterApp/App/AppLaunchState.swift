enum AppLaunchState: Equatable {
    case preparing
    case onboarding
    case main
    case failed(message: String)
}
