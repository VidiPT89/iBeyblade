import SpriteKit

enum Phase {
    case splash, menu, launch, battle, roundResult, matchOver, paused
}

enum Difficulty: String, CaseIterable {
    case easy, normal, hard
}

struct DifficultyConfig {
    /// radians of random error added to the CPU's aim
    let aimVariance: CGFloat
    let powerMin: CGFloat
    let powerMax: CGFloat
    /// chance per check that the CPU spends a boost charge when it's behind
    let boostChance: CGFloat
    let boostCheckInterval: ClosedRange<CGFloat>
}

enum GameConfig {
    static let difficulties: [Difficulty: DifficultyConfig] = [
        .easy: DifficultyConfig(aimVariance: 0.5, powerMin: 0.45, powerMax: 0.7, boostChance: 0.12, boostCheckInterval: 2.5...4.5),
        .normal: DifficultyConfig(aimVariance: 0.28, powerMin: 0.6, powerMax: 0.88, boostChance: 0.28, boostCheckInterval: 1.8...3.2),
        .hard: DifficultyConfig(aimVariance: 0.12, powerMin: 0.75, powerMax: 1.0, boostChance: 0.48, boostCheckInterval: 1.0...2.2),
    ]
    static let winsNeeded = 2
}

/// A tappable region tracked outside the node tree's normal hit-testing,
/// checked as a simple linear scan against the last touch location.
struct UIButton {
    let node: SKNode
    let id: String
}

struct Spark {
    var x: CGFloat
    var y: CGFloat
    var vx: CGFloat
    var vy: CGFloat
    var life: CGFloat = 0
    var maxLife: CGFloat
    weak var node: SKShapeNode?
}

final class GameScene: SKScene {

    // MARK: State

    var phase: Phase = .splash
    var difficulty: Difficulty = .normal
    var playerPresetIndex = 0
    var cpuPresetIndex = 1
    var playerWins = 0
    var cpuWins = 0
    var roundNumber = 1
    var gamePaused = false
    var lastRoundLoser: BeybladeEntity?
    var lastRoundReason: KOReason?
    var pendingRoundEnd: CGFloat?
    var collisionCooldown: CGFloat = 0

    var player: BeybladeEntity!
    var cpu: BeybladeEntity!
    var playerNode: BeybladeNode!
    var cpuNode: BeybladeNode!

    // MARK: Arena geometry (screen-space, recomputed on layout)

    var arenaCenter: CGPoint = .zero
    var arenaRadius: CGFloat = 140
    let arenaContainer = SKNode()
    var arenaFloor: SKShapeNode!
    var arenaRim: SKShapeNode!
    var arenaRimGlow: SKShapeNode!

    let entitiesContainer = SKNode()
    let sparksContainer = SKNode()
    var sparks: [Spark] = []

    var topSafeInset: CGFloat = 0
    var bottomSafeInset: CGFloat = 0

    // MARK: UI (see GameScene+UI.swift)

    var hud = HUDNodes()
    var menuOverlay: SKNode?
    var launchOverlay: SKNode?
    var pauseOverlay: SKNode?
    var roundResultOverlay: SKNode?
    var matchOverOverlay: SKNode?
    var buttons: [UIButton] = []

    var menuTitleLabel: SKLabelNode?
    var menuTaglineLabel: SKLabelNode?
    var diffButtons: [Difficulty: (bg: SKShapeNode, label: SKLabelNode)] = [:]
    var topCards: [(bg: SKShapeNode, name: SKLabelNode, type: SKLabelNode, stats: SKNode)] = []
    var startLabel: SKLabelNode?
    var langButtonLabel: SKLabelNode?

    var pullHintLabel: SKLabelNode?
    var pullIndicator: SKShapeNode?
    var launchAnchor: CGPoint = .zero
    var isDragging = false
    var dragCurrent: CGPoint = .zero

    var pauseTitle: SKLabelNode?
    var pauseSub: SKLabelNode?
    var roundResultTitle: SKLabelNode?
    var roundResultSub: SKLabelNode?
    var matchOverTitle: SKLabelNode?
    var matchOverSub: SKLabelNode?
    var matchAgainLabel: SKLabelNode?
    var matchMenuLabel: SKLabelNode?
    var matchAgainBg: SKShapeNode?
    var matchMenuBg: SKShapeNode?

