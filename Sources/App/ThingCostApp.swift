import SwiftData
import SwiftUI
import TipKit
import WidgetKit

@main
struct ThingCostApp: App {
    @State private var store = StoreService.shared
    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue
    @Environment(\.scenePhase) private var scenePhase
    private let modelContainer: ModelContainer

    init() {
        try? Tips.configure([
            .datastoreLocation(.applicationDefault),
        ])
        if CommandLine.arguments.contains("--reset-onboarding") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        }
        if CommandLine.arguments.contains("--reset-data") {
            SharedStore.wipeAllStores()
        }
        if CommandLine.arguments.contains("--skip-onboarding") {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
        SharedStore.migrateLegacyStoreIfNeeded()
        modelContainer = SharedStore.makeContainer()
        DemoData.seedIfRequested(into: modelContainer)
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
                .onChange(of: scenePhase) { _, newPhase in
                    if newPhase == .background {
                        WidgetCenter.shared.reloadAllTimelines()
                    }
                }
        }
        .modelContainer(modelContainer)
    }
}
