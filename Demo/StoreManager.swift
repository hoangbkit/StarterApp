import Foundation
import StoreKit

/// Handles product loading, purchases, and entitlement state using StoreKit 2.
@MainActor
final class StoreManager: ObservableObject {

    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case failed(String)
    }

    static let monthlyID = "com.hoangbkit.Demo.pro.monthly"
    static let yearlyID = "com.hoangbkit.Demo.pro.yearly"

    @Published private(set) var products: [Product] = []
    @Published private(set) var isPro = false
    @Published var purchaseState: PurchaseState = .idle

    private var transactionListener: Task<Void, Never>?

    init() {
        transactionListener = listenForTransactionUpdates()
        Task {
            await loadProducts()
            await refreshEntitlements()
        }
    }

    deinit {
        transactionListener?.cancel()
    }

    func loadProducts() async {
        do {
            let storeProducts = try await Product.products(for: [Self.monthlyID, Self.yearlyID])
            let order = [Self.monthlyID, Self.yearlyID]
            products = storeProducts.sorted {
                (order.firstIndex(of: $0.id) ?? .max) < (order.firstIndex(of: $1.id) ?? .max)
            }
        } catch {
            purchaseState = .failed("Couldn't load plans. Check your connection and try again.")
        }
    }

    func purchase(_ product: Product) async {
        purchaseState = .purchasing
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await refreshEntitlements()
                purchaseState = .idle
            case .userCancelled, .pending:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await refreshEntitlements()
        } catch {
            purchaseState = .failed("Restore failed. Please try again.")
        }
    }

    func refreshEntitlements() async {
        var hasPro = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == Self.monthlyID || transaction.productID == Self.yearlyID,
               transaction.revocationDate == nil {
                hasPro = true
            }
        }
        isPro = hasPro
    }

    private func listenForTransactionUpdates() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { return }
                if let transaction = try? self.checkVerified(result) {
                    await transaction.finish()
                    await self.refreshEntitlements()
                }
            }
        }
    }

    nonisolated private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw StoreError.failedVerification
        case .verified(let safe):
            return safe
        }
    }

    enum StoreError: LocalizedError {
        case failedVerification
        var errorDescription: String? { "This purchase could not be verified." }
    }
}
