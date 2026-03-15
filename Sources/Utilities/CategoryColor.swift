import SwiftUI

extension ItemCategory {
    var color: Color {
        switch self {
        case .electronics: return .blue
        case .clothing: return .purple
        case .furniture: return .orange
        case .vehicle: return .red
        case .sports: return .green
        case .kitchen: return .yellow
        case .accessories: return .pink
        case .other: return .gray
        }
    }
}
