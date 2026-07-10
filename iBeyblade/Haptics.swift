import UIKit

enum Haptics {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let notif = UINotificationFeedbackGenerator()

    static func impact(_ magnitude: CGFloat) {
        switch magnitude {
        case ..<0.4: light.impactOccurred(intensity: max(0.3, magnitude))
        case 0.4..<0.75: medium.impactOccurred(intensity: magnitude)
        default: heavy.impactOccurred(intensity: min(1, magnitude))
        }
    }

    static func success() { notif.notificationOccurred(.success) }
    static func warning() { notif.notificationOccurred(.warning) }
}
