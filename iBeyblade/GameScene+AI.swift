import SpriteKit

let baseLaunchSpeed: CGFloat = 260

/// CPU opponent behavior: launch aim/power tuned by difficulty, plus
/// periodic Special Move usage that leans harder when the CPU is behind.
/// Not called at all in local 2P — Player 2 controls the "cpu" slot directly.
extension GameScene {

    func launchCPUTop() {
        let cfg = GameConfig.difficulties[difficulty]!
        let origin = cpuLaunchOrigin
        let toCenter = CGVector(dx: arenaCenter.x - origin.x, dy: arenaCenter.y - origin.y)
        let baseAngle = atan2(toCenter.dy, toCenter.dx)
        let angle = baseAngle + CGFloat.random(in: -cfg.aimVariance...cfg.aimVariance)
        let power = CGFloat.random(in: cfg.powerMin...cfg.powerMax)
        let direction = CGVector(dx: cos(angle) * baseLaunchSpeed, dy: sin(angle) * baseLaunchSpeed)
        cpu.launch(from: origin, direction: direction, power: power)
        cpuNode.playLaunchPulse()
        cpuSpecialTimer = CGFloat.random(in: cfg.specialCheckInterval)
    }

    func updateCPUAI(dt: CGFloat) {
        guard cpu.isAlive, cpu.launched else { return }
        cpuSpecialTimer -= dt
        guard cpuSpecialTimer <= 0 else { return }
        let cfg = GameConfig.difficulties[difficulty]!
        cpuSpecialTimer = CGFloat.random(in: cfg.specialCheckInterval)

        guard cpu.specialGauge >= 100 else { return }
        let behind = cpu.stamina < player.stamina - 8
        var chance = cfg.specialUseChance
        if behind { chance = min(1, chance * 1.4) }
        guard CGFloat.random(in: 0...1) < chance else { return }
        fireSpecialMove(for: cpu, node: cpuNode)
    }
}
