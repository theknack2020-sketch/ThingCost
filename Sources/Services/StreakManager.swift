import SwiftUI

@MainActor
@Observable
final class StreakManager {
    static let shared = StreakManager()

    @ObservationIgnored
    @AppStorage("currentStreak") private(set) var currentStreak = 0
    @ObservationIgnored
    @AppStorage("longestStreak") private(set) var longestStreak = 0
    @ObservationIgnored
    @AppStorage("lastActiveDate") private var lastActiveDateString = ""
    @ObservationIgnored
    @AppStorage("totalDaysActive") private(set) var totalDaysActive = 0

    private init() {}

    func recordActivity() {
        let today = Calendar.current.startOfDay(for: Date())
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        let todayStr = formatter.string(from: today)

        guard todayStr != lastActiveDateString else { return } // Already recorded today

        if let lastDate = formatter.date(from: lastActiveDateString) {
            let daysSinceLast = Calendar.current.dateComponents([.day], from: lastDate, to: today).day ?? 0
            if daysSinceLast == 1 {
                currentStreak += 1
            } else if daysSinceLast > 1 {
                currentStreak = 1 // Reset
            }
        } else {
            currentStreak = 1 // First day
        }

        totalDaysActive += 1
        if currentStreak > longestStreak { longestStreak = currentStreak }
        lastActiveDateString = todayStr
    }

    var isActiveToday: Bool {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withFullDate]
        return lastActiveDateString == formatter.string(from: Calendar.current.startOfDay(for: Date()))
    }

    var streakEmoji: String {
        switch currentStreak {
        case 0: "🌱"
        case 1 ... 2: "🔥"
        case 3 ... 6: "🔥🔥"
        case 7 ... 13: "⚡️"
        case 14 ... 29: "🌟"
        default: "💎"
        }
    }

    var streakTitle: String {
        switch currentStreak {
        case 0: "Start Your Streak"
        case 1 ... 2: "Getting Started"
        case 3 ... 6: "Building Momentum"
        case 7 ... 13: "On Fire!"
        case 14 ... 29: "Unstoppable"
        default: "Legendary"
        }
    }
}
