import Foundation
import SwiftData
import Testing
@testable import ThingCost

/// Covers the App Group shared store plumbing that feeds both the app and the
/// widget: container creation, a cross-context write/read roundtrip (the widget
/// reads via its own `ModelContext`), and migration idempotency.
@Suite("SharedStore", .serialized)
@MainActor
struct SharedStoreTests {
    @Test("Group container URL is available with the App Group entitlement")
    func groupContainerAvailable() {
        #expect(SharedStore.groupContainerURL != nil)
        #expect(SharedStore.groupStoreURL?.lastPathComponent == "default.store")
    }

    @Test("Write in one context is readable from a fresh context (widget path)")
    func crossContextRoundtrip() throws {
        SharedStore.wipeAllStores()
        let container = SharedStore.makeContainer()

        let writeContext = ModelContext(container)
        let item = Item(name: "Test Phone", price: 999, purchaseDate: .now)
        writeContext.insert(item)
        try writeContext.save()

        // The widget opens its own ModelContext against the same store.
        let readContext = ModelContext(container)
        let count = try readContext.fetchCount(FetchDescriptor<Item>())
        #expect(count == 1)

        SharedStore.wipeAllStores()
    }

    @Test("Migration is a no-op without a legacy store and is idempotent")
    func migrationIdempotent() {
        SharedStore.wipeAllStores()
        // No legacy store → nothing to migrate, no crash, no group store created.
        SharedStore.migrateLegacyStoreIfNeeded()
        if let groupURL = SharedStore.groupStoreURL {
            #expect(!FileManager.default.fileExists(atPath: groupURL.path))
        }
        // Calling again is safe.
        SharedStore.migrateLegacyStoreIfNeeded()
    }

    @Test("Legacy store migrates into the group container once")
    func legacyStoreMigrates() throws {
        SharedStore.wipeAllStores()

        // Build a real store at the legacy location, as v1.x did.
        let legacyConfig = ModelConfiguration(url: SharedStore.legacyStoreURL)
        let legacyContainer = try ModelContainer(for: Item.self, configurations: legacyConfig)
        let legacyContext = ModelContext(legacyContainer)
        legacyContext.insert(Item(name: "Legacy Laptop", price: 1200, purchaseDate: .now))
        try legacyContext.save()

        SharedStore.migrateLegacyStoreIfNeeded()

        let groupURL = try #require(SharedStore.groupStoreURL)
        #expect(FileManager.default.fileExists(atPath: groupURL.path))

        // The migrated store contains the legacy data.
        let container = SharedStore.makeContainer()
        let count = try ModelContext(container).fetchCount(FetchDescriptor<Item>())
        #expect(count == 1)

        // Legacy files are retained as a safety net this release.
        #expect(FileManager.default.fileExists(atPath: SharedStore.legacyStoreURL.path))

        SharedStore.wipeAllStores()
    }
}
