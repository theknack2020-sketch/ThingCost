import Testing
import Foundation
@testable import ThingCost

@Suite("Item Cost Calculation")
struct ItemCostTests {
    @Test("Daily cost: price / days owned")
    func dailyCost() {
        let tenDaysAgo = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let item = Item(name: "Test", price: 1000, purchaseDate: tenDaysAgo)
        #expect(item.daysOwned == 10)
        #expect(abs(item.dailyCost - 100.0) < 0.01)
    }

    @Test("Same-day purchase has minimum 1 day")
    func sameDayMinimum() {
        let item = Item(name: "Today", price: 500, purchaseDate: Date())
        #expect(item.daysOwned >= 1)
        #expect(item.dailyCost <= 500)
    }

    @Test("Monthly cost is dailyCost × 30")
    func monthlyCost() {
        let date = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let item = Item(name: "Test", price: 3000, purchaseDate: date)
        #expect(abs(item.monthlyCost - item.dailyCost * 30) < 0.01)
    }

    @Test("Yearly cost is dailyCost × 365")
    func yearlyCost() {
        let date = Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        let item = Item(name: "Test", price: 3000, purchaseDate: date)
        #expect(abs(item.yearlyCost - item.dailyCost * 365) < 0.01)
    }

    @Test("Projected cost: price / totalDays")
    func projectedCost() {
        let date = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let item = Item(name: "Test", price: 365, purchaseDate: date)
        let projected = item.projectedDailyCost(afterTotalDays: 365)
        #expect(abs(projected - 1.0) < 0.01)
    }

    @Test("Projected cost with 0 days returns price")
    func projectedCostZeroDays() {
        let item = Item(name: "Test", price: 100, purchaseDate: Date())
        let projected = item.projectedDailyCost(afterTotalDays: 0)
        #expect(projected == 100)
    }

    @Test("Cost milestones only include future dates")
    func milestonesAreFuture() {
        let date = Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        let item = Item(name: "Test", price: 1000, purchaseDate: date)
        for milestone in item.costMilestones {
            #expect(milestone.days > item.daysOwned)
            #expect(milestone.cost < item.dailyCost)
        }
    }
}

@Suite("Item Category")
struct ItemCategoryTests {
    @Test("All categories have icon names")
    func categoryIcons() {
        for category in ItemCategory.allCases {
            #expect(!category.iconName.isEmpty)
        }
    }

    @Test("All categories have unique raw values")
    func uniqueRawValues() {
        let rawValues = ItemCategory.allCases.map(\.rawValue)
        #expect(Set(rawValues).count == rawValues.count)
    }
}

@Suite("Sort Options")
struct SortOptionTests {
    @Test("All sort options are available")
    func allSortOptions() {
        #expect(SortOption.allCases.count == 7)
    }
}
