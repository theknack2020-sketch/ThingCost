import Foundation

extension Int {
    /// "1 day", "5 days"
    var dayLabel: String {
        "\(self) \(self == 1 ? "day" : "days")"
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
        } else if self >= 100 {
            formatter.maximumFractionDigits = 2
        } else {
            formatter.maximumFractionDigits = 2
        }
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