    // Splash (see GameScene+Splash.swift)
    var splashOverlay: SKNode?
    var splashBg: SKShapeNode?
    var splashTitle: SKLabelNode?
    var splashTop: SKShapeNode?
    var splashFins: SKNode?
    var splashCredit: SKLabelNode?
    var splashLink: SKLabelNode?
    var splashSkipLabel: SKLabelNode?

    // Ambient background
    struct Mote { let node: SKShapeNode; let speed: CGFloat; var phase: CGFloat }
    var motes: [Mote] = []

    // AI (see GameScene+AI.swift)
    var cpuBoostTimer: CGFloat = 0

    var lastUpdateTime: TimeInterval = 0

    // MARK: Lifecycle

    override func didMove(to view: SKView) {
        backgroundColor = SKColor(hex: "#05060f")
        anchorPoint = .zero

        buildAmbientBackground()
        buildArena()
        addChild(entitiesContainer)
        addChild(sparksContainer)
        buildEntities()
        buildHUD()
        buildMenu()
        buildLaunchOverlay()
        buildPauseOverlay()
        buildRoundResultOverlay()
        buildMatchOverOverlay()
        buildSplash()
        refreshTexts()
        layout(size: size)

        showMenu()
        playSplash()

        view.isMultipleTouchEnabled = true
    }

    override func didChangeSize(_ oldSize: CGSize) {
        layout(size: size)
    }

    func layout(size: CGSize) {
        guard size.width > 0, size.height > 0, arenaFloor != nil else { return }
        topSafeInset = view?.safeAreaInsets.top ?? 0
        bottomSafeInset = view?.safeAreaInsets.bottom ?? 0

        let hudHeight: CGFloat = 96 + topSafeInset
        let controlsHeight: CGFloat = 120 + bottomSafeInset
        let sideMargin: CGFloat = 24
        let availableW = size.width - sideMargin * 2
        let availableH = size.height - hudHeight - controlsHeight
        let newRadius = max(60, min(availableW, availableH) / 2)
        let newCenter = CGPoint(x: size.width / 2, y: controlsHeight + availableH / 2)

        let delta = CGVector(dx: newCenter.x - arenaCenter.x, dy: newCenter.y - arenaCenter.y)
        if player != nil, arenaRadius > 0 {
            player.position.x += delta.dx; player.position.y += delta.dy
            cpu.position.x += delta.dx; cpu.position.y += delta.dy
        }

        arenaCenter = newCenter
        arenaRadius = newRadius
        redrawArena()

        layoutHUD(size: size)
        layoutMenu(size: size)
        layoutLaunchOverlay(size: size)
        layoutPauseOverlay(size: size)
        layoutRoundResultOverlay(size: size)
        layoutMatchOverOverlay(size: size)
        layoutSplash(size: size)
    }

    // MARK: Arena

    func buildArena() {
        arenaFloor = SKShapeNode()
        arenaFloor.fillColor = SKColor(hex: "#0d0f22")
        arenaFloor.strokeColor = .clear
        arenaContainer.addChild(arenaFloor)

        arenaRimGlow = SKShapeNode()
        arenaRimGlow.strokeColor = SKColor(hex: "#4d78ff")
        arenaRimGlow.fillColor = .clear
        arenaRimGlow.lineWidth = 10
        arenaRimGlow.glowWidth = 14
        arenaRimGlow.alpha = 0.35
        arenaContainer.addChild(arenaRimGlow)

        arenaRim = SKShapeNode()
        arenaRim.strokeColor = SKColor(hex: "#7fa8ff")
        arenaRim.fillColor = .clear
        arenaRim.lineWidth = 4
        arenaRim.glowWidth = 4
        arenaContainer.addChild(arenaRim)

        addChild(arenaContainer)
    }

    func redrawArena() {
        let rect = CGRect(x: arenaCenter.x - arenaRadius, y: arenaCenter.y - arenaRadius, width: arenaRadius * 2, height: arenaRadius * 2)
        arenaFloor.path = CGPath(ellipseIn: rect, transform: nil)
        arenaRimGlow.path = CGPath(ellipseIn: rect, transform: nil)
        arenaRim.path = CGPath(ellipseIn: rect, transform: nil)
    }

