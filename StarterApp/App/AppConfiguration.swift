import AppFoundation
import Foundation

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

    static let paywallConfiguration = PaywallConfiguration(
        title: "Get more StarterApp",
        subtitle: "Choose the plan that's right for you",
        planTitle: "StarterApp Pro",
        planSubtitle: "Everything you need, without limits",
        features: [
            PaywallFeature(
                id: "all-features",
                systemImage: "sparkles",
                title: "All Pro features",
                message: "Unlock every premium feature in StarterApp."
            ),
            PaywallFeature(
                id: "updates",
                systemImage: "arrow.down.circle",
                title: "Future updates",
                message: "Get every new Pro feature as it ships."
            ),
            PaywallFeature(
                id: "limits",
                systemImage: "infinity",
                title: "No limits",
                message: "Remove free-plan usage limits."
            ),
        ],
        preferredProductID: yearlyProductID,
        purchaseButtonTitle: "Get Pro plan",
        privacyURL: privacyURL,
        termsURL: termsURL
    )

    static func makePurchaseManager() -> PurchaseManager {
        PurchaseManager(
            configuration: purchaseConfiguration,
            simulated: isSimulatedPurchaseModeEnabled,
            simulatedProducts: simulatedProducts,
            simulatedPersistenceKey: "com.hoangbkit.starterapp.simulated-purchases"
        )
    }

    static func makePreviewPurchaseManager() -> PurchaseManager {
        PurchaseManager(
            configuration: purchaseConfiguration,
            simulated: true,
            simulatedProducts: simulatedProducts,
            simulatedOperationDelay: .milliseconds(0)
        )
    }
}
