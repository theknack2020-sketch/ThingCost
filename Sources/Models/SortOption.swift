import Foundation

enum SortOption: String, CaseIterable, Identifiable {
    case dailyCostHigh = "Daily Cost ↓"
    case dailyCostLow = "Daily Cost ↑"
    case priceHigh = "Price ↓"
    case priceLow = "Price ↑"
    case newest = "Newest First"
    case oldest = "Oldest First"
    case name = "Name A-Z"

    var id: String { rawValue }
}
