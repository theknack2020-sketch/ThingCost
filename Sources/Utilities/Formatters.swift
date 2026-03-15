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
    /// Compact currency: no decimals for whole numbers, 2 decimals otherwise
    func compactCurrency(code: String) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = code
        // If the value is effectively a whole number, skip decimals
        if self >= 100 && self.truncatingRemainder(dividingBy: 1) < 0.01 {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
        }
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
