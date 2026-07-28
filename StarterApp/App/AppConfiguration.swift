import AppFoundation
import Foundation

@MainActor
enum AppConfiguration {
    private static let fallbackDisplayName = "StarterApp"
    private static let fallbackBundleIdentifier = "com.hoangbkit.starterapp"

    static var displayName: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
            ?? Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String
            ?? fallbackDisplayName
    }

    static var bundleIdentifier: String {
        Bundle.main.bundleIdentifier ?? fallbackBundleIdentifier
    }

    static let appStoreID: String? = nil

    static var appStoreURL: URL? {
        guard let appStoreID, !appStoreID.isEmpty else { return nil }
        return URL(string: "https://apps.apple.com/app/id\(appStoreID)")
    }

    static let yearlyProductID = "com.hoangbkit.starterapp.pro.yearly"
    static let lifetimeProductID = "com.hoangbkit.starterapp.pro.lifetime"

    static var simulatedPurchaseModeDefaultsKey: String {
        "\(bundleIdentifier).developer.simulated-purchases-enabled"
    }

    static var simulatedPurchasePersistenceKey: String {
        "\(bundleIdentifier).simulated-purchases"
    }

    static var themeStateKey: String {
        "\(bundleIdentifier).theme-state"
    }

    static let supportURL = URL(string: "https://example.com/contact")!
    static let privacyURL = URL(string: "https://example.com/privacy")!
    static let termsURL = URL(string: "https://example.com/terms")!

    static let purchaseFeatures: [PurchaseFeature] = [
        PurchaseFeature(
            id: "all-features",
            title: "All Pro features",
            freeValue: "Limited",
            proValue: "Unlimited"
        ),
        PurchaseFeature(
            id: "themes-icons",
            title: "Themes and icons",
            freeValue: "Default",
            proValue: "All"
        ),
        PurchaseFeature(
            id: "updates",
            title: "Future updates",
            freeValue: "Core",
            proValue: "Included"
        ),
    ]

    static let purchaseConfiguration = PurchaseConfiguration(
        productIDs: [
            yearlyProductID,
            lifetimeProductID,
        ],
        preferredProductID: lifetimeProductID,
        features: purchaseFeatures
    )

    static let simulatedProducts: [PurchaseProduct] = [
        PurchaseProduct(
            id: yearlyProductID,
            displayName: "\(displayName) Pro Yearly",
            description: "Annual access to every \(displayName) Pro feature.",
            displayPrice: "$9.99",
            price: 9.99,
            subscriptionPeriod: .init(value: 1, unit: .year)
        ),
        PurchaseProduct(
            id: lifetimeProductID,
            displayName: "\(displayName) Pro Lifetime",
            description: "Pay once and keep \(displayName) Pro forever.",
            displayPrice: "$24.99",
            price: 24.99
        ),
    ]

    static let proPaywallConfiguration = FoundationPaywallConfiguration(
        title: "Unlock \(displayName) Pro",
        subtitle: "Choose yearly access or pay once for lifetime access.",
        features: [
            FoundationPaywallFeature(
                id: "all-features",
                systemImage: "checkmark",
                title: "All Pro features",
                message: "Unlock every premium feature in \(displayName)."
            ),
            FoundationPaywallFeature(
                id: "themes-icons",
                systemImage: "checkmark",
                title: "Themes and icons",
                message: "Use every Pro theme and alternate app icon."
            ),
            FoundationPaywallFeature(
                id: "updates",
                systemImage: "checkmark",
                title: "Future updates",
                message: "Get every new Pro feature as it ships."
            ),
        ],
        purchaseButtonTitle: "Continue",
        highlightedProductID: lifetimeProductID,
        privacyURL: privacyURL,
        termsURL: termsURL
    )

    static let proUpsellConfiguration = LimitReachedUpsellConfiguration(
        title: "Unlock more with Pro",
        message: "Keep using the free foundation, or unlock every premium theme, icon, and feature.",
        symbolName: "crown.fill",
        comparisonTitle: "Free vs Pro",
        comparisonSubtitle: "Choose the access level that fits your app.",
        unlockButtonTitle: "View Pro plans",
        comparisonAccessibilityLabel: "StarterApp Free and Pro feature comparison"
    )

    static let proCelebrationConfiguration = FoundationProCelebrationConfiguration(
        navigationTitle: "\(displayName) Pro",
        comparisonAccessibilityLabel: "StarterApp Free and Pro comparison"
    )

    static let proPlanSettingsConfiguration = ProPlanSettingsConfiguration(
        sectionTitle: "\(displayName) Pro",
        activePlanTitle: "\(displayName) Pro",
        unlockTitle: "Unlock \(displayName) Pro"
    )

    static func makePurchaseManager() -> PurchaseManager {
        PurchaseManager(
            configuration: purchaseConfiguration,
            simulated: true,
            simulatedProducts: simulatedProducts,
            simulatedPersistenceKey: simulatedPurchasePersistenceKey
        )
    }

    static func makeThemeManager() -> ThemeManager {
        ThemeManager(
            catalog: .foundationDefaults,
            stateStore: UserDefaultsThemeStateStore(storageKey: themeStateKey)
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