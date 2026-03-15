import Foundation
import SwiftData
import SwiftUI

@Model
final class Item {
    var name: String
    var price: Double
    var purchaseDate: Date
    var category: ItemCategory
    var iconName: String
    var createdAt: Date

    init(
        name: String,
        price: Double,
        purchaseDate: Date,
        category: ItemCategory = .other,
        iconName: String = "bag.fill"
    ) {
        self.name = name
        self.price = price
        self.purchaseDate = purchaseDate
        self.category = category
        self.iconName = iconName
        self.createdAt = Date()
    }

    var daysOwned: Int {
        max(Calendar.current.dateComponents([.day], from: purchaseDate, to: Date()).day ?? 1, 1)
    }

    var dailyCost: Double {
        price / Double(daysOwned)
    }

    var monthlyCost: Double {
        dailyCost * 30
    }

    var yearlyCost: Double {
        dailyCost * 365
    }

    /// Projected daily cost after a given number of total days from purchase
    func projectedDailyCost(afterTotalDays days: Int) -> Double {
        guard days > 0 else { return price }
        return price / Double(days)
    }

    /// Cost per day at various future milestones
    var costMilestones: [(label: String, days: Int, cost: Double)] {
        let milestones: [(LocalizedStringResource, Int)] = [
            ("milestone_1month", 30),
            ("milestone_3months", 90),
            ("milestone_6months", 180),
            ("milestone_1year", 365),
            ("milestone_2years", 730),
            ("milestone_3years", 1095),
        ]
        return milestones
            .filter { $0.1 > daysOwned }
            .map { (label: String(localized: $0.0), days: $0.1, cost: projectedDailyCost(afterTotalDays: $0.1)) }
    }
}

enum ItemCategory: String, Codable, CaseIterable, Identifiable {
    case electronics
    case clothing
    case furniture
    case vehicle
    case sports
    case kitchen
    case accessories
    case other

    var id: String { rawValue }

    var displayName: LocalizedStringResource {
        switch self {
        case .electronics: "cat_electronics"
        case .clothing: "cat_clothing"
        case .furniture: "cat_furniture"
        case .vehicle: "cat_vehicle"
        case .sports: "cat_sports"
        case .kitchen: "cat_kitchen"
        case .accessories: "cat_accessories"
        case .other: "cat_other"
        }
    }

    var iconName: String {
        switch self {
        case .electronics: return "laptopcomputer"
        case .clothing: return "tshirt.fill"
        case .furniture: return "sofa.fill"
        case .vehicle: return "car.fill"
        case .sports: return "figure.run"
        case .kitchen: return "fork.knife"
        case .accessories: return "watch.analog"
        case .other: return "bag.fill"
        }
    }

    var defaultIcon: String { iconName }
}
