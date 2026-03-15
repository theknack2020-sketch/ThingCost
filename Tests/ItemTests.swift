import Testing
import Foundation
@testable import ThingCost

@Suite("Item Model Tests")
struct ItemTests {
    @Test("Daily cost calculation - basic")
    func dailyCostBasic() {
        let item = Item(
            name: "Test",
            price: 1000,
            purchaseDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        )
        #expect(item.daysOwned == 10)
        #expect(abs(item.dailyCost - 100.0) < 0.01)
    }

    @Test("Daily cost - same day purchase")
    func dailyCostSameDay() {
        let item = Item(
            name: "Test",
            price: 500,
            purchaseDate: Date()
        )
        // Minimum 1 day to avoid division by zero
        #expect(item.daysOwned >= 1)
        #expect(item.dailyCost <= 500)
    }

    @Test("Monthly cost is 30x daily")
    func monthlyCost() {
        let item = Item(
            name: "Test",
            price: 3000,
            purchaseDate: Calendar.current.date(byAdding: .day, value: -100, to: Date())!
        )
        #expect(abs(item.monthlyCost - item.dailyCost * 30) < 0.01)
    }

    @Test("Projected daily cost")
    func projectedCost() {
        let item = Item(
            name: "Test",
            price: 365,
            purchaseDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        )
        let projected = item.projectedDailyCost(afterTotalDays: 365)
        #expect(abs(projected - 1.0) < 0.01)
    }

    @Test("Cost milestones only show future dates")
    func costMilestones() {
        let item = Item(
            name: "Test",
            price: 1000,
            purchaseDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!
        )
        let milestones = item.costMilestones
        #expect(!milestones.isEmpty)
        for milestone in milestones {
            #expect(milestone.days > item.daysOwned)
        }
    }

    @Test("Category has icon name")
    func categoryIcons() {
        for category in ItemCategory.allCases {
            #expect(!category.iconName.isEmpty)
        }
    }
}
