import AppFoundation
import SwiftUI

@main
@MainActor
struct StarterAppApp: App {
    @State private var purchases = AppConfiguration.makePurchaseController()

    var body: some Scene {
        WindowGroup {
            AppRootView()
                .environment(purchases)
                .managesPurchases(purchases)
        }
    }
}
