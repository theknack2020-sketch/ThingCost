import Foundation
import TelemetryDeck

@MainActor
enum Analytics {
    // MARK: - Setup

    static func configure() {
        let config = TelemetryDeck.Config(appID: Self.appID)
        TelemetryDeck.initialize(config: config)
    }

    // MARK: - Screen Views

    static func screenViewed(_ screen: Screen) {
        TelemetryDeck.signal("screen.viewed", parameters: ["screen": screen.rawValue])
    }

    // MARK: - Item Events

    static func itemAdded(category: String, daysOwned: Int) {
        TelemetryDeck.signal("item.added", parameters: [
            "category": category,
            "daysOwned": "\(daysOwned)",
        ])
    }

    static func itemDeleted() {
        TelemetryDeck.signal("item.deleted")
    }

    static func itemEdited() {
        TelemetryDeck.signal("item.edited")
    }

    // MARK: - Paywall Events

    static func paywallViewed(trigger: String) {
        TelemetryDeck.signal("paywall.viewed", parameters: ["trigger": trigger])
    }

    static func purchaseCompleted() {
        TelemetryDeck.signal("purchase.completed")
    }

    static func purchaseFailed(error: String) {
        TelemetryDeck.signal("purchase.failed", parameters: ["error": error])
    }

    static func restoreCompleted(found: Bool) {
        TelemetryDeck.signal("purchase.restore", parameters: ["found": "\(found)"])
    }

    // MARK: - Engagement Events

    static func streakRecorded(days: Int) {
        TelemetryDeck.signal("streak.recorded", parameters: ["days": "\(days)"])
    }

    static func achievementUnlocked(name: String) {
        TelemetryDeck.signal("achievement.unlocked", parameters: ["name": name])
    }

    static func shareCardCreated(style: String) {
        TelemetryDeck.signal("share.card", parameters: ["style": style])
    }

    static func csvExported() {
        TelemetryDeck.signal("export.csv")
    }

    static func useLogged(itemName: String) {
        TelemetryDeck.signal("item.useLogged", parameters: ["item": itemName])
    }

    // MARK: - Onboarding

    static func onboardingCompleted(addedSample: Bool) {
        TelemetryDeck.signal("onboarding.completed", parameters: ["addedSample": "\(addedSample)"])
    }

    static func notificationPermissionResult(granted: Bool) {
        TelemetryDeck.signal("notification.permission", parameters: ["granted": "\(granted)"])
    }

    // MARK: - Screens Enum

    enum Screen: String {
        case itemList = "ItemList"
        case itemDetail = "ItemDetail"
        case addItem = "AddItem"
        case editItem = "EditItem"
        case paywall = "Paywall"
        case settings = "Settings"
        case onboarding = "Onboarding"
        case shareCard = "ShareCard"
    }

    // MARK: - App ID (from environment or fallback)

    private static var appID: String {
        ProcessInfo.processInfo.environment["TELEMETRYDECK_APP_ID"]
            ?? "YOUR_TELEMETRYDECK_APP_ID"
    }
}
