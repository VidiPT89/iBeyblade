import SpriteKit

/// Battle simulation: autonomous top movement, wall/top collision
/// resolution, and spin-out / ring-out / burst detection.
extension GameScene {

    func tick(dt: CGFloat, time: CGFloat) {
        guard phase == .battle, !gamePaused else { return }
        if let remaining = pendingRoundEnd {
            let next = remaining - dt
            if next <= 0 {
                pendingRoundEnd = nil
                concludeRound()
                return
            }
            pendingRoundEnd = next
        }

        player.step(dt: dt, opponent: cpu, arenaCenter: arenaCenter, time: time)
        cpu.step(dt: dt, opponent: player, arenaCenter: arenaCenter, time: time)

        if collisionCooldown > 0 { collisionCooldown -= dt }
        resolveWallCollision(player)
        resolveWallCollision(cpu)
        resolveTopCollision()
        updateCPUAI(dt: dt)
    }

    private func resolveWallCollision(_ e: BeybladeEntity) {
        guard e.launched, e.isAlive else { return }
        let dx = e.position.x - arenaCenter.x
        let dy = e.position.y - arenaCenter.y
        let dist = hypot(dx, dy)
        let limit = arenaRadius - e.preset.radius
        guard dist > limit, dist > 0.001 else { return }

        let nx = dx / dist
        let ny = dy / dist
        let outwardSpeed = e.velocity.dx * nx + e.velocity.dy * ny

        if e.stamina < 14 || outwardSpeed > 130 {
            triggerKO(e, reason: .ringOut)
            return
        }

        let restitution: CGFloat = 0.6
        let vDotN = e.velocity.dx * nx + e.velocity.dy * ny
        e.velocity.dx -= (1 + restitution) * vDotN * nx
        e.velocity.dy -= (1 + restitution) * vDotN * ny
        e.position.x = arenaCenter.x + nx * limit
        e.position.y = arenaCenter.y + ny * limit
        e.stamina = max(0, e.stamina - 1.5)

        spawnSparks(at: e.position, color: SKColor(hex: e.preset.glowHex), count: 5)
        SoundEngine.shared.playClash(intensity: 0.12)
        Haptics.impact(0.15)
    }

    private func resolveTopCollision() {
        guard player.launched, cpu.launched, player.isAlive, cpu.isAlive else { return }
        let dx = cpu.position.x - player.position.x
        let dy = cpu.position.y - player.position.y
        let dist = max(0.01, hypot(dx, dy))
        let minDist = player.preset.radius + cpu.preset.radius
        guard dist < minDist else { return }

        let nx = dx / dist
        let ny = dy / dist
        let overlap = minDist - dist
        // Always separate overlapping bodies so they don't visually stick,
        // even while a hit's cooldown is still active.
        player.position.x -= nx * overlap / 2
        player.position.y -= ny * overlap / 2
        cpu.position.x += nx * overlap / 2
        cpu.position.y += ny * overlap / 2

        guard collisionCooldown <= 0 else { return }
        collisionCooldown = 0.35

        let rvx = cpu.velocity.dx - player.velocity.dx
        let rvy = cpu.velocity.dy - player.velocity.dy
        let approach = max(0, -(rvx * nx + rvy * ny))
        let spinBonus = (player.spinSpeed + cpu.spinSpeed) * 1.4
        let impactSpeed = max(40, approach) + spinBonus
        let sameDirection = player.preset.spin == cpu.preset.spin
        let dirMultiplier: CGFloat = sameDirection ? 0.75 : 1.3
        let hitPower = impactSpeed * dirMultiplier

        // Knockback is an outright velocity kick (not a scaled "force"), so a
        // single clash produces a visible bounce-apart instead of a tiny nudge.
        let knockOnPlayer = hitPower * (cpu.preset.attack / (player.preset.defense + 0.2)) * 0.6
        let knockOnCPU = hitPower * (player.preset.attack / (cpu.preset.defense + 0.2)) * 0.6

        player.velocity.dx -= nx * knockOnPlayer
        player.velocity.dy -= ny * knockOnPlayer
        cpu.velocity.dx += nx * knockOnCPU
        cpu.velocity.dy += ny * knockOnCPU

        let tx = -ny, ty = nx
        let jitter = CGFloat.random(in: -20...20)
        player.velocity.dx += tx * jitter
        player.velocity.dy += ty * jitter
        cpu.velocity.dx -= tx * jitter
        cpu.velocity.dy -= ty * jitter

        // Stamina loss scales with the same knockback the top actually took,
        // so a single hit costs a sensible chunk instead of draining instantly.
        player.stamina = max(0, player.stamina - knockOnPlayer * 0.12)
        cpu.stamina = max(0, cpu.stamina - knockOnCPU * 0.12)

        let midpoint = CGPoint(x: (player.position.x + cpu.position.x) / 2, y: (player.position.y + cpu.position.y) / 2)
        let clashIntensity = min(1, hitPower / 260)
        spawnSparks(at: midpoint, color: .white, count: 16)
        SoundEngine.shared.playClash(intensity: clashIntensity)
        Haptics.impact(clashIntensity)

        let burstThreshold: CGFloat = 340
        if hitPower > burstThreshold {
            if player.stamina <= cpu.stamina, player.stamina < 35 {
                triggerKO(player, reason: .burst)
            } else if cpu.stamina < player.stamina, cpu.stamina < 35 {
                triggerKO(cpu, reason: .burst)
            }
        }

        if player.stamina <= 0, player.isAlive { triggerKO(player, reason: .spinOut) }
        if cpu.stamina <= 0, cpu.isAlive { triggerKO(cpu, reason: .spinOut) }
    }

    private func triggerKO(_ e: BeybladeEntity, reason: KOReason) {
        guard e.isAlive else { return }
        e.isAlive = false
        e.koReason = reason
        let node = e === player ? playerNode! : cpuNode!
        node.playKOAnimation(reason: reason)

        switch reason {
        case .spinOut: SoundEngine.shared.playSpinOut()
        case .ringOut: SoundEngine.shared.playRingOut()
        case .burst: SoundEngine.shared.playBurst()
        }
        Haptics.warning()

        lastRoundLoser = e
        lastRoundReason = reason
        if pendingRoundEnd == nil { pendingRoundEnd = 0.9 }
    }

    func concludeRound() {
        let winner: BeybladeEntity?
        if player.isAlive, !cpu.isAlive { winner = player }
        else if cpu.isAlive, !player.isAlive { winner = cpu }
        else { winner = nil }

        if winner === player { playerWins += 1 }
        else if winner === cpu { cpuWins += 1 }

        if playerWins >= GameConfig.winsNeeded || cpuWins >= GameConfig.winsNeeded {
            phase = .matchOver
            if playerWins > cpuWins { SoundEngine.shared.playMatchWin() } else { SoundEngine.shared.playRoundLose() }
            showMatchOverOverlay()
        } else {
            phase = .roundResult
            if winner === player { SoundEngine.shared.playRoundWin() } else { SoundEngine.shared.playRoundLose() }
            showRoundResultOverlay(winner: winner)
        }
    }
}
