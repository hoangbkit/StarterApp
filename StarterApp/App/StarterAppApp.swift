import AppFoundation
import SwiftUI

@main
@MainActor
struct StarterAppApp: App {
    @State private var purchases = AppConfiguration.makePurchaseController()
    @State private var themes = ThemeManager(catalog: .foundationDefaults)

    #if DEBUG
    @AppStorage(AppConfiguration.simulatedPurchaseModeDefaultsKey)
    private var simulatedPurchasesEnabled = AppConfiguration.isSimulatedPurchaseModeEnabled
    #endif

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(purchases)
                .environment(themes)
                .managesPurchases(purchases)
                .appFoundationTheme(themes)
                .synchronizesThemeAccess(themes, hasPro: purchases.isEntitled)
                #if DEBUG
                .task(id: simulatedPurchasesEnabled) {
                    guard purchases.isUsingSimulatedPurchases != simulatedPurchasesEnabled else {
                        return
                    }

                    let replacement = AppConfiguration.makePurchaseController(
                        simulated: simulatedPurchasesEnabled
                    )
                    purchases = replacement
                    await replacement.prepare()
                }
                #endif
        }
    }
}
