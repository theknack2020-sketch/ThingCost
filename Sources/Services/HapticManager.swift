import UIKit

@MainActor
final class HapticManager {
    static let shared = HapticManager()

    private let impactLight = UIImpactFeedbackGenerator(style: .light)
    private let impactMedium = UIImpactFeedbackGenerator(style: .medium)
    private let impactHeavy = UIImpactFeedbackGenerator(style: .heavy)
    private let impactRigid = UIImpactFeedbackGenerator(style: .rigid)
    private let impactSoft = UIImpactFeedbackGenerator(style: .soft)
    private let notificationGenerator = UINotificationFeedbackGenerator()
    private let selectionGenerator = UISelectionFeedbackGenerator()

    private init() {
        impactLight.prepare()
        impactMedium.prepare()
        notificationGenerator.prepare()
        selectionGenerator.prepare()
    }

    // MARK: - Core

    func impact(style: UIImpactFeedbackGenerator.FeedbackStyle) {
        switch style {
        case .light: impactLight.impactOccurred()
        case .medium: impactMedium.impactOccurred()
        case .heavy: impactHeavy.impactOccurred()
        case .rigid: impactRigid.impactOccurred()
        case .soft: impactSoft.impactOccurred()
        @unknown default: impactMedium.impactOccurred()
        }
    }

    func notification(type: UINotificationFeedbackGenerator.FeedbackType) {
        notificationGenerator.notificationOccurred(type)
    }

    func selection() {
        selectionGenerator.selectionChanged()
    }

    // MARK: - Convenience

    func tap() {
        impact(style: .light)
    }

    func save() {
        notification(type: .success)
    }

    func delete() {
        notification(type: .warning)
    }

    func error() {
        notification(type: .error)
    }

    func celebrate() {
        impact(style: .heavy)
    }
}
