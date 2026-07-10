import SpriteKit

let baseLaunchSpeed: CGFloat = 260

/// CPU opponent behavior: launch aim/power tuned by difficulty, plus
/// periodic boost usage that leans harder when the CPU is behind on stamina.
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
        cpuBoostTimer = CGFloat.random(in: cfg.boostCheckInterval)
    }

    func updateCPUAI(dt: CGFloat) {
        guard cpu.isAlive, cpu.launched else { return }
        cpuBoostTimer -= dt
        guard cpuBoostTimer <= 0 else { return }
        let cfg = GameConfig.difficulties[difficulty]!
        cpuBoostTimer = CGFloat.random(in: cfg.boostCheckInterval)

        let behind = cpu.stamina < player.stamina - 8
        var chance = cfg.boostChance
        if behind { chance *= 1.7 }
        guard CGFloat.random(in: 0...1) < chance else { return }
        if cpu.applyBoost() {
            cpuNode.playBoostPulse()
            SoundEngine.shared.playBoost()
        }
    }
}
