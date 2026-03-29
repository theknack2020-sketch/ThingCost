import Foundation
import Observation
import SwiftUI

@MainActor
@Observable
final class PaywallTrigger {
    static let shared = PaywallTrigger()

    @ObservationIgnored
    @AppStorage("totalItemsAdded") private var totalItemsAdded = 0

    @ObservationIgnored
    @AppStorage("lastPaywallShown") private var lastPaywallShownTimestamp: Double = 0

    private init() {}

    /// Call after a new item is saved
    func recordItemAdded() {
        totalItemsAdded += 1
    }

    /// Returns true if a soft paywall should be presented
    func shouldShowSoftPaywall(isPro: Bool) -> Bool {
        guard !isPro else { return false }
        // After 5th item added
        guard totalItemsAdded >= 5 else { return false }
        // Throttle: at most once per 24 hours
        let now = Date().timeIntervalSince1970
        guard now - lastPaywallShownTimestamp > 86400 else { return false }
        return true
    }

    /// Record that the paywall was shown (resets the 24h cooldown)
    func recordPaywallShown() {
        lastPaywallShownTimestamp = Date().timeIntervalSince1970
    }
}
