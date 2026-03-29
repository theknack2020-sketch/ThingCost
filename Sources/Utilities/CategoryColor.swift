import SwiftUI

extension ItemCategory {
    var color: Color {
        switch self {
        case .electronics: .blue
        case .clothing: .purple
        case .furniture: .orange
        case .vehicle: .red
        case .sports: .green
        case .kitchen: .yellow
        case .accessories: .pink
        case .other: .gray
        }
    }
}
