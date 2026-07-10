import CoreGraphics

enum KOReason {
    case spinOut, ringOut, burst
}

/// A launched spinning top. Physics runs autonomously frame-to-frame — the
/// player only sets the initial launch vector and can spend boost charges —
/// matching how a real spinning top behaves once it leaves your hand.
final class BeybladeEntity {
    let preset: TopPreset
    let isPlayer: Bool

    var position: CGPoint = .zero
    var velocity: CGVector = .zero
    var spinAngle: CGFloat = 0
    /// rad/sec magnitude of the visual spin (always positive; direction from preset.spin)
    var spinSpeed: CGFloat = 0
    /// 0...100 remaining spin energy
    var stamina: CGFloat = 100
    var boostCharges: Int = 3
    var isAlive: Bool = true
    var launched: Bool = false
    var koReason: KOReason?
    /// 0...1, rises as stamina runs low — drives the wobble/topple visuals
    var wobble: CGFloat = 0
    private var seed: CGFloat

    init(preset: TopPreset, isPlayer: Bool) {
        self.preset = preset
        self.isPlayer = isPlayer
        self.seed = CGFloat.random(in: 0..<1000)
    }

    func launch(from origin: CGPoint, direction: CGVector, power: CGFloat) {
        position = origin
        let clamped = max(0.25, min(1, power))
        velocity = CGVector(dx: direction.dx * clamped, dy: direction.dy * clamped)
        spinSpeed = 14 + clamped * 6
        stamina = 100
        boostCharges = 3
        isAlive = true
        launched = true
        koReason = nil
        wobble = 0
    }

    func applyBoost() -> Bool {
        guard isAlive, boostCharges > 0, stamina > 6 else { return false }
        boostCharges -= 1
        stamina = max(0, stamina - 6)
        let speed = hypot(velocity.dx, velocity.dy)
        let dir: CGVector
        if speed > 0.01 {
            dir = CGVector(dx: velocity.dx / speed, dy: velocity.dy / speed)
        } else {
            let a = CGFloat.random(in: 0..<(2 * .pi))
            dir = CGVector(dx: cos(a), dy: sin(a))
        }
        velocity.dx += dir.dx * 90
        velocity.dy += dir.dy * 90
        spinSpeed += 4
        return true
    }

    /// Autonomous per-frame steering + spin decay. Called before wall/top
    /// collision resolution each simulation step.
    func step(dt: CGFloat, opponent: BeybladeEntity, arenaCenter: CGPoint, time: CGFloat) {
        guard launched, isAlive else { return }

        let decayRate: CGFloat = 5.2 * (1.05 - preset.stamina)
        stamina = max(0, stamina - decayRate * dt)
        wobble = min(1, max(0, 1 - stamina / 22))

        let staminaFrac = stamina / 100
        spinSpeed = (10 + 6 * preset.stamina) * max(0.08, staminaFrac)

        // Blend a light homing pull toward the opponent with organic jitter;
        // more aggressive types chase harder, weakened tops wander erratically.
        let toOpponent = CGVector(dx: opponent.position.x - position.x, dy: opponent.position.y - position.y)
        let toOppLen = max(0.001, hypot(toOpponent.dx, toOpponent.dy))
        let homing = CGVector(dx: toOpponent.dx / toOppLen, dy: toOpponent.dy / toOppLen)

        let jitterAngle = sin(time * 3.1 + seed) * .pi * (0.6 + wobble * 1.4)
        let jitter = CGVector(dx: cos(jitterAngle), dy: sin(jitterAngle))

        let pull = preset.aggression * 0.55
        let steer = CGVector(
            dx: homing.dx * pull + jitter.dx * (1 - pull),
            dy: homing.dy * pull + jitter.dy * (1 - pull)
        )

        let targetSpeed: CGFloat = (70 + 90 * staminaFrac) * (0.6 + preset.aggression * 0.4)
        velocity.dx += steer.dx * targetSpeed * 0.9 * dt
        velocity.dy += steer.dy * targetSpeed * 0.9 * dt

        let speed = hypot(velocity.dx, velocity.dy)
        let maxSpeed: CGFloat = 260
        if speed > maxSpeed {
            velocity.dx = velocity.dx / speed * maxSpeed
            velocity.dy = velocity.dy / speed * maxSpeed
        }

        let damping: CGFloat = 0.985
        velocity.dx *= damping
        velocity.dy *= damping

        position.x += velocity.dx * dt
        position.y += velocity.dy * dt

        let spinDir: CGFloat = preset.spin == .cw ? -1 : 1
        spinAngle += spinDir * spinSpeed * dt

        if stamina <= 0 {
            isAlive = false
            koReason = .spinOut
        }
    }
}
