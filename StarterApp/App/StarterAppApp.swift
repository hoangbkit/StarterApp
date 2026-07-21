import AppFoundation
import SwiftUI
import UIKit

@main
@MainActor
struct StarterAppApp: App {
    @State private var purchases = AppConfiguration.makePurchaseManager()
    @State private var themes = ThemeManager(catalog: .foundationDefaults)

    init() {
        let navigationBar = UINavigationBar.appearance()
        navigationBar.largeTitleTextAttributes = [
            .font: Self.roundedSystemFont(size: 34, weight: .bold),
        ]
        navigationBar.titleTextAttributes = [
            .font: Self.roundedSystemFont(size: 17, weight: .semibold),
        ]
    }

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(purchases)
                .environment(themes)
                .managesPurchases(purchases)
                .appFoundationTheme(themes)
                .synchronizesThemeAccess(themes, hasPro: purchases.hasPro)
                .environment(\.font, .system(.body, design: .rounded))
        }
    }

    private static func roundedSystemFont(size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        guard let roundedDescriptor = systemFont.fontDescriptor.withDesign(.rounded) else {
            return systemFont
        }
        return UIFont(descriptor: roundedDescriptor, size: size)
    }
}
