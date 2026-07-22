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
            // Recovery: a corrupt store (e.g. a partial WAL after the process was
            // killed mid-save) would otherwise crash the app on every launch.
            // Move the store + sidecars aside and retry once with a fresh store
            // so the app opens instead of bricking.
            moveCorruptStoreAside()
            do {
                return try ModelContainer(for: Item.self)
            } catch {
                // Last resort: an in-memory store keeps the app usable for this
                // session rather than a hard crash on launch.
                do {
                    let config = ModelConfiguration(isStoredInMemoryOnly: true)
                    return try ModelContainer(for: Item.self, configurations: config)
                } catch {
                    fatalError("Failed to create any ModelContainer: \(error)")
                }
            }
        }
    }

    /// Renames the on-disk store and its sidecars to a `.corrupt-<timestamp>`
    /// suffix so a fresh store can be created without deleting the user's data
    /// outright (the backup copy can still be inspected/recovered).
    private static func moveCorruptStoreAside() {
        let fm = FileManager.default
        let stamp = Int(Date().timeIntervalSince1970)
        for name in [".default_SUPPORT", "default.store-wal", "default.store-shm", "default.store"] {
            let url = URL.applicationSupportDirectory.appending(path: name)
            guard fm.fileExists(atPath: url.path) else { continue }
            let backup = URL.applicationSupportDirectory.appending(path: "\(name).corrupt-\(stamp)")
            try? fm.moveItem(at: url, to: backup)
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
                    #if DEBUG
                        if ScreenshotTour.proUnlocked {
                            store.debugForceUnlimited()
                        }
                    #endif
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
