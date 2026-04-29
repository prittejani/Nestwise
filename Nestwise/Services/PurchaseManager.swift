//
//  PurchaseManager.swift
//  Netwise
//
//  Created by Prit  on 12/04/26.
//


import Foundation
import StoreKit
import Combine

@MainActor
final class PurchaseManager: ObservableObject {

    // MARK: - Shared Instance
    static let shared = PurchaseManager()

    // MARK: - Published State
    @Published var monthlyProduct: Product?
    @Published var yearlyProduct: Product?
    @Published var purchaseState: PurchaseState = .idle
    @Published var entitlement: Entitlement = .pro(expiryDate: nil) // Default to Pro

    // MARK: - Types
    enum PurchaseState: Equatable {
        case idle
        case loading
        case success
        case failed(String)
        case cancelled
    }

    enum Entitlement: Equatable {
        case free
        case pro(expiryDate: Date?)

        var isPro: Bool {
            if case .pro = self { return true }
            return false
        }

        var expiryDate: Date? {
            if case .pro(let date) = self { return date }
            return nil
        }
    }

    // MARK: - Private
    private var transactionListenerTask: Task<Void, Never>?
    private let productIDs: Set<String> = []
    /*
    private let productIDs: Set<String> = [
        AppConstants.monthlyProductID,
        AppConstants.yearlyProductID
    ]
    */

    // MARK: - Init
    private init() {
        /*
        transactionListenerTask = listenForTransactions()
        Task {
            await loadProducts()
            await refreshEntitlement()
        }
        */
    }

    deinit {
        transactionListenerTask?.cancel()
    }

    // MARK: - Load Products
    func loadProducts() async {
        /*
        do {
            let storeProducts = try await Product.products(for: productIDs)
            for product in storeProducts {
                if product.id == AppConstants.monthlyProductID {
                    monthlyProduct = product
                } else if product.id == AppConstants.yearlyProductID {
                    yearlyProduct = product
                }
            }
        } catch {
            print("PurchaseManager: Failed to load products — \(error.localizedDescription)")
        }
        */
    }

    // MARK: - Purchase
    func purchase(_ product: Product) async {
        /*
        purchaseState = .loading

        do {
            let result = try await product.purchase()

            switch result {
            case .success(let verification):
                let transaction = try verify(verification)
                await transaction.finish()
                await refreshEntitlement()
                purchaseState = .success

            case .userCancelled:
                purchaseState = .cancelled

            case .pending:
                // Waiting for parental approval etc.
                purchaseState = .idle

            @unknown default:
                purchaseState = .idle
            }

        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
        */
    }

    // MARK: - Purchase by ID (convenience)
    func purchaseByID(_ productID: String) async {
        /*
        guard let product = product(for: productID) else {
            purchaseState = .failed("Product not found. Check your connection and try again.")
            return
        }
        await purchase(product)
        */
    }

    // MARK: - Restore
    func restorePurchases() async {
        /*
        purchaseState = .loading
        do {
            try await AppStore.sync()
            await refreshEntitlement()
            purchaseState = entitlement.isPro ? .success : .idle
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
        */
    }

    // MARK: - Refresh Entitlement
    func refreshEntitlement() async {
        /*
        var foundValidSubscription = false
        var latestExpiry: Date? = nil

        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else { continue }
            guard productIDs.contains(transaction.productID) else { continue }

            // Check not revoked
            if transaction.revocationDate != nil { continue }

            // Check not expired
            if let expiry = transaction.expirationDate, expiry < Date() { continue }

            foundValidSubscription = true
            latestExpiry = transaction.expirationDate
        }

        if foundValidSubscription {
            entitlement = .pro(expiryDate: latestExpiry)
            persist(isPro: true)
        } else {
            entitlement = .free
            persist(isPro: false)
        }
        */
    }

    // MARK: - Transaction Listener
    private func listenForTransactions() -> Task<Void, Never> {
        Task(priority: .background) { 
            // Loop removed
        }
    }

    // MARK: - Helpers
    func product(for id: String) -> Product? {
        /*
        if id == AppConstants.monthlyProductID { return monthlyProduct }
        if id == AppConstants.yearlyProductID  { return yearlyProduct  }
        */
        return nil
    }

    var hasLoadedProducts: Bool {
        monthlyProduct != nil || yearlyProduct != nil
    }

    var remainingFreeMessages: Int {
        MessageLimitService.shared.remainingMessages
    }

    var canSendMessage: Bool {
        true // Always true now
    }

    private func verify<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let value):
            return value
        }
    }

    private func persist(isPro: Bool) {
        UserDefaults.standard.set(isPro, forKey: AppConstants.Keys.isPro)
    }
}
