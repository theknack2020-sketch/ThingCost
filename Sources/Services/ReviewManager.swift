import StoreKit
import SwiftUI

@MainActor
final class ReviewManager {
    static let shared = ReviewManager()

    private let itemsAddedKey = "reviewManager_itemsAdded"
    private let lastReviewVersionKey = "reviewManager_lastReviewVersion"
    private let appOpenCountKey = "reviewManager_appOpenCount"

    private init() {}

    // MARK: - Track Events

    func recordAppOpen() {
        let count = UserDefaults.standard.integer(forKey: appOpenCountKey) + 1
        UserDefaults.standard.set(count, forKey: appOpenCountKey)
    }

    func recordItemAdded() {
        let count = UserDefaults.standard.integer(forKey: itemsAddedKey) + 1
        UserDefaults.standard.set(count, forKey: itemsAddedKey)
    }

    // MARK: - Should Request

    /// Ask for review after a positive moment:
    /// - At least 3 items added (user invested time)
    /// - At least 5 app opens (not brand new)
    /// - Haven't asked for this app version yet
    var shouldRequestReview: Bool {
        let itemsAdded = UserDefaults.standard.integer(forKey: itemsAddedKey)
        let appOpens = UserDefaults.standard.integer(forKey: appOpenCountKey)
        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let lastReviewVersion = UserDefaults.standard.string(forKey: lastReviewVersionKey)

        guard itemsAdded >= 3, appOpens >= 5 else { return false }
        guard lastReviewVersion != currentVersion else { return false }
        return true
    }

    /// Request review through the system prompt.
    /// Call after a positive action (item added, achievement unlocked, share completed).
    func requestReviewIfAppropriate() {
        guard shouldRequestReview else { return }

        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        UserDefaults.standard.set(currentVersion, forKey: lastReviewVersionKey)

        // Slight delay so the positive action's UI settles first
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            guard let scene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive })
            else { return }
            AppStore.requestReview(in: scene)
        }
    }
}
