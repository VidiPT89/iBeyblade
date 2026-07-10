import SpriteKit
import UIKit

/// Forwards hardware-keyboard presses (space to boost, P/Escape to pause) to
/// the current GameScene — handy for the Simulator and any iPad with a
/// keyboard.
final class GameSKView: SKView {
    override var canBecomeFirstResponder: Bool { true }

    override func safeAreaInsetsDidChange() {
        super.safeAreaInsetsDidChange()
        (scene as? GameScene)?.layout(size: bounds.size)
    }

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let scene = scene as? GameScene else { return super.pressesBegan(presses, with: event) }
        var handled = false
        for press in presses {
            if let key = Self.token(for: press) {
                scene.handleKeyDown(key, isRepeat: false)
                handled = true
            }
        }
        if !handled { super.pressesBegan(presses, with: event) }
    }

    override func pressesEnded(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        guard let scene = scene as? GameScene else { return super.pressesEnded(presses, with: event) }
        var handled = false
        for press in presses {
            if let key = Self.token(for: press) {
                scene.handleKeyUp(key)
                handled = true
            }
        }
        if !handled { super.pressesEnded(presses, with: event) }
    }

    private static func token(for press: UIPress) -> String? {
        guard let key = press.key else { return nil }
        switch key.keyCode {
        case .keyboardSpacebar: return " "
        case .keyboardP: return "p"
        case .keyboardEscape: return "Escape"
        default: return nil
        }
    }
}
