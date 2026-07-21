import Foundation
import SwiftData
import SwiftUI

/// Seeds a curated demo dataset when the app is launched with `--demoData`.
/// Used by UI tests and the App Store screenshot pipeline; never runs in production.
enum DemoData {
    @MainActor
    static func seedIfRequested(into container: ModelContainer) {
        let args = CommandLine.arguments
        guard args.contains("--demoData") || args.contains("-demoData") else { return }
        let context = ModelContext(container)
        let existing = (try? context.fetchCount(FetchDescriptor<Item>())) ?? 0
        guard existing == 0 else { return }

        let calendar = Calendar.current
        func daysAgo(_ days: Int) -> Date {
            calendar.date(byAdding: .day, value: -days, to: Date()) ?? Date()
        }

        let items: [(String, Double, Int, ItemCategory, String, Int)] = [
            // (name, price, daysOwned, category, icon, useCount)
            ("iPhone 15 Pro", 999.00, 365, .electronics, "iphone", 0),
            ("MacBook Air", 1199.00, 548, .electronics, "laptopcomputer", 0),
            ("Sony WH-1000XM5", 399.00, 300, .electronics, "headphones", 260),
            ("Espresso Machine", 699.00, 420, .kitchen, "cup.and.saucer.fill", 380),
            ("Nike Air Max", 160.00, 130, .sports, "figure.run", 48),
            ("Herman Miller Chair", 1095.00, 240, .furniture, "chair.lounge.fill", 0),
            ("Kindle Paperwhite", 139.00, 500, .electronics, "book.fill", 120),
            ("Winter Jacket", 189.00, 90, .clothing, "jacket", 30),
        ]

        for (name, price, days, category, icon, uses) in items {
            let item = Item(
                name: name,
                price: price,
                purchaseDate: daysAgo(days),
                category: category,
                iconName: icon
            )
            item.useCount = uses
            context.insert(item)
        }
        try? context.save()
    }
}
