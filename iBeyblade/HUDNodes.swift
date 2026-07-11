import SpriteKit

/// Groups the always-visible battle HUD: stamina bars, round pips, Special
/// Move buttons (one per player), language/pause/settings/help controls.
final class HUDNodes {
    let container = SKNode()

    let playerStaminaBg = SKShapeNode(rectOf: CGSize(width: 130, height: 10), cornerRadius: 5)
    let playerStaminaFill = SKShapeNode(rectOf: CGSize(width: 130, height: 10), cornerRadius: 5)
    let playerNameLabel = SKLabelNode(fontNamed: "Menlo-Bold")

    let cpuStaminaBg = SKShapeNode(rectOf: CGSize(width: 130, height: 10), cornerRadius: 5)
    let cpuStaminaFill = SKShapeNode(rectOf: CGSize(width: 130, height: 10), cornerRadius: 5)
    let cpuNameLabel = SKLabelNode(fontNamed: "Menlo-Bold")

    let roundLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    let suddenDeathLabel = SKLabelNode(fontNamed: "Menlo-Bold")

    // Player 1 Special Move button (bottom-right)
    let boostButton = SKShapeNode(circleOfRadius: 34)
    let boostLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    let boostChargesLabel = SKLabelNode(fontNamed: "Menlo")

    // Player 2 Special Move button (top-right, local 2P only)
    let boostButton2 = SKShapeNode(circleOfRadius: 34)
    let boostLabel2 = SKLabelNode(fontNamed: "Menlo-Bold")
    let boostChargesLabel2 = SKLabelNode(fontNamed: "Menlo")

    let langButton = SKLabelNode(fontNamed: "Menlo-Bold")
    let langHit = SKShapeNode(rectOf: CGSize(width: 44, height: 40))
    let pauseButton = SKShapeNode(rectOf: CGSize(width: 48, height: 40), cornerRadius: 8)
    let pauseLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    /// Always-visible shortcut back to the main menu during a match, so
    /// quitting a bot fight doesn't require pausing first.
    let homeButton = SKShapeNode(rectOf: CGSize(width: 48, height: 40), cornerRadius: 8)
    let homeLabel = SKLabelNode(fontNamed: "Menlo-Bold")
}
