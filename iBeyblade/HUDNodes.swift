import SpriteKit

/// Groups the always-visible battle HUD: stamina bars, round pips, boost
/// button, language/pause controls.
final class HUDNodes {
    let container = SKNode()

    let playerStaminaBg = SKShapeNode(rectOf: CGSize(width: 130, height: 10), cornerRadius: 5)
    let playerStaminaFill = SKShapeNode(rectOf: CGSize(width: 130, height: 10), cornerRadius: 5)
    let playerNameLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    let playerPips = SKNode()

    let cpuStaminaBg = SKShapeNode(rectOf: CGSize(width: 130, height: 10), cornerRadius: 5)
    let cpuStaminaFill = SKShapeNode(rectOf: CGSize(width: 130, height: 10), cornerRadius: 5)
    let cpuNameLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    let cpuPips = SKNode()

    let roundLabel = SKLabelNode(fontNamed: "Menlo-Bold")

    let boostButton = SKShapeNode(circleOfRadius: 34)
    let boostLabel = SKLabelNode(fontNamed: "Menlo-Bold")
    let boostChargesLabel = SKLabelNode(fontNamed: "Menlo")

    let langButton = SKLabelNode(fontNamed: "Menlo-Bold")
    let langHit = SKShapeNode(rectOf: CGSize(width: 44, height: 40))
    let pauseButton = SKShapeNode(rectOf: CGSize(width: 48, height: 40), cornerRadius: 8)
    let pauseLabel = SKLabelNode(fontNamed: "Menlo-Bold")
}
