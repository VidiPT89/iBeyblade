import CoreGraphics

enum KOReason {
    case spinOut, ringOut, burst
}

/// A launched spinning top. Physics runs autonomously frame-to-frame — the
/// player only sets the initial launch vector and can unleash a Special Move
/// once its gauge fills — matching how a real spinning top behaves once it
/// leaves your hand.
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
    /// 0...100 — fills passively while spinning and in bursts on hits; a
    /// Special Move can fire once it reaches 100.
    var specialGauge: CGFloat = 0
    /// >0 while a Special Move's temporary attack/defense buff is active
    var specialActiveTimer: CGFloat = 0
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

    var specialActive: Bool { specialActiveTimer > 0 }
    /// Effective Attack/Defense, boosted while a Special Move is active.
    var effectiveAttack: CGFloat { preset.attack * (specialActive ? 1.4 : 1.0) }
    var effectiveDefense: CGFloat { preset.defense * (specialActive ? 1.3 : 1.0) }

    func launch(from origin: CGPoint, direction: CGVector, power: CGFloat) {
        position = origin
        let clamped = max(0.25, min(1, power))
        velocity = CGVector(dx: direction.dx * clamped, dy: direction.dy * clamped)
        spinSpeed = 14 + clamped * 6
        stamina = 100
        specialGauge = 0
        specialActiveTimer = 0
        isAlive = true
        launched = true
        koReason = nil
        wobble = 0
    }

    func gainSpecialGauge(_ amount: CGFloat) {
        guard isAlive else { return }
        specialGauge = min(100, specialGauge + amount)
    }

    /// Consumes a full gauge and unleashes the top's spirit: a speed kick
    /// plus a temporary Attack/Defense buff, matching Beyblade Burst's
    /// Special Moves.
    func triggerSpecial() -> Bool {
        guard isAlive, specialGauge >= 100 else { return false }
        specialGauge = 0
        specialActiveTimer = 2.5
        let speed = hypot(velocity.dx, velocity.dy)
        let dir: CGVector
        if speed > 0.01 {
            dir = CGVector(dx: velocity.dx / speed, dy: velocity.dy / speed)
        } else {
            let a = CGFloat.random(in: 0..<(2 * .pi))
            dir = CGVector(dx: cos(a), dy: sin(a))
        }
        velocity.dx += dir.dx * 110
        velocity.dy += dir.dy * 110
        spinSpeed += 5
        return true
    }

    /// Autonomous per-frame steering + spin decay. Called before wall/top
    /// collision resolution each simulation step. `decayMultiplier` ramps up
    /// during Sudden Death so every round is guaranteed to end.
    func step(dt: CGFloat, opponent: BeybladeEntity, arenaCenter: CGPoint, arenaRadius: CGFloat, time: CGFloat, decayMultiplier: CGFloat = 1) {
        guard launched, isAlive else { return }

        let decayRate: CGFloat = 5.2 * (1.05 - preset.stamina) * decayMultiplier
        stamina = max(0, stamina - decayRate * dt)
        wobble = min(1, max(0, 1 - stamina / 22))

        if specialActiveTimer > 0 { specialActiveTimer = max(0, specialActiveTimer - dt) }
        gainSpecialGauge(3.2 * dt)

        let staminaFrac = stamina / 100
        spinSpeed = (10 + 6 * preset.stamina) * max(0.08, staminaFrac)

        // Blend a light homing pull toward the opponent with organic jitter;
        // more aggressive types chase harder, weakened tops wander erratically.
        // At close range the pull fades out (and gently reverses) so two tops
        // can't settle into a glued equilibrium that never resolves.
        let toOpponent = CGVector(dx: opponent.position.x - position.x, dy: opponent.position.y - position.y)
        let toOppLen = max(0.001, hypot(toOpponent.dx, toOpponent.dy))
        let contactDist = preset.radius + opponent.preset.radius
        let closeRangeFade = min(1, max(0, (toOppLen - contactDist * 1.1) / (contactDist * 0.5)))
        let homing = CGVector(dx: toOpponent.dx / toOppLen * closeRangeFade, dy: toOpponent.dy / toOppLen * closeRangeFade)

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

        // Real stadiums dish down toward the middle, so a top's own weight
        // drags it back toward the center — barely noticeable near the
        // middle, strong enough near the rim to matter, exactly like riding
        // the slope of a real Beyblade arena.
        let toCenter = CGVector(dx: arenaCenter.x - position.x, dy: arenaCenter.y - position.y)
        let distFromCenter = hypot(toCenter.dx, toCenter.dy)
        if distFromCenter > 0.001, arenaRadius > 0 {
            let slopeT = min(1, distFromCenter / arenaRadius)
            let slopePull: CGFloat = 46 * slopeT * slopeT
            velocity.dx += (toCenter.dx / distFromCenter) * slopePull * dt
            velocity.dy += (toCenter.dy / distFromCenter) * slopePull * dt
        }

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

        // Stamina hitting zero here only marks the top as spent — GameScene's
        // tick() is what actually calls triggerKO() and concludes the round,
        // so every KO path (collision or natural decay) goes through the
        // same code that plays the animation and unblocks the match.
    }
}
