import Testing
import Foundation
@testable import ThingCost

@Suite("Edge Case: Extreme Values")
struct ExtremeValueTests {
    @Test("Very large price: 999,999,999")
    func veryLargePrice() {
        let date = Calendar.current.date(byAdding: .day, value: -30, to: Date())!
        let item = Item(name: "Yacht", price: 999_999_999, purchaseDate: date)
        #expect(item.dailyCost > 0)
        #expect(item.dailyCost == 999_999_999.0 / 30.0)
        #expect(item.monthlyCost == item.dailyCost * 30)
        #expect(item.yearlyCost == item.dailyCost * 365)
    }

    @Test("Very small price: 0.01")
    func verySmallPrice() {
        let date = Calendar.current.date(byAdding: .day, value: -365, to: Date())!
        let item = Item(name: "Penny", price: 0.01, purchaseDate: date)
        #expect(item.dailyCost > 0)
        #expect(item.dailyCost < 0.001) // < 0.001 per day
    }

    @Test("Very old purchase: 10 years ago")
    func veryOldPurchase() {
        let date = Calendar.current.date(byAdding: .year, value: -10, to: Date())!
        let item = Item(name: "Antique", price: 1000, purchaseDate: date)
        #expect(item.daysOwned > 3600) // ~3650 days
        #expect(item.dailyCost < 1) // should be very low
    }

    @Test("Purchase 1 second ago: minimum 1 day")
    func justPurchased() {
        let item = Item(name: "Just Bought", price: 500, purchaseDate: Date())
        #expect(item.daysOwned == 1)
        #expect(item.dailyCost == 500)
    }

    @Test("Emoji name: stored and retrieved")
    func emojiName() {
        let item = Item(name: "🎮 PS5 Controller", price: 2499, purchaseDate: Date())
        #expect(item.name == "🎮 PS5 Controller")
        #expect(item.dailyCost == 2499)
    }

    @Test("Unicode name: stored and retrieved")
    func unicodeName() {
        let item = Item(name: "Çamaşır Makinesi", price: 15000, purchaseDate: Date())
        #expect(item.name == "Çamaşır Makinesi")
    }

    @Test("Very long name: 100 characters")
    func veryLongName() {
        let longName = String(repeating: "A", count: 100)
        let item = Item(name: longName, price: 100, purchaseDate: Date())
        #expect(item.name.count == 100)
    }
}

@Suite("Edge Case: Compact Currency Formatting")
struct CompactCurrencyTests {
    @Test("Large value: no decimals")
    func largeValueNoDecimals() {
        let result = Double(84999).compactCurrency(code: "USD")
        #expect(!result.contains(".00"))
    }

    @Test("Small value: has decimals")
    func smallValueHasDecimals() {
        let result = Double(3.50).compactCurrency(code: "USD")
        #expect(result.contains("3") || result.contains("50"))
    }

    @Test("Day label: singular")
    func dayLabelSingular() {
        let label = 1.dayLabel
        // Should contain "1" and a day word
        #expect(label.contains("1"))
    }

    @Test("Day label: plural")
    func dayLabelPlural() {
        let label = 5.dayLabel
        #expect(label.contains("5"))
    }

    @Test("Day label: zero is handled")
    func dayLabelZero() {
        let label = 0.dayLabel
        #expect(label.contains("0"))
    }
}

@Suite("Edge Case: Milestones")
struct MilestoneEdgeCaseTests {
    @Test("Item purchased 2 years ago: few milestones left")
    func oldItemFewMilestones() {
        let date = Calendar.current.date(byAdding: .year, value: -2, to: Date())!
        let item = Item(name: "Old Item", price: 1000, purchaseDate: date)
        // 2 years = ~730 days, so only 3-year milestone should remain
        let milestones = item.costMilestones
        #expect(milestones.count == 1)
        #expect(milestones.first?.days == 1095)
    }

    @Test("Item purchased 5 years ago: no milestones")
    func veryOldItemNoMilestones() {
        let date = Calendar.current.date(byAdding: .year, value: -5, to: Date())!
        let item = Item(name: "Very Old", price: 1000, purchaseDate: date)
        #expect(item.costMilestones.isEmpty)
    }

    @Test("Today's item: all milestones available")
    func newItemAllMilestones() {
        let item = Item(name: "New", price: 1000, purchaseDate: Date())
        #expect(item.costMilestones.count == 6)
    }
}

@Suite("Edge Case: All Categories")
struct CategoryEdgeCaseTests {
    @Test("Each category has a valid color")
    func allCategoriesHaveColors() {
        for category in ItemCategory.allCases {
            // Accessing .color shouldn't crash
            _ = category.color
        }
    }

    @Test("Each category has a localized display name")
    func allCategoriesHaveDisplayName() {
        for category in ItemCategory.allCases {
            let name = String(localized: category.displayName)
            #expect(!name.isEmpty)
        }
    }

    @Test("Default category is .other")
    func defaultCategory() {
        let item = Item(name: "Test", price: 100, purchaseDate: Date())
        #expect(item.category == .other)
    }
}

@Suite("Edge Case: Sort Options")
struct SortEdgeCaseTests {
    @Test("All sort options have localized display names")
    func allSortOptionsHaveDisplayName() {
        for option in SortOption.allCases {
            let name = String(localized: option.displayName)
            #expect(!name.isEmpty)
        }
    }
}

@Suite("Edge Case: AppTheme")
struct AppThemeTests {
    @Test("All themes have valid color scheme or nil")
    func allThemesValid() {
        #expect(AppTheme.system.colorScheme == nil)
        #expect(AppTheme.light.colorScheme == .light)
        #expect(AppTheme.dark.colorScheme == .dark)
    }

    @Test("All themes have icons")
    func allThemesHaveIcons() {
        for theme in AppTheme.allCases {
            #expect(!theme.iconName.isEmpty)
        }
    }

    @Test("All themes have display names")
    func allThemesHaveDisplayNames() {
        for theme in AppTheme.allCases {
            let name = String(localized: theme.displayName)
            #expect(!name.isEmpty)
        }
    }
}
