import SwiftData
import SwiftUI
import TelemetryDeck
import TipKit

@main
struct ThingCostApp: App {
    @State private var store = StoreService.shared
    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue

    init() {
        Analytics.configure()
        try? Tips.configure([
            .datastoreLocation(.applicationDefault),
        ])
        if CommandLine.arguments.contains("--reset-onboarding") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        }
        if CommandLine.arguments.contains("--reset-data") {
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: url)
        }
        if CommandLine.arguments.contains("--skip-onboarding") {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
    }

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .system
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .preferredColorScheme(selectedTheme.colorScheme)
                .task {
                    await store.loadProducts()
                    await store.checkEntitlements()
                }
                .task {
                    await store.listenForTransactions()
                }
                .onAppear {
                    StreakManager.shared.recordActivity()
                    ReviewManager.shared.recordAppOpen()
                    if UserDefaults.standard.bool(forKey: "streakAlertsEnabled") {
                        NotificationManager.shared.scheduleStreakAtRisk()
                    }
                }
        }
        .modelContainer(for: Item.self)
    }
}
