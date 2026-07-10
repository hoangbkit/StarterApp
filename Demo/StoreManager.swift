import Foundation
import StoreKit
import UIKit
import os

/// Handles product loading, purchases, and entitlement state using StoreKit 2.
///
/// Production notes:
/// - `isPro` is derived from `Transaction.currentEntitlements`, the source of
///   truth Apple recommends for entitlement checks (it automatically excludes
///   expired/revoked transactions, so there's nothing to compute manually).
/// - Entitlements are re-checked on init, after purchase/restore, on every
///   `Transaction.updates` event, and whenever the app returns to the
///   foreground — that last one matters because a subscription can lapse
///   (billing failure past its grace period) while the app is simply sitting
///   in the background with no StoreKit event to react to.
/// - `subscriptionRenewalState` surfaces grace period / billing retry / expired
///   so UI can show accurate messaging instead of a binary Pro/Free flag.
@MainActor
final class StoreManager: ObservableObject {

    enum PurchaseState: Equatable {
        case idle
        /// `productID` is nil for restore, since no single product is "purchasing".
        case purchasing(Product.ID?)
        case pendingApproval
        case failed(String)
    }

    enum ProductsState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }

    static let monthlyID = "com.hoangbkit.Demo.pro.monthly"
    static let yearlyID = "com.hoangbkit.Demo.pro.yearly"

    @Published private(set) var products: [Product] = []
    @Published private(set) var productsState: ProductsState = .idle
    @Published private(set) var isPro = false
    @Published private(set) var subscriptionRenewalState: Product.SubscriptionInfo.RenewalState?
    @Published var purchaseState: PurchaseState = .idle

    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "com.hoangbkit.Demo",
        category: "StoreManager"
    )

    private var transactionListener: Task<Void, Never>?
    private var foregroundObserver: NSObjectProtocol?
    private let productLoadMaxAttempts = 3

    init() {
        transactionListener = listenForTransactionUpdates()
        foregroundObserver = NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
                await self?.refreshEntitlements()
            }
        }
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
        if let foregroundObserver {
            NotificationCenter.default.removeObserver(foregroundObserver)
        }
    }

    // MARK: - Products

    /// Loads the store's products with a short retry/backoff so a single
    /// network hiccup on cold start doesn't leave the paywall empty forever.
    func loadProducts() async {
        productsState = .loading
        var lastError: Error?

        for attempt in 1...productLoadMaxAttempts {
            do {
                let storeProducts = try await Product.products(for: [Self.monthlyID, Self.yearlyID])
                guard !storeProducts.isEmpty else { throw StoreError.noProductsReturned }

                let order = [Self.monthlyID, Self.yearlyID]
                products = storeProducts.sorted {
                    (order.firstIndex(of: $0.id) ?? .max) < (order.firstIndex(of: $1.id) ?? .max)
                }
                productsState = .loaded
                return
            } catch {
                lastError = error
                logger.error("loadProducts attempt \(attempt) failed: \(String(describing: error), privacy: .public)")
                if attempt < productLoadMaxAttempts {
                    try? await Task.sleep(for: .seconds(Double(attempt) * 1.5))
                }
            }
        }

        productsState = .failed(Self.userMessage(for: lastError ?? StoreError.noProductsReturned))
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async {
        purchaseState = .purchasing(product.id)
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                purchaseState = .idle

            case .pending:
                // Ask to Buy (Family Sharing) or another approval step is in
                // progress. The transaction will arrive later via
                // Transaction.updates once approved/declined.
                purchaseState = .pendingApproval

            case .userCancelled:
                purchaseState = .idle

            @unknown default:
                purchaseState = .idle
            }
        } catch {
            logger.error("Purchase failed for \(product.id, privacy: .public): \(String(describing: error), privacy: .public)")
            purchaseState = .failed(Self.userMessage(for: error))
        }
    }

    /// Whether the given product (or, if nil, a restore) is currently in flight.
    func isPurchasing(_ productID: Product.ID?) -> Bool {
        if case .purchasing(let id) = purchaseState { return id == productID }
        return false
    }

    // MARK: - Restore

    func restorePurchases() async {
        purchaseState = .purchasing(nil)
        do {
            try await AppStore.sync()
            await refreshEntitlements()
            purchaseState = .idle
        } catch {
            logger.error("Restore failed: \(String(describing: error), privacy: .public)")
            purchaseState = .failed(Self.userMessage(for: error))
        }
    }

    // MARK: - Entitlements

    func refreshEntitlements() async {
        var hasPro = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                guard transaction.productID == Self.monthlyID || transaction.productID == Self.yearlyID else { continue }
                guard transaction.revocationDate == nil else { continue }
                hasPro = true
            } catch {
                logger.error("Skipped an unverifiable entitlement: \(String(describing: error), privacy: .public)")
            }
        }

        isPro = hasPro
        subscriptionRenewalState = await fetchRenewalState()
    }

    /// Grace period / billing retry / expired, purely for UI messaging.
    /// `isPro` above is unaffected by this — it always reflects StoreKit's
    /// own verified entitlement state.
    private func fetchRenewalState() async -> Product.SubscriptionInfo.RenewalState? {
        guard let subscription = products.first(where: {
            $0.id == Self.monthlyID || $0.id == Self.yearlyID
        })?.subscription else { return nil }

        guard let statuses = try? await subscription.status else { return nil }

        for status in statuses {
            guard case .verified(let transaction) = status.transaction,
                  transaction.productID == Self.monthlyID || transaction.productID == Self.yearlyID
            else { continue }
            return status.state
        }
        return nil
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.refreshEntitlements()
                } catch {
                    self.logger.error("Dropped an unverifiable transaction update: \(String(describing: error), privacy: .public)")
                }
            }
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw StoreError.failedVerification(error)
        case .verified(let safe):
            return safe
        }
    }

    // MARK: - Errors

    enum StoreError: LocalizedError {
        case failedVerification(Error)
        case noProductsReturned

        var errorDescription: String? {
            switch self {
            case .failedVerification:
                return "This purchase could not be verified. Please contact support if this continues."
            case .noProductsReturned:
                return "We couldn't load subscription plans. Check your connection and try again."
            }
        }
    }

    /// Maps StoreKit's error types to copy that's safe to show a user,
    /// instead of leaking raw StoreKit error strings into the UI.
    private static func userMessage(for error: Error) -> String {
        if let storeKitError = error as? StoreKitError {
            switch storeKitError {
            case .userCancelled:
                return "Purchase cancelled."
            case .networkError:
                return "No internet connection. Check your network and try again."
            case .systemError:
                return "The App Store couldn't complete this request. Please try again later."
            case .notAvailableInStorefront:
                return "This plan isn't available in your region's App Store."
            case .notEntitled:
                return "You're not entitled to this purchase."
            case .unknown:
                return "Something went wrong. Please try again."
            @unknown default:
                return "Something went wrong. Please try again."
            }
        }

        if let purchaseError = error as? Product.PurchaseError {
            switch purchaseError {
            case .productUnavailable:
                return "This plan is currently unavailable."
            case .purchaseNotAllowed:
                return "Purchases are restricted on this device."
            case .ineligibleForOffer:
                return "You're not eligible for this offer."
            case .invalidQuantity, .invalidOfferIdentifier, .invalidOfferPrice,
                 .invalidOfferSignature, .missingOfferParameters:
                return "This offer couldn't be applied. Please try again."
            @unknown default:
                return "Something went wrong. Please try again."
            }
        }

        if let storeError = error as? StoreError {
            return storeError.errorDescription ?? "Something went wrong. Please try again."
        }

        return "Something went wrong. Please try again."
    }
}
