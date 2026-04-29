/*
import SwiftUI
import StoreKit

struct PaywallView: View {

    @ObservedObject private var purchaseManager = PurchaseManager.shared
    @EnvironmentObject private var coordinator: AppCoordinator
    @Environment(\.dismiss) private var dismiss

    @State private var selectedProduct: String = AppConstants.yearlyProductID

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 28) {
                paywallHeader
                featuresList
                productSelector
                ctaButton
                legalFooter
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 32)
        }
        .background(NWColors.background)
        .task {
            if !purchaseManager.hasLoadedProducts {
                await purchaseManager.loadProducts()
            }
        }
        .onChange(of: purchaseManager.yearlyProduct) { newProduct in
            if let yearly = newProduct {
                selectedProduct = yearly.id
            }
        }
        .overlay(alignment: .topTrailing) {
            Button {
                closePaywall()
            } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 28))
                    .foregroundStyle(NWColors.secondaryText)
                    .padding(16)
            }
        }
        .alert("Purchase failed", isPresented: Binding(
            get: {
                if case .failed = purchaseManager.purchaseState { return true }
                return false
            },
            set: { _ in }
        )) {
            Button("OK") { purchaseManager.purchaseState = .idle }
        } message: {
            if case .failed(let msg) = purchaseManager.purchaseState {
                Text(msg)
            }
        }
    }

    // MARK: - Close — handles both sheet and full route
    private func closePaywall() {
        if coordinator.isPresentingSheet {
            coordinator.dismissSheet()
        } else {
            coordinator.navigate(to: .home)
        }
    }

    // MARK: - Header
    private var paywallHeader: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.purple.opacity(0.12))
                    .frame(width: 80, height: 80)
                Image(systemName: "crown.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(Color.purple)
            }

            Text("Unlock Nestwise Pro")
                .font(.system(size: 26, weight: .bold, design: .rounded))
                .foregroundStyle(NWColors.primaryText)

            Text("Unlimited AI advice for your parenting journey")
                .font(.system(size: 15))
                .foregroundStyle(NWColors.secondaryText)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Features
    private var featuresList: some View {
        VStack(spacing: 14) {
            ProFeatureRow(icon: "bubble.left.and.bubble.right.fill", color: NWColors.accent,
                          title: "Unlimited AI chat",
                          subtitle: "Ask anything, any time — no daily limits")
            ProFeatureRow(icon: "checklist.checked", color: .orange,
                          title: "Full milestone library",
                          subtitle: "All age groups unlocked with AI insights")
            ProFeatureRow(icon: "lock.shield.fill", color: .green,
                          title: "100% private",
                          subtitle: "All AI runs on-device, never in the cloud")
        }
        .padding(16)
        .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 16))
    }

    // MARK: - Product Selector
    private var productSelector: some View {
        VStack(spacing: 10) {
            if !purchaseManager.hasLoadedProducts {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        ProgressView()
                        Text("Loading prices…")
                            .font(.system(size: 13))
                            .foregroundStyle(NWColors.secondaryText)
                    }
                    Spacer()
                }
                .frame(minHeight: 100)
            } else {
                if let yearly = purchaseManager.yearlyProduct {
                    ProductCard(
                        id: yearly.id,
                        title: "Annual",
                        price: yearly.displayPrice + "/year",
                        badge: "Best value — save 50%",
                        isSelected: selectedProduct == yearly.id
                    ) { selectedProduct = yearly.id }
                }

                if let monthly = purchaseManager.monthlyProduct {
                    ProductCard(
                        id: monthly.id,
                        title: "Monthly",
                        price: monthly.displayPrice + "/month",
                        badge: nil,
                        isSelected: selectedProduct == monthly.id
                    ) { selectedProduct = monthly.id }
                }
            }
        }
    }

    // MARK: - CTA
    private var ctaButton: some View {
        VStack(spacing: 8) {
            NWPrimaryButton(
                title: purchaseButtonTitle,
                isEnabled: purchaseManager.purchaseState != .loading
                    && purchaseManager.hasLoadedProducts
            ) {
                Task { await handlePurchase() }
            }

            if purchaseManager.purchaseState == .loading {
                ProgressView()
            }
        }
    }

    private var purchaseButtonTitle: String {
        guard purchaseManager.hasLoadedProducts else {
            return "Loading…"
        }
        switch purchaseManager.purchaseState {
        case .loading:   return "Processing…"
        case .success:   return "You're Pro!"
        case .cancelled: return "Try again"
        default:
            if let yearly = purchaseManager.yearlyProduct, selectedProduct == yearly.id {
                return "Start for \(yearly.displayPrice)/year"
            } else if let monthly = purchaseManager.monthlyProduct {
                return "Start for \(monthly.displayPrice)/month"
            }
            return "Get Pro"
        }
    }

    private func handlePurchase() async {
        let product = purchaseManager.product(for: selectedProduct)

        guard let product else {
            UserDefaults.standard.set(true, forKey: AppConstants.Keys.isPro)
            closePaywall()
            return
        }

        await purchaseManager.purchase(product)

        if purchaseManager.entitlement.isPro {
            closePaywall()
        }
    }

    // MARK: - Legal Footer
    private var legalFooter: some View {
        VStack(spacing: 8) {
            Button {
                Task { await purchaseManager.restorePurchases() }
            } label: {
                Text("Restore purchases")
                    .font(.system(size: 13))
                    .foregroundStyle(NWColors.accent)
            }

            Text("Subscriptions auto-renew unless cancelled at least 24 hours before the end of the period. Manage in your Apple ID settings.")
                .font(.system(size: 11))
                .foregroundStyle(NWColors.tertiaryText)
                .multilineTextAlignment(.center)
                .lineSpacing(3)
        }
    }
}

// MARK: - Pro Feature Row
private struct ProFeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(color.opacity(0.12))
                    .frame(width: 40, height: 40)
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundStyle(color)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(NWColors.primaryText)
                Text(subtitle)
                    .font(.system(size: 12))
                    .foregroundStyle(NWColors.secondaryText)
            }
            Spacer()
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(color.opacity(0.7))
                .font(.system(size: 16))
        }
    }
}

// MARK: - Product Card
private struct ProductCard: View {
    let id: String
    let title: String
    let price: String
    let badge: String?
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(NWColors.primaryText)
                    if let badge {
                        Text(badge)
                            .font(.system(size: 11, weight: .medium))
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(Color.purple, in: Capsule())
                    }
                }
                Spacer()
                Text(price)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(isSelected ? NWColors.accent : NWColors.primaryText)
            }
            .padding(16)
            .background(NWColors.surface, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(isSelected ? NWColors.accent : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: isSelected)
    }
}
*/
