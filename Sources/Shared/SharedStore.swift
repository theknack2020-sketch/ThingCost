import Foundation
import SwiftData

/// Shared SwiftData store in the App Group container, used by both the app and the widget.
enum SharedStore {
    static let appGroupID = "group.com.ufukozdemir.thingcost"
    static let storeName = "default.store"

    /// Store file names including SQLite sidecars and the hidden support directory
    /// where Core Data keeps `.externalStorage` blobs (photos, receipts).
    /// Order matters for migration: the main store is copied LAST so its existence
    /// doubles as the "migration finished" sentinel.
    private static let storeFileNames = [
        ".default_SUPPORT",
        "default.store-wal",
        "default.store-shm",
        "default.store",
    ]

    static var groupContainerURL: URL? {
        FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupID)
    }

    static var groupStoreURL: URL? {
        groupContainerURL?.appending(path: storeName)
    }

    /// Legacy pre-App-Group store location, created by `.modelContainer(for:)` in v1.x.
    static var legacyStoreURL: URL {
        URL.applicationSupportDirectory.appending(path: storeName)
    }

    /// Builds the shared container. Prefers the App Group store; if the group store
    /// does not exist yet but a legacy store does (a failed/pending migration in the
    /// app process), falls back to the legacy store so users never see an empty app.
    /// In the widget process the legacy path never exists, so it always opens the
    /// group store (empty until the app has launched once post-update).
    static func makeContainer() -> ModelContainer {
        let fm = FileManager.default
        if let groupURL = groupStoreURL {
            let groupStoreExists = fm.fileExists(atPath: groupURL.path)
            let legacyStoreExists = fm.fileExists(atPath: legacyStoreURL.path)
            if groupStoreExists || !legacyStoreExists {
                do {
                    let config = ModelConfiguration(url: groupURL)
                    return try ModelContainer(for: Item.self, configurations: config)
                } catch {
                    // Fall through to the legacy/default container below.
                }
            }
        }
        do {
            return try ModelContainer(for: Item.self)
        } catch {
            fatalError("Failed to create any ModelContainer: \(error)")
        }
    }

    /// One-time copy of the legacy store into the App Group container.
    /// Must run before any ModelContainer is created in this process so no SQLite
    /// connection is open on either side of the copy. Idempotent: no-ops once the
    /// group store exists. App target only — the widget cannot read the app's
    /// Application Support directory.
    ///
    /// The legacy files are intentionally left in place this release as a safety
    /// net; a future release can delete them once migration has proven itself.
    static func migrateLegacyStoreIfNeeded() {
        let fm = FileManager.default
        guard let groupURL = groupContainerURL else { return }
        let destStore = groupURL.appending(path: storeName)
        guard !fm.fileExists(atPath: destStore.path) else { return }
        guard fm.fileExists(atPath: legacyStoreURL.path) else { return }

        do {
            for name in storeFileNames {
                let src = URL.applicationSupportDirectory.appending(path: name)
                let dst = groupURL.appending(path: name)
                guard fm.fileExists(atPath: src.path) else { continue }
                if fm.fileExists(atPath: dst.path) {
                    try fm.removeItem(at: dst)
                }
                try fm.copyItem(at: src, to: dst)
            }
        } catch {
            // Roll back the partial copy so the sentinel stays false and the
            // next launch retries; makeContainer() falls back to the legacy store.
            for name in storeFileNames {
                try? fm.removeItem(at: groupURL.appending(path: name))
            }
        }
    }

    /// Removes every store file from both locations. Used by the `--reset-data`
    /// UI-test launch argument.
    static func wipeAllStores() {
        let fm = FileManager.default
        for name in storeFileNames {
            try? fm.removeItem(at: URL.applicationSupportDirectory.appending(path: name))
            if let groupURL = groupContainerURL {
                try? fm.removeItem(at: groupURL.appending(path: name))
            }
        }
    }
}
