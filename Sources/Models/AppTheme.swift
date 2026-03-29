import SwiftUI

enum AppTheme: String, CaseIterable, Identifiable {
    case system
    case light
    case dark

    var id: String {
        rawValue
    }

    var displayName: LocalizedStringResource {
        switch self {
        case .system: "theme_system"
        case .light: "theme_light"
        case .dark: "theme_dark"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }

    var iconName: String {
        switch self {
        case .system: "circle.lefthalf.filled"
        case .light: "sun.max.fill"
        case .dark: "moon.fill"
        }
    }

    /// Free users get system and light; dark requires Pro
    var isProOnly: Bool {
        switch self {
        case .system, .light: false
        case .dark: true
        }
    }
}
