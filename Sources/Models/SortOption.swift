import Foundation
import SwiftUI

enum SortOption: String, CaseIterable, Identifiable {
    case dailyCostHigh
    case dailyCostLow
    case priceHigh
    case priceLow
    case newest
    case oldest
    case name

    var id: String {
        rawValue
    }

    var displayName: LocalizedStringResource {
        switch self {
        case .dailyCostHigh: "sort_daily_high"
        case .dailyCostLow: "sort_daily_low"
        case .priceHigh: "sort_price_high"
        case .priceLow: "sort_price_low"
        case .newest: "sort_newest"
        case .oldest: "sort_oldest"
        case .name: "sort_name"
        }
    }
}
