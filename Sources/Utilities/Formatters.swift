import Foundation
import SwiftUI

extension Int {
    /// Localized "1 day", "5 days" / "1 gün", "5 gün"
    var dayLabel: String {
        if self == 1 {
            return String(localized: "day_singular \(self)")
        } else {
            return String(localized: "day_plural \(self)")
        }
    }
}

extension Double {
    /// Compact currency: "₺85.000" for large, "₺361,11" for medium, "₺3,80" for small
    func compactCurrency(code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        if self >= 10000 {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
        }
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
