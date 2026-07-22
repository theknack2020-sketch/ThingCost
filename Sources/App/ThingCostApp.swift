import SwiftData
import SwiftUI
import TipKit

@main
struct ThingCostApp: App {
    @State private var store = StoreService.shared
    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue
    private let modelContainer: ModelContainer

    init() {
        #if DEBUG
            let tipsEnabled = !ScreenshotTour.isActive
        #else
            let tipsEnabled = true
        #endif
        if tipsEnabled {
            try? Tips.configure([
                .datastoreLocation(.applicationDefault),
            ])
        }
        if CommandLine.arguments.contains("--reset-onboarding") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        }
        if CommandLine.arguments.contains("--reset-data") {
            Self.wipeStore()
        }
        if CommandLine.arguments.contains("--skip-onboarding") {
            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        }
        modelContainer = Self.makeContainer()
        DemoData.seedIfRequested(into: modelContainer)
    }

    private static func makeContainer() -> ModelContainer {
        do {
            return try ModelContainer(for: Item.self)
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    /// Removes the store and its sidecars so `--reset-data` runs start truly
    /// empty (UI tests + screenshot pipeline depend on this).
    private static func wipeStore() {
        let fm = FileManager.default
        for name in [".default_SUPPORT", "default.store-wal", "default.store-shm", "default.store"] {
            try? fm.removeItem(at: URL.applicationSupportDirectory.appending(path: name))
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
        .modelContainer(modelContainer)
    }
}
