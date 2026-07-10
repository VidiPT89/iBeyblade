import UIKit

enum Haptics {
    private static let light = UIImpactFeedbackGenerator(style: .light)
    private static let medium = UIImpactFeedbackGenerator(style: .medium)
    private static let heavy = UIImpactFeedbackGenerator(style: .heavy)
    private static let notif = UINotificationFeedbackGenerator()

    static var isEnabled: Bool {
        get { UserDefaults.standard.object(forKey: "ibeyblade.haptics") == nil ? true : UserDefaults.standard.bool(forKey: "ibeyblade.haptics") }
        set { UserDefaults.standard.set(newValue, forKey: "ibeyblade.haptics") }
    }

    static func impact(_ magnitude: CGFloat) {
        guard isEnabled else { return }
        switch magnitude {
        case ..<0.4: light.impactOccurred(intensity: max(0.3, magnitude))
        case 0.4..<0.75: medium.impactOccurred(intensity: magnitude)
        default: heavy.impactOccurred(intensity: min(1, magnitude))
        }
    }

    static func success() {
        guard isEnabled else { return }
        notif.notificationOccurred(.success)
    }

    static func warning() {
        guard isEnabled else { return }
        notif.notificationOccurred(.warning)
    }
}
