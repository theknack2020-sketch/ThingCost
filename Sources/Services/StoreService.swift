import Foundation
import Observation
import StoreKit

@Observable
@MainActor
final class StoreService {
    static let shared = StoreService()

    private(set) var isUnlimited = false
    private(set) var product: Product?
    private(set) var purchaseState: PurchaseState = .idle

    private let productID = "com.ufukozdemir.thingcost.unlimited.v2"
    private let freeItemLimit = 5

    /// Convenience alias — true when the user owns the lifetime unlock
    var isPro: Bool {
        isUnlimited
    }

    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case purchased
        case failed(String)
    }

    private init() {}

    // MARK: - Public API — Item Limit

    func canAddItem(currentCount: Int) -> Bool {
        isPro || currentCount < freeItemLimit
    }

    var remainingFreeItems: Int {
        max(freeItemLimit - 0, 0)
    }

    func remainingFreeSlots(currentCount: Int) -> Int {
        isPro ? .max : max(freeItemLimit - currentCount, 0)
    }

    // MARK: - Pro Feature Gates

    /// Share card styles: minimal is free, bold & gradient require Pro
    func isShareStyleAvailable(_ style: ShareCardStyle) -> Bool {
        if isPro { return true }
        return style == .minimal
    }

    /// Themes: system & light are free, everything else requires Pro
    func isThemeAvailable(_ theme: AppTheme) -> Bool {
        if isPro { return true }
        return !theme.isProOnly
    }

    /// CSV export requires Pro
    var canExportCSV: Bool {
        isPro
    }

    /// Cost projection milestones: free users see up to 6 months (180 days)
    func isMilestoneAvailable(days: Int) -> Bool {
        if isPro { return true }
        return days <= 180
    }

    /// Advanced charts require Pro
    var canAccessAdvancedCharts: Bool {
        isPro
    }

    /// Custom categories require Pro
    var canUseCustomCategories: Bool {
        isPro
    }

    /// Multiple currency support requires Pro
    var canUseMultipleCurrencies: Bool {
        isPro
    }

    /// Use logging requires Pro (free users see the score but can't log uses)
    var canLogUses: Bool {
        isPro
    }

    /// Photo attachment requires Pro
    var canAttachPhoto: Bool {
        isPro
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
            case let .success(verification):
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

    var showRestoreResult = false
    var restoreResultMessage = ""

    func restore() async {
        do {
            try await AppStore.sync()
            await checkEntitlements()
            if isUnlimited {
                restoreResultMessage = String(localized: "paywall_purchase_restored")
                Analytics.restoreCompleted(found: true)
            } else {
                restoreResultMessage = String(localized: "paywall_no_purchase_found")
                Analytics.restoreCompleted(found: false)
            }
            showRestoreResult = true
        } catch {
            restoreResultMessage = String(localized: "paywall_restore_failed")
            showRestoreResult = true
        }
    }

    // MARK: - Check Entitlements

    func checkEntitlements() async {
        var foundEntitlement = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? checkVerified(result),
               transaction.productID == productID,
               transaction.revocationDate == nil
            {
                foundEntitlement = true
            }
        }
        isUnlimited = foundEntitlement
    }

    // MARK: - Transaction Updates

    func listenForTransactions() async {
        for await result in Transaction.updates {
            if let transaction = try? checkVerified(result),
               transaction.productID == productID
            {
                if transaction.revocationDate == nil {
                    isUnlimited = true
                } else {
                    isUnlimited = false
                }
                await transaction.finish()
            }
        }
    }

    // MARK: - Helpers

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case let .unverified(_, error):
            throw error
        case let .verified(item):
            return item
        }
    }
}
