import Observation
import StoreKit
import SwiftUI

/// Asks for an App Store review only after a genuinely positive moment, and only
/// once the person has clearly invested in ThingCost. The ask is honest and
/// two-step: an in-app "Enjoying ThingCost?" card first — a happy tap opens
/// Apple's native rating prompt, an unhappy tap opens private feedback so a
/// gripe reaches us instead of a public one-star. Never a fake star UI that
/// secretly filters reviews.
@Observable @MainActor
final class ReviewManager {
    static let shared = ReviewManager()

    private let itemsAddedKey = "reviewManager_itemsAdded"
    private let lastReviewVersionKey = "reviewManager_lastReviewVersion"
    private let appOpenCountKey = "reviewManager_appOpenCount"

    /// Private feedback channel for the "could be better" path.
    private static let feedbackMailto =
        "mailto:support@theknack.dev?subject=ThingCost%20Feedback"

    /// Drives the honest in-app pre-prompt card. Set at a peak moment; a happy
    /// tap fires Apple's native prompt, an unhappy tap opens private feedback.
    var pendingPrePrompt = false

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
        let lastReviewVersion = UserDefaults.standard.string(forKey: lastReviewVersionKey)

        guard itemsAdded >= 3, appOpens >= 5 else { return false }
        guard lastReviewVersion != Self.currentVersion else { return false }
        return true
    }

    /// Surface the honest pre-prompt card if the timing gate allows.
    /// Call after a positive action (item added, achievement unlocked, share
    /// completed) — never after an error or friction.
    func requestReviewIfAppropriate() {
        guard shouldRequestReview else { return }

        // Record the ask now so the once-per-version cap applies to the
        // pre-prompt itself; the native prompt only fires on "I love it".
        UserDefaults.standard.set(Self.currentVersion, forKey: lastReviewVersionKey)

        // Slight delay so the positive action's UI settles first
        Task { @MainActor in
            try? await Task.sleep(for: .seconds(1.5))
            pendingPrePrompt = true
        }
    }

    // MARK: - Pre-prompt outcomes

    /// "I love it" — open Apple's native rating prompt (iOS caps it at 3/365).
    func lovedIt() {
        pendingPrePrompt = false
        guard let scene = activeWindowScene else { return }
        AppStore.requestReview(in: scene)
    }

    /// "Could be better" — route to private feedback so the gripe reaches us,
    /// not a public one-star.
    func notForMe() {
        pendingPrePrompt = false
        if let url = URL(string: Self.feedbackMailto) {
            UIApplication.shared.open(url)
        }
    }

    // MARK: - Helpers

    private static var currentVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }

    private var activeWindowScene: UIWindowScene? {
        let scenes = UIApplication.shared.connectedScenes
        return scenes.first { $0.activationState == .foregroundActive } as? UIWindowScene
            ?? scenes.first { $0 is UIWindowScene } as? UIWindowScene
    }
}