    // MARK: Entities

    func buildEntities() {
        player = BeybladeEntity(preset: BeybladePresets.all[playerPresetIndex], isPlayer: true)
        cpu = BeybladeEntity(preset: BeybladePresets.all[cpuPresetIndex], isPlayer: false)
        playerNode = BeybladeNode(entity: player)
        cpuNode = BeybladeNode(entity: cpu)
        entitiesContainer.addChild(cpuNode)
        entitiesContainer.addChild(playerNode)
    }

    func rebuildEntities() {
        playerNode.removeFromParent()
        cpuNode.removeFromParent()
        buildEntities()
    }

    // MARK: Main loop

    override func update(_ currentTime: TimeInterval) {
        var dt = currentTime - lastUpdateTime
        if lastUpdateTime == 0 { dt = 1.0 / 60.0 }
        dt = min(1.0 / 20.0, dt)
        lastUpdateTime = currentTime

        updateAmbientBackground(dt: CGFloat(dt))
        if player != nil, !player.launched { player.spinAngle += CGFloat(dt) * 3 }
        if cpu != nil, !cpu.launched { cpu.spinAngle += CGFloat(dt) * 3 }
        tick(dt: CGFloat(dt), time: CGFloat(currentTime))
        updateSparks(dt: CGFloat(dt))
        playerNode.syncVisual()
        cpuNode.syncVisual()
        updateHUDBars()
    }

    // MARK: Ambient background

    func buildAmbientBackground() {
        for _ in 0..<40 {
            let dot = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.6...1.8))
            dot.fillColor = SKColor(white: 0.9, alpha: 0.5)
            dot.strokeColor = .clear
            dot.zPosition = -10
            dot.position = CGPoint(x: CGFloat.random(in: 0...size.width), y: CGFloat.random(in: 0...size.height))
            addChild(dot)
            motes.append(Mote(node: dot, speed: CGFloat.random(in: 3...12), phase: CGFloat.random(in: 0...(2 * .pi))))
        }
    }

    func updateAmbientBackground(dt: CGFloat) {
        guard size.height > 0 else { return }
        for i in motes.indices {
            var mote = motes[i]
            mote.node.position.y -= mote.speed * dt
            if mote.node.position.y < -5 {
                mote.node.position.y = size.height + 5
                mote.node.position.x = CGFloat.random(in: 0...size.width)
            }
            mote.phase += dt * 2
            mote.node.alpha = 0.1 + (sin(mote.phase) * 0.5 + 0.5) * 0.3
            motes[i] = mote
        }
    }

    // MARK: Sparks (collision particles)

    func spawnSparks(at point: CGPoint, color: SKColor, count: Int = 14) {
        for _ in 0..<count {
            let angle = CGFloat.random(in: 0...(2 * .pi))
            let speed = CGFloat.random(in: 40...220)
            let s = CGFloat.random(in: 2...4)
            let node = SKShapeNode(circleOfRadius: s)
            node.fillColor = color
            node.strokeColor = .clear
            node.glowWidth = 2
            node.position = point
            sparksContainer.addChild(node)
            sparks.append(Spark(x: point.x, y: point.y, vx: cos(angle) * speed, vy: sin(angle) * speed, maxLife: CGFloat.random(in: 0.25...0.5), node: node))
        }
    }

    func updateSparks(dt: CGFloat) {
        for i in sparks.indices.reversed() {
            sparks[i].life += dt
            sparks[i].x += sparks[i].vx * dt
            sparks[i].y += sparks[i].vy * dt
            sparks[i].vx *= 0.9
            sparks[i].vy *= 0.9
            if let node = sparks[i].node {
                node.position = CGPoint(x: sparks[i].x, y: sparks[i].y)
                node.alpha = max(0, 1 - sparks[i].life / sparks[i].maxLife)
            }
            if sparks[i].life >= sparks[i].maxLife {
                sparks[i].node?.removeFromParent()
                sparks.remove(at: i)
            }
        }
    }
}
