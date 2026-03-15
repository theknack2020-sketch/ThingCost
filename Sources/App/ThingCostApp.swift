import SwiftUI
import SwiftData

@main
struct ThingCostApp: App {
    @State private var store = StoreService.shared

    init() {
        if CommandLine.arguments.contains("--reset-onboarding") {
            UserDefaults.standard.removeObject(forKey: "hasCompletedOnboarding")
        }
        if CommandLine.arguments.contains("--reset-data") {
            // Delete SwiftData store
            let url = URL.applicationSupportDirectory.appending(path: "default.store")
            try? FileManager.default.removeItem(at: url)
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(store)
                .task {
                    await store.loadProducts()
                    await store.checkEntitlements()
                }
                .task {
                    await store.listenForTransactions()
                }
        }
        .modelContainer(for: Item.self)
    }
}
