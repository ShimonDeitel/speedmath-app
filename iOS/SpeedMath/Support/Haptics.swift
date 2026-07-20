import UIKit

enum HapticStyle: String, Codable, CaseIterable, Identifiable {
    case off, light, medium, heavy

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .off: return "Off"
        case .light: return "Light"
        case .medium: return "Medium"
        case .heavy: return "Heavy"
        }
    }

    fileprivate var impactStyle: UIImpactFeedbackGenerator.FeedbackStyle {
        switch self {
        case .off, .light: return .light
        case .medium: return .medium
        case .heavy: return .heavy
        }
    }
}

enum Haptics {
    static func light(_ style: HapticStyle) {
        guard style != .off else { return }
        UIImpactFeedbackGenerator(style: style.impactStyle).impactOccurred()
    }

    static func success(_ style: HapticStyle) {
        guard style != .off else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.success)
    }

    static func failure(_ style: HapticStyle) {
        guard style != .off else { return }
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }

    static func selection(_ style: HapticStyle) {
        guard style != .off else { return }
        UISelectionFeedbackGenerator().selectionChanged()
    }
}
