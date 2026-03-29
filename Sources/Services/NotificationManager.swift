@preconcurrency import UserNotifications

@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
        } catch {
            return false
        }
    }

    func isAuthorized() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }

    func scheduleDailyReminder(hour: Int = 20, minute: Int = 0) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_daily_title")
        content.body = String(localized: "notification_daily_body")
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelDailyReminder() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["dailyReminder"])
    }

    func scheduleStreakAtRisk() {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_streak_title")
        content.body = String(localized: "notification_streak_body \(StreakManager.shared.currentStreak)")
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 86400, repeats: false)
        let request = UNNotificationRequest(identifier: "streakAtRisk", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
    }

    func cancelStreakAtRisk() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["streakAtRisk"])
    }

    func scheduleCostMilestone(itemName: String, milestone: String, cost: String) {
        let content = UNMutableNotificationContent()
        content.title = String(localized: "notification_milestone_title \(itemName)")
        content.body = String(localized: "notification_milestone_body \(milestone) \(cost)")
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(
            identifier: "milestone_\(itemName)_\(milestone)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    // MARK: - Warranty Expiration Notifications

    /// Schedule a notification 7 days before warranty expires for each item.
    /// Cancels all previous warranty notifications before scheduling new ones.
    func scheduleWarrantyReminders(for items: [Item]) {
        let center = UNUserNotificationCenter.current()

        Task {
            let requests = await center.pendingNotificationRequests()
            let warrantyIDs = requests
                .filter { $0.identifier.hasPrefix("warranty_") }
                .map(\.identifier)
            center.removePendingNotificationRequests(withIdentifiers: warrantyIDs)

            for item in items {
                guard let expirationDate = item.warrantyExpirationDate,
                      item.isWarrantyActive,
                      let reminderDate = Calendar.current.date(byAdding: .day, value: -7, to: expirationDate),
                      reminderDate > Date()
                else { continue }

                let content = UNMutableNotificationContent()
                content.title = "Warranty Expiring Soon"
                content.body = "\(item.name) warranty expires in 7 days. Check if you need to make a claim."
                content.sound = .default

                let components = Calendar.current.dateComponents(
                    [.year, .month, .day, .hour, .minute],
                    from: reminderDate
                )
                let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
                let identifier = "warranty_\(item.persistentModelID.hashValue)"
                let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

                try? await center.add(request)
            }
        }
    }
}
