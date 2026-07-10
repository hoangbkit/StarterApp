import SwiftUI
import StoreKit

struct PaywallView: View {
    @EnvironmentObject private var store: StoreManager
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProductID: String?

    private let features = [
        "Unlock every Pro feature in Demo",
        "Priority access to new updates",
        "Remove usage limits"
    ]

    private var monthly: Product? {
        store.products.first { $0.id == StoreManager.monthlyID }
    }

    private var yearly: Product? {
        store.products.first { $0.id == StoreManager.yearlyID }
    }

    private var selectedProduct: Product? {
        store.products.first { $0.id == selectedProductID }
    }

    /// Percent saved on the yearly plan vs. paying monthly for 12 months, computed from live prices.
    private var yearlySavingsPercent: Int? {
        guard let monthly, let yearly else { return nil }
        let monthlyAnnualCost = monthly.price * 12
        guard monthlyAnnualCost > 0 else { return nil }
        let savings = (monthlyAnnualCost - yearly.price) / monthlyAnnualCost * 100
        let percent = NSDecimalNumber(decimal: savings).intValue
        return percent > 0 ? percent : nil
    }

    private var isPurchasing: Bool {
        store.isPurchasing(selectedProductID)
    }

    private var alertTitle: String {
        if store.purchaseState == .pendingApproval { return "Waiting for Approval" }
        return "Something went wrong"
    }

    private var alertMessage: String? {
        switch store.purchaseState {
        case .failed(let message):
            return message
        case .pendingApproval:
            return "This purchase needs approval from your family organizer. You'll be notified once it's approved."
        default:
            return nil
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 28) {
                header
                planCard
                legalFooter
            }
            .padding(.horizontal, 20)
            .padding(.top, 8)
            .padding(.bottom, 32)
        }
        .background(Color(.systemGroupedBackground).ignoresSafeArea())
        .overlay(alignment: .topLeading) { closeButton }
        .task { selectDefaultPlanIfNeeded() }
        .onChange(of: store.products) { _, _ in selectDefaultPlanIfNeeded() }
        .onChange(of: store.isPro) { _, isPro in
            if isPro { dismiss() }
        }
        .alert(
            alertTitle,
            isPresented: Binding(
                get: { alertMessage != nil },
                set: { if !$0 { store.purchaseState = .idle } }
            )
        ) {
            Button("OK", role: .cancel) { store.purchaseState = .idle }
        } message: {
            Text(alertMessage ?? "")
        }
    }

    private func selectDefaultPlanIfNeeded() {
        guard selectedProductID == nil else { return }
        selectedProductID = (yearly ?? monthly)?.id
    }

    // MARK: - Sections

    private var closeButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.primary)
                .frame(width: 36, height: 36)
                .background(.thinMaterial, in: Circle())
        }
        .padding(.leading, 4)
        .padding(.top, 8)
    }

    private var header: some View {
        VStack(spacing: 10) {
            Text("Get more Demo")
                .font(.system(size: 32, weight: .regular, design: .serif))
            Text("Choose the plan that's right for you")
                .font(.title3)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 36)
        .multilineTextAlignment(.center)
    }

    private var planCard: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Pro")
                    .font(.system(size: 26, weight: .semibold, design: .serif))
                Text("For everyday productivity")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if store.products.isEmpty {
                if case .failed(let message) = store.productsState {
                    VStack(spacing: 12) {
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                        Button("Try Again") {
                            Task { await store.loadProducts() }
                        }
                        .buttonStyle(.bordered)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                } else {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 24)
                }
            } else {
                HStack(spacing: 12) {
                    if let monthly {
                        planOption(for: monthly, badge: nil)
                    }
                    if let yearly {
                        planOption(for: yearly, badge: yearlySavingsPercent.map { "Save \($0)%" })
                    }
                }

                purchaseButton
            }

            Divider()

            featureList
        }
        .padding(20)
        .background(.background, in: RoundedRectangle(cornerRadius: 24, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .strokeBorder(Color.primary.opacity(0.08))
        )
    }

    private func planOption(for product: Product, badge: String?) -> some View {
        let isSelected = selectedProductID == product.id

        return Button {
            selectedProductID = product.id
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    ZStack {
                        Circle()
                            .strokeBorder(isSelected ? Color.accentColor : Color.secondary.opacity(0.4), lineWidth: 1.5)
                        if isSelected {
                            Circle()
                                .fill(Color.accentColor)
                                .padding(4)
                        }
                    }
                    .frame(width: 22, height: 22)

                    Spacer()

                    if let badge {
                        Text(badge)
                            .font(.caption.weight(.semibold))
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                            .foregroundStyle(Color.accentColor)
                    }
                }

                Text(product.displayPrice)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(.primary)

                Text(product.id == StoreManager.monthlyID ? "Billed monthly" : "Billed annually")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                isSelected ? Color.accentColor.opacity(0.08) : Color(.secondarySystemGroupedBackground),
                in: RoundedRectangle(cornerRadius: 16, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .strokeBorder(isSelected ? Color.accentColor : Color.primary.opacity(0.08), lineWidth: isSelected ? 1.5 : 1)
            )
        }
        .buttonStyle(.plain)
    }

    private var purchaseButton: some View {
        Button {
            guard let selectedProduct else { return }
            Task { await store.purchase(selectedProduct) }
        } label: {
            HStack {
                if isPurchasing {
                    ProgressView().tint(.white)
                } else {
                    Text("Get Pro plan")
                        .font(.headline)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
        }
        .background(Color.black, in: Capsule())
        .foregroundStyle(.white)
        .disabled(selectedProduct == nil || isPurchasing)
    }

    private var featureList: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("Everything in Free, plus:")
                .font(.subheadline.weight(.semibold))
            ForEach(features, id: \.self) { feature in
                HStack(alignment: .top, spacing: 10) {
                    Image(systemName: "checkmark")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(feature)
                        .font(.subheadline)
                }
            }
        }
    }

    private var legalFooter: some View {
        VStack(spacing: 10) {
            Text("Payment is charged to your Apple ID at confirmation. Subscriptions renew automatically unless canceled at least 24 hours before the end of the current period. Manage or cancel anytime in Settings.")
                .font(.caption2)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            HStack(spacing: 16) {
                Link("Terms of Use", destination: URL(string: "https://example.com/terms")!)
                Link("Privacy Policy", destination: URL(string: "https://example.com/privacy")!)
                Button("Restore Purchases") {
                    Task { await store.restorePurchases() }
                }
                .disabled(store.isPurchasing(nil))
            }
            .font(.caption)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    PaywallView()
        .environmentObject(StoreManager())
}
