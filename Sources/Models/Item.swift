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
    @Attribute(.externalStorage) var photoData: Data?
    @Attribute(.externalStorage) var receiptData: Data?
    var warrantyExpirationDate: Date?
    var useCount: Int

    init(
        name: String,
        price: Double,
        purchaseDate: Date,
        category: ItemCategory = .other,
        iconName: String = "bag.fill",
        photoData: Data? = nil,
        receiptData: Data? = nil,
        warrantyExpirationDate: Date? = nil
    ) {
        self.name = name
        self.price = price
        self.purchaseDate = purchaseDate
        self.category = category
        self.iconName = iconName
        createdAt = Date()
        self.photoData = photoData
        self.receiptData = receiptData
        self.warrantyExpirationDate = warrantyExpirationDate
        useCount = 0
    }

    // MARK: - Warranty

    var isWarrantyActive: Bool {
        guard let expiration = warrantyExpirationDate else { return false }
        return expiration > Date()
    }

    var warrantyDaysRemaining: Int? {
        guard let expiration = warrantyExpirationDate else { return nil }
        let days = Calendar.current.dateComponents([.day], from: Date(), to: expiration).day ?? 0
        return max(0, days)
    }

    var hasReceipt: Bool {
        receiptData != nil
    }

    // MARK: - Time-Based Cost

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

    // MARK: - Use-Based Cost

    var costPerUse: Double? {
        guard useCount > 0 else { return nil }
        return price / Double(useCount)
    }

    // MARK: - Worth It Score (0–100)

    /// Composite score: how "worth it" this purchase is.
    /// Factors: daily cost decay, usage frequency, ownership duration.
    /// Higher = better value. 70+ = great, 40-69 = decent, <40 = reconsider.
    var worthScore: Int {
        // Factor 1: Daily cost relative to price (max 40 pts)
        // As daily cost drops below 1% of price, it's a great deal
        let costRatio = dailyCost / max(price, 0.01)
        let costScore = max(0, min(40, Int((1.0 - costRatio * 100) * 0.4 * 100)))

        // Factor 2: Ownership duration (max 30 pts)
        // Longer ownership = better amortization
        let durationScore = switch daysOwned {
        case 0 ..< 7: 5
        case 7 ..< 30: 10
        case 30 ..< 90: 15
        case 90 ..< 180: 20
        case 180 ..< 365: 25
        default: 30
        }

        // Factor 3: Usage frequency (max 30 pts)
        // Uses per week since purchase
        let usageScore: Int
        if useCount > 0 {
            let weeks = max(Double(daysOwned) / 7.0, 1.0)
            let usesPerWeek = Double(useCount) / weeks
            switch usesPerWeek {
            case 0 ..< 0.5: usageScore = 5
            case 0.5 ..< 1: usageScore = 10
            case 1 ..< 3: usageScore = 15
            case 3 ..< 5: usageScore = 20
            case 5 ..< 7: usageScore = 25
            default: usageScore = 30
            }
        } else {
            // No usage data — neutral contribution
            usageScore = 15
        }

        return min(100, max(0, costScore + durationScore + usageScore))
    }

    var worthLabel: String {
        switch worthScore {
        case 80 ... 100: String(localized: "worth_amazing")
        case 60 ..< 80: String(localized: "worth_great")
        case 40 ..< 60: String(localized: "worth_decent")
        case 20 ..< 40: String(localized: "worth_meh")
        default: String(localized: "worth_poor")
        }
    }

    var worthColor: Color {
        switch worthScore {
        case 80 ... 100: .green
        case 60 ..< 80: .blue
        case 40 ..< 60: .orange
        case 20 ..< 40: .red.opacity(0.8)
        default: .red
        }
    }

    /// Projected daily cost after a given number of total days from purchase
    func projectedDailyCost(afterTotalDays days: Int) -> Double {
        guard days > 0 else { return price }
        return price / Double(days)
    }

    /// Cost per day at various future milestones
    var costMilestones: [CostMilestone] {
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
            .map { CostMilestone(label: String(localized: $0.0), days: $0.1, cost: projectedDailyCost(afterTotalDays: $0.1)) }
    }
}

struct CostMilestone {
    let label: String
    let days: Int
    let cost: Double
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

    var id: String {
        rawValue
    }

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
        case .electronics: "laptopcomputer"
        case .clothing: "tshirt.fill"
        case .furniture: "sofa.fill"
        case .vehicle: "car.fill"
        case .sports: "figure.run"
        case .kitchen: "fork.knife"
        case .accessories: "watch.analog"
        case .other: "bag.fill"
        }
    }

    var defaultIcon: String {
        iconName
    }
}
