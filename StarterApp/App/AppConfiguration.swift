import AppFoundation
import Foundation
import SwiftUI

@MainActor
enum AppConfiguration {
    static let displayName = "StarterApp"
    static let appStoreID: String? = nil

    static let monthlyProductID = "com.hoangbkit.starterapp.pro.monthly"
    static let yearlyProductID = "com.hoangbkit.starterapp.pro.yearly"
    static let simulatedPurchaseModeDefaultsKey = "com.hoangbkit.starterapp.developer.simulated-purchases-enabled"

    static let supportURL = URL(string: "https://example.com/support")!
    static let privacyURL = URL(string: "https://example.com/privacy")!
    static let termsURL = URL(string: "https://example.com/terms")!

    static let purchaseConfiguration = PurchaseConfiguration(
        productIDs: [
            monthlyProductID,
            yearlyProductID,
        ],
        preferredProductID: yearlyProductID
    )

    static let simulatedProducts: [StoreProduct] = [
        StoreProduct(
            id: monthlyProductID,
            displayName: "StarterApp Pro Monthly",
            description: "Monthly access to every StarterApp Pro feature.",
            displayPrice: "$4.99",
            price: 4.99,
            subscriptionPeriod: .init(value: 1, unit: .month)
        ),
        StoreProduct(
            id: yearlyProductID,
            displayName: "StarterApp Pro Yearly",
            description: "Annual access to every StarterApp Pro feature.",
            displayPrice: "$39.99",
            price: 39.99,
            subscriptionPeriod: .init(value: 1, unit: .year)
        ),
    ]

    static var isSimulatedPurchaseModeEnabled: Bool {
        #if DEBUG
        UserDefaults.standard.bool(forKey: simulatedPurchaseModeDefaultsKey)
        #else
        false
        #endif
    }

    static let paywallConfiguration = FoundationPaywallConfiguration(
        title: "Get more StarterApp",
        subtitle: "Choose the plan that's right for you",
        features: [
            FoundationPaywallFeature(
                id: "all-features",
                systemImage: "sparkles",
                title: "All Pro features",
                message: "Unlock every premium feature in StarterApp."
            ),
            FoundationPaywallFeature(
                id: "updates",
                systemImage: "arrow.down.circle",
                title: "Future updates",
                message: "Get every new Pro feature as it ships."
            ),
            FoundationPaywallFeature(
                id: "limits",
                systemImage: "infinity",
                title: "No limits",
                message: "Remove free-plan usage limits."
            ),
        ],
        purchaseButtonTitle: "Get Pro plan",
        highlightedProductID: yearlyProductID,
        privacyURL: privacyURL,
        termsURL: termsURL,
        theme: FoundationTheme(primary: .black, secondary: .black)
    )

    static func makePurchaseController() -> PurchaseController {
        PurchaseController(
            configuration: purchaseConfiguration,
            simulated: isSimulatedPurchaseModeEnabled,
            simulatedProducts: simulatedProducts,
            simulatedPersistenceKey: "com.hoangbkit.starterapp.simulated-purchases"
        )
    }

    static func makePreviewPurchaseController() -> PurchaseController {
        PurchaseController(
            configuration: purchaseConfiguration,
            simulated: true,
            simulatedProducts: simulatedProducts,
            simulatedOperationDelay: .milliseconds(0)
        )
    }
}
