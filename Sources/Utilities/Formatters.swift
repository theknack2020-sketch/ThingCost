import Foundation
import SwiftUI

extension String {
    /// Parses a user-entered decimal string using the device locale first
    /// (so "12,99" works in comma-decimal regions like DE/FR/PL, where the
    /// numeric keypad shows a comma), falling back to C-locale parsing.
    var localizedDecimalValue: Double? {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.locale = .current
        if let number = formatter.number(from: self) {
            return number.doubleValue
        }
        // Fallback: normalize a stray comma to a period.
        return Double(replacingOccurrences(of: ",", with: "."))
    }
}

extension Int {
    /// Localized "1 day", "5 days" / "1 gün", "5 gün"
    var dayLabel: String {
        if self == 1 {
            String(localized: "day_singular \(self)")
        } else {
            String(localized: "day_plural \(self)")
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
        if self >= 100, truncatingRemainder(dividingBy: 1) < 0.01 {
            formatter.maximumFractionDigits = 0
        } else {
            formatter.maximumFractionDigits = 2
        }
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
