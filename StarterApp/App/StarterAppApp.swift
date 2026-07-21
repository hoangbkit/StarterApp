import AppFoundation
import SwiftUI

@main
@MainActor
struct StarterAppApp: App {
    @State private var purchases = AppConfiguration.makePurchaseController()
    @State private var themes = ThemeManager(catalog: .foundationDefaults)

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(purchases)
                .environment(themes)
                .managesPurchases(purchases)
                .appFoundationTheme(themes)
                .synchronizesThemeAccess(themes, hasPro: purchases.isEntitled)
        }
    }
}
