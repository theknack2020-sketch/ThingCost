import Foundation
import StoreKit
import Observation

@Observable
@MainActor
final class StoreService {
    static let shared = StoreService()

    private(set) var isUnlimited = false
    private(set) var product: Product?
    private(set) var purchaseState: PurchaseState = .idle

    private let productID = "com.ufukozdemir.thingcost.unlimited.v2"
    private let freeItemLimit = 3

    enum PurchaseState {
        case idle
        case purchasing
        case purchased
        case failed(String)
    }

    private init() {}

    // MARK: - Public API

    func canAddItem(currentCount: Int) -> Bool {
        isUnlimited || currentCount < freeItemLimit
    }

    var remainingFreeItems: Int {
        max(freeItemLimit - 0, 0) // Will be called with actual count
    }

    func remainingFreeSlots(currentCount: Int) -> Int {
        isUnlimited ? .max : max(freeItemLimit - currentCount, 0)
    }

    // MARK: - Load Products

    func loadProducts() async {
        do {
            let products = try await Product.products(for: [productID])
            product = products.first
        } catch {
            print("[StoreService] Failed to load products: \(error)")
        }
    }

    // MARK: - Purchase

    func purchase() async {
        guard let product else { return }

        purchaseState = .purchasing

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                isUnlimited = true
                purchaseState = .purchased
                await transaction.finish()
            case .userCancelled:
                purchaseState = .idle
            case .pending:
                purchaseState = .idle
            @unknown default:
                purchaseState = .idle
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }

    // MARK: - Restore

    func restore() async {
        do {
            try await AppStore.sync()
            await checkEntitlements()
        } catch {
            print("[StoreService] Restore failed: \(error)")
        }
    }

    // MARK: - Check Entitlements

    func checkEntitlements() async {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == productID {
                isUnlimited = true
                return
            }
        }
    }

    // MARK: - Transaction Updates

    func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result),
               transaction.productID == productID {
                isUnlimited = true
                await transaction.finish()
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let item):
            return item
        }
    }
}
