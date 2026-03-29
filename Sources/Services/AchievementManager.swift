import SwiftUI

enum Achievement: String, CaseIterable, Identifiable {
    case firstItem = "First Purchase"
    case fiveItems = "Collector"
    case tenItems = "Hoarder"
    case weekStreak = "Week Warrior"
    case monthStreak = "Monthly Master"
    case sharedCard = "Social Butterfly"
    case cheapestDay = "Penny Pincher"
    case allCategories = "Diversified"

    var id: String {
        rawValue
    }

    var description: String {
        switch self {
        case .firstItem: "Added your first item"
        case .fiveItems: "Tracked 5 items"
        case .tenItems: "Tracked 10 items"
        case .weekStreak: "7-day streak"
        case .monthStreak: "30-day streak"
        case .sharedCard: "Shared a cost card"
        case .cheapestDay: "Found your cheapest daily cost"
        case .allCategories: "Used all 8 categories"
        }
    }

    var icon: String {
        switch self {
        case .firstItem: "star.fill"
        case .fiveItems: "star.circle.fill"
        case .tenItems: "crown.fill"
        case .weekStreak: "flame.fill"
        case .monthStreak: "bolt.shield.fill"
        case .sharedCard: "paperplane.fill"
        case .cheapestDay: "dollarsign.circle.fill"
        case .allCategories: "square.grid.3x3.fill"
        }
    }

    var threshold: String {
        switch self {
        case .firstItem: "1 item"
        case .fiveItems: "5 items"
        case .tenItems: "10 items"
        case .weekStreak: "7 days"
        case .monthStreak: "30 days"
        case .sharedCard: "1 share"
        case .cheapestDay: "< $1/day"
        case .allCategories: "8 categories"
        }
    }

    var color: Color {
        switch self {
        case .firstItem: .yellow
        case .fiveItems: .blue
        case .tenItems: .purple
        case .weekStreak: .orange
        case .monthStreak: .red
        case .sharedCard: .green
        case .cheapestDay: .mint
        case .allCategories: .indigo
        }
    }
}

@MainActor
@Observable
final class AchievementManager {
    static let shared = AchievementManager()

    @ObservationIgnored
    @AppStorage("unlockedAchievements") private var unlockedData = ""

    @ObservationIgnored
    @AppStorage("hasSharedCard") private(set) var hasSharedCard = false

    private init() {}

    var unlockedAchievements: Set<String> {
        Set(unlockedData.split(separator: ",").map(String.init))
    }

    func isUnlocked(_ achievement: Achievement) -> Bool {
        unlockedAchievements.contains(achievement.rawValue)
    }

    var unlockedCount: Int {
        unlockedAchievements.count(where: { !$0.isEmpty })
    }

    func markShared() {
        hasSharedCard = true
    }

    func checkAndUnlock(itemCount: Int, streak: Int, categoryCount: Int) -> Achievement? {
        let checks: [(Achievement, Bool)] = [
            (.firstItem, itemCount >= 1),
            (.fiveItems, itemCount >= 5),
            (.tenItems, itemCount >= 10),
            (.weekStreak, streak >= 7),
            (.monthStreak, streak >= 30),
            (.sharedCard, hasSharedCard),
            (.allCategories, categoryCount >= ItemCategory.allCases.count),
        ]

        for (achievement, condition) in checks {
            if condition, !isUnlocked(achievement) {
                unlock(achievement)
                return achievement
            }
        }
        return nil
    }

    private func unlock(_ achievement: Achievement) {
        var current = unlockedAchievements
        current.insert(achievement.rawValue)
        unlockedData = current.joined(separator: ",")
        HapticManager.shared.celebrate()
    }
}
