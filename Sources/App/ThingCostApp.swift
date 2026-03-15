import SwiftUI
import SwiftData

@main
struct ThingCostApp: App {
    @State private var store = StoreService.shared

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
