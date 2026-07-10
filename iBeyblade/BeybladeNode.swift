import SpriteKit

/// Visual representation of a `BeybladeEntity`: a glowing disc with rotating
/// fin blades, a stamina ring, and one-shot launch/boost/KO animations.
final class BeybladeNode: SKNode {
    let entity: BeybladeEntity

    private let bodyShape: SKShapeNode
    private let finLayer: SKNode
    private let hubShape: SKShapeNode
    private let staminaRing: SKShapeNode
    private let nameLabel: SKLabelNode

    init(entity: BeybladeEntity) {
        self.entity = entity
        let r = entity.preset.radius
        bodyShape = SKShapeNode(circleOfRadius: r)
        finLayer = SKNode()
        hubShape = SKShapeNode(circleOfRadius: r * 0.34)
        staminaRing = SKShapeNode()
        nameLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        super.init()

        let bodyColor = SKColor(hex: entity.preset.bodyHex)
        let glowColor = SKColor(hex: entity.preset.glowHex)

        bodyShape.fillColor = SKColor(white: 0.08, alpha: 1)
        bodyShape.strokeColor = glowColor
        bodyShape.lineWidth = 3
        bodyShape.glowWidth = 6
        addChild(bodyShape)

        for i in 0..<6 {
            let a0 = CGFloat(i) * .pi / 3
            let path = CGMutablePath()
            let outer = r * 0.95
            let inner = r * 0.5
            path.move(to: CGPoint(x: cos(a0) * outer, y: sin(a0) * outer))
            path.addLine(to: CGPoint(x: cos(a0 + 0.32) * inner, y: sin(a0 + 0.32) * inner))
            path.addLine(to: CGPoint(x: cos(a0 - 0.32) * inner, y: sin(a0 - 0.32) * inner))
            path.closeSubpath()
            let fin = SKShapeNode(path: path)
            fin.fillColor = bodyColor
            fin.strokeColor = .clear
            fin.alpha = 0.9
            finLayer.addChild(fin)
        }
        addChild(finLayer)

        hubShape.fillColor = SKColor(white: 0.05, alpha: 1)
        hubShape.strokeColor = glowColor
        hubShape.lineWidth = 2
        hubShape.glowWidth = 3
        addChild(hubShape)

        staminaRing.strokeColor = glowColor
        staminaRing.lineWidth = 4
        staminaRing.lineCap = .round
        staminaRing.fillColor = .clear
        addChild(staminaRing)

        nameLabel.fontSize = 11
        nameLabel.fontColor = SKColor(white: 1, alpha: 0.8)
        nameLabel.text = entity.preset.name
        nameLabel.position = CGPoint(x: 0, y: -r - 16)
        addChild(nameLabel)

        updateStaminaRing()
    }

    required init?(coder: NSCoder) { fatalError("unused") }

    func resetForNewRound() {
        removeAllActions()
        setScale(1)
        zRotation = 0
        alpha = 1
        bodyShape.position = .zero
        bodyShape.setScale(1)
        bodyShape.alpha = 1
    }

    func syncVisual() {
        position = entity.position
        finLayer.zRotation = entity.spinAngle
        let shake = entity.wobble * 4
        if shake > 0.1 {
            bodyShape.position = CGPoint(x: CGFloat.random(in: -shake...shake), y: CGFloat.random(in: -shake...shake))
        }
        updateStaminaRing()
    }

    private func updateStaminaRing() {
        let r = entity.preset.radius + 10
        let frac = max(0, min(1, entity.stamina / 100))
        let start: CGFloat = .pi / 2
        let end = start - frac * 2 * .pi
        let path = CGMutablePath()
        path.addArc(center: .zero, radius: r, startAngle: start, endAngle: end, clockwise: true)
        staminaRing.path = path
        staminaRing.strokeColor = frac < 0.25 ? SKColor(hex: "#ff4d4d") : SKColor(hex: entity.preset.glowHex)
    }

    func playLaunchPulse() {
        setScale(0.4)
        run(.sequence([.scale(to: 1.1, duration: 0.12), .scale(to: 1.0, duration: 0.1)]))
    }

    func playBoostPulse() {
        let flash = SKShapeNode(circleOfRadius: entity.preset.radius * 1.4)
        flash.strokeColor = SKColor(hex: entity.preset.glowHex)
        flash.lineWidth = 3
        flash.fillColor = .clear
        flash.glowWidth = 6
        addChild(flash)
        flash.run(.sequence([
            .group([.scale(to: 1.8, duration: 0.35), .fadeOut(withDuration: 0.35)]),
            .removeFromParent(),
        ]))
    }

    /// The top's guardian spirit bursting out — bigger and brighter than a
    /// regular boost pulse, marking a Special Move.
    func playSpecialBurst() {
        let glowColor = SKColor(hex: entity.preset.glowHex)
        for i in 0..<3 {
            let ring = SKShapeNode(circleOfRadius: entity.preset.radius)
            ring.strokeColor = glowColor
            ring.lineWidth = 4
            ring.fillColor = .clear
            ring.glowWidth = 8
            ring.alpha = 0.9
            ring.zPosition = -1
            addChild(ring)
            let delay = Double(i) * 0.12
            ring.run(.sequence([
                .wait(forDuration: delay),
                .group([.scale(to: 3.4, duration: 0.6), .fadeOut(withDuration: 0.6)]),
                .removeFromParent(),
            ]))
        }
        let core = SKShapeNode(circleOfRadius: entity.preset.radius * 1.3)
        core.fillColor = glowColor
        core.strokeColor = .clear
        core.alpha = 0.6
        core.zPosition = -1
        addChild(core)
        core.run(.sequence([.group([.scale(to: 2.4, duration: 0.5), .fadeOut(withDuration: 0.5)]), .removeFromParent()]))
    }

    func playKOAnimation(reason: KOReason) {
        removeAllActions()
        switch reason {
        case .spinOut:
            run(.sequence([
                .group([.scale(to: 0.15, duration: 0.6), .rotate(byAngle: .pi * 2.2, duration: 0.6), .fadeOut(withDuration: 0.6)]),
            ]))
        case .ringOut:
            let dir = CGVector(dx: entity.velocity.dx, dy: entity.velocity.dy)
            let len = max(1, hypot(dir.dx, dir.dy))
            let fly = CGVector(dx: dir.dx / len * 240, dy: dir.dy / len * 240)
            run(.sequence([
                .group([.moveBy(x: fly.dx, y: fly.dy, duration: 0.5), .fadeOut(withDuration: 0.5), .scale(to: 0.6, duration: 0.5)]),
            ]))
        case .burst:
            let burst = SKShapeNode(circleOfRadius: entity.preset.radius)
            burst.fillColor = SKColor(hex: entity.preset.glowHex)
            burst.strokeColor = .clear
            burst.alpha = 0.8
            addChild(burst)
            burst.run(.sequence([.group([.scale(to: 3, duration: 0.4), .fadeOut(withDuration: 0.4)]), .removeFromParent()]))
            run(.sequence([.group([.scale(to: 0, duration: 0.25), .fadeOut(withDuration: 0.25)])]))
        }
    }
}
