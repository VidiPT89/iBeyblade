import SpriteKit
#if canImport(UIKit)
import UIKit
#endif

extension GameScene {

    // MARK: Launch origins

    var playerLaunchOrigin: CGPoint {
        CGPoint(x: arenaCenter.x, y: arenaCenter.y - arenaRadius * 0.62)
    }

    var cpuLaunchOrigin: CGPoint {
        CGPoint(x: arenaCenter.x, y: arenaCenter.y + arenaRadius * 0.62)
    }

    // MARK: HUD

    func buildHUD() {
        hud.playerStaminaBg.fillColor = SKColor(white: 1, alpha: 0.08)
        hud.playerStaminaBg.strokeColor = .clear
        hud.playerStaminaFill.fillColor = SKColor(hex: "#3ca0ff")
        hud.playerStaminaFill.strokeColor = .clear
        hud.playerNameLabel.fontSize = 12
        hud.playerNameLabel.fontColor = .white
        hud.playerNameLabel.horizontalAlignmentMode = .left

        hud.cpuStaminaBg.fillColor = SKColor(white: 1, alpha: 0.08)
        hud.cpuStaminaBg.strokeColor = .clear
        hud.cpuStaminaFill.fillColor = SKColor(hex: "#ff5a3c")
        hud.cpuStaminaFill.strokeColor = .clear
        hud.cpuNameLabel.fontSize = 12
        hud.cpuNameLabel.fontColor = .white
        hud.cpuNameLabel.horizontalAlignmentMode = .right

        hud.roundLabel.fontSize = 13
        hud.roundLabel.fontColor = SKColor(hex: "#ffd27a")
        hud.roundLabel.horizontalAlignmentMode = .center

        hud.boostButton.fillColor = SKColor(white: 1, alpha: 0.1)
        hud.boostButton.strokeColor = SKColor(hex: "#7fa8ff")
        hud.boostButton.lineWidth = 2
        hud.boostButton.glowWidth = 3
        hud.boostLabel.fontSize = 12
        hud.boostLabel.fontColor = .white
        hud.boostLabel.verticalAlignmentMode = .center
        hud.boostLabel.horizontalAlignmentMode = .center
        hud.boostChargesLabel.fontSize = 10
        hud.boostChargesLabel.fontColor = SKColor(white: 1, alpha: 0.7)
        hud.boostChargesLabel.verticalAlignmentMode = .center
        hud.boostChargesLabel.horizontalAlignmentMode = .center

        hud.langButton.fontSize = 16
        hud.langButton.fontColor = .white
        hud.langButton.verticalAlignmentMode = .center
        hud.langHit.fillColor = .clear
        hud.langHit.strokeColor = .clear

        hud.pauseButton.fillColor = SKColor(white: 1, alpha: 0.08)
        hud.pauseButton.strokeColor = SKColor(hex: "#4d78ff")
        hud.pauseLabel.fontSize = 14
        hud.pauseLabel.fontColor = .white
        hud.pauseLabel.verticalAlignmentMode = .center
        hud.pauseLabel.horizontalAlignmentMode = .center
        hud.pauseLabel.text = "II"

        for n in [hud.playerStaminaBg, hud.playerStaminaFill, hud.playerNameLabel,
                  hud.cpuStaminaBg, hud.cpuStaminaFill, hud.cpuNameLabel,
                  hud.roundLabel, hud.boostButton, hud.boostLabel, hud.boostChargesLabel,
                  hud.langButton, hud.langHit, hud.pauseButton, hud.pauseLabel] {
            hud.container.addChild(n)
        }
        addChild(hud.container)

        buttons.append(UIButton(node: hud.langHit, id: "btn-lang"))
        buttons.append(UIButton(node: hud.pauseButton, id: "btn-pause"))
        buttons.append(UIButton(node: hud.pauseLabel, id: "btn-pause"))
        buttons.append(UIButton(node: hud.boostButton, id: "btn-boost"))
        buttons.append(UIButton(node: hud.boostLabel, id: "btn-boost"))
    }

    func layoutHUD(size: CGSize) {
        let topY = size.height - topSafeInset - 26
        hud.playerNameLabel.position = CGPoint(x: 18, y: topY)
        hud.playerStaminaBg.position = CGPoint(x: 18 + 65, y: topY - 18)
        hud.playerStaminaFill.position = hud.playerStaminaBg.position

        hud.cpuNameLabel.position = CGPoint(x: size.width - 18, y: topY)
        hud.cpuStaminaBg.position = CGPoint(x: size.width - 18 - 65, y: topY - 18)
        hud.cpuStaminaFill.position = hud.cpuStaminaBg.position

        hud.roundLabel.position = CGPoint(x: size.width / 2, y: topY - 4)

        hud.langButton.position = CGPoint(x: size.width / 2 - 60, y: size.height - topSafeInset - 60)
        hud.langHit.position = hud.langButton.position
        hud.pauseButton.position = CGPoint(x: size.width / 2 + 60, y: size.height - topSafeInset - 60)
        hud.pauseLabel.position = hud.pauseButton.position

        hud.boostButton.position = CGPoint(x: size.width - 60, y: 60 + bottomSafeInset)
        hud.boostLabel.position = CGPoint(x: hud.boostButton.position.x, y: hud.boostButton.position.y + 6)
        hud.boostChargesLabel.position = CGPoint(x: hud.boostButton.position.x, y: hud.boostButton.position.y - 12)
    }

    func updateHUDBars() {
        let show = phase == .launch || phase == .battle || phase == .roundResult
        hud.container.isHidden = !show
        guard show, player != nil, cpu != nil else { return }

        let pFrac = max(0, min(1, player.stamina / 100))
        let cFrac = max(0, min(1, cpu.stamina / 100))
        hud.playerStaminaFill.xScale = max(0.001, pFrac)
        hud.cpuStaminaFill.xScale = max(0.001, cFrac)
        hud.playerStaminaFill.position.x = hud.playerStaminaBg.position.x - (130 * (1 - pFrac)) / 2
        hud.cpuStaminaFill.position.x = hud.cpuStaminaBg.position.x + (130 * (1 - cFrac)) / 2

        hud.boostChargesLabel.text = "x\(player.boostCharges)"
        hud.boostButton.alpha = (player.boostCharges > 0 && player.isAlive && phase == .battle) ? 1 : 0.35
        hud.pauseButton.isHidden = phase != .battle && phase != .launch
        hud.pauseLabel.isHidden = hud.pauseButton.isHidden
    }

    // MARK: Menu

    func buildMenu() {
        let overlay = SKNode()
        overlay.zPosition = 100
        let bg = SKShapeNode()
        bg.fillColor = SKColor(hex: "#05060f")
        bg.strokeColor = .clear
        overlay.addChild(bg)

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.fontSize = 30
        title.fontColor = SKColor(hex: "#ffd27a")
        overlay.addChild(title)
        menuTitleLabel = title

        let tagline = SKLabelNode(fontNamed: "Menlo")
        tagline.fontSize = 13
        tagline.fontColor = SKColor(white: 1, alpha: 0.7)
        tagline.numberOfLines = 2
        tagline.preferredMaxLayoutWidth = 300
        overlay.addChild(tagline)
        menuTaglineLabel = tagline

        for diff in Difficulty.allCases {
            let bgBtn = SKShapeNode(rectOf: CGSize(width: 90, height: 34), cornerRadius: 8)
            bgBtn.strokeColor = SKColor(hex: "#4d78ff")
            bgBtn.lineWidth = 1.5
            let label = SKLabelNode(fontNamed: "Menlo-Bold")
            label.fontSize = 13
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.fontColor = .white
            overlay.addChild(bgBtn)
            overlay.addChild(label)
            diffButtons[diff] = (bgBtn, label)
            buttons.append(UIButton(node: bgBtn, id: "diff-\(diff.rawValue)"))
        }

        for (i, preset) in BeybladePresets.all.enumerated() {
            let card = SKShapeNode(rectOf: CGSize(width: 148, height: 88), cornerRadius: 10)
            card.strokeColor = SKColor(hex: preset.glowHex)
            card.lineWidth = 1.5
            let name = SKLabelNode(fontNamed: "Menlo-Bold")
            name.fontSize = 12
            name.fontColor = .white
            name.horizontalAlignmentMode = .center
            let type = SKLabelNode(fontNamed: "Menlo")
            type.fontSize = 10
            type.fontColor = SKColor(hex: preset.glowHex)
            type.horizontalAlignmentMode = .center
            let stats = SKNode()
            overlay.addChild(card)
            overlay.addChild(name)
            overlay.addChild(type)
            overlay.addChild(stats)
            topCards.append((card, name, type, stats))
            buttons.append(UIButton(node: card, id: "top-\(i)"))
        }

        let start = SKShapeNode(rectOf: CGSize(width: 220, height: 50), cornerRadius: 12)
        start.fillColor = SKColor(hex: "#ffd27a")
        start.strokeColor = .clear
        overlay.addChild(start)
        let startL = SKLabelNode(fontNamed: "Menlo-Bold")
        startL.fontSize = 15
        startL.fontColor = SKColor(hex: "#05060f")
        startL.verticalAlignmentMode = .center
        startL.horizontalAlignmentMode = .center
        overlay.addChild(startL)
        startLabel = startL
        buttons.append(UIButton(node: start, id: "start-tap"))

        addChild(overlay)
        menuOverlay = overlay
    }

    func layoutMenu(size: CGSize) {
        guard let overlay = menuOverlay, let bg = overlay.children.first as? SKShapeNode else { return }
        bg.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        let cx = size.width / 2
        var y = size.height - topSafeInset - 70
        menuTitleLabel?.position = CGPoint(x: cx, y: y)
        y -= 42
        menuTaglineLabel?.position = CGPoint(x: cx, y: y)
        y -= 56

        let diffs = Difficulty.allCases
        let diffSpacing: CGFloat = 96
        let diffStartX = cx - diffSpacing * CGFloat(diffs.count - 1) / 2
        for (i, diff) in diffs.enumerated() {
            guard let pair = diffButtons[diff] else { continue }
            let x = diffStartX + CGFloat(i) * diffSpacing
            pair.bg.position = CGPoint(x: x, y: y)
            pair.label.position = CGPoint(x: x, y: y)
        }
        y -= 66

        let cols = 2
        let cardW: CGFloat = 156
        let cardH: CGFloat = 96
        let startX = cx - cardW * CGFloat(cols - 1) / 2
        for (i, card) in topCards.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * cardW
            let cardY = y - CGFloat(row) * cardH
            card.bg.position = CGPoint(x: x, y: cardY)
            card.name.position = CGPoint(x: x, y: cardY + 16)
            card.type.position = CGPoint(x: x, y: cardY)
            layoutStatBars(card.stats, preset: BeybladePresets.all[i], center: CGPoint(x: x, y: cardY - 19))
        }
        y -= cardH * 1.9

        guard let start = buttons.first(where: { $0.id == "start-tap" })?.node else { return }
        start.position = CGPoint(x: cx, y: max(50 + bottomSafeInset, y))
        startLabel?.position = start.position
    }

    private func layoutStatBars(_ container: SKNode, preset: TopPreset, center: CGPoint) {
        container.removeAllChildren()
        let stats: [(String, CGFloat, SKColor)] = [
            (L.t("statAtk"), preset.attack, SKColor(hex: "#ff5a3c")),
            (L.t("statDef"), preset.defense, SKColor(hex: "#3ca0ff")),
            (L.t("statStm"), preset.stamina, SKColor(hex: "#3cffb0")),
        ]
        for (i, stat) in stats.enumerated() {
            let y = center.y - CGFloat(i) * 10
            let label = SKLabelNode(fontNamed: "Menlo")
            label.text = stat.0
            label.fontSize = 8
            label.fontColor = SKColor(white: 1, alpha: 0.7)
            label.horizontalAlignmentMode = .left
            label.verticalAlignmentMode = .center
            label.position = CGPoint(x: center.x - 62, y: y)
            container.addChild(label)

            let barBg = SKShapeNode(rectOf: CGSize(width: 60, height: 5), cornerRadius: 2.5)
            barBg.fillColor = SKColor(white: 1, alpha: 0.1)
            barBg.strokeColor = .clear
            barBg.position = CGPoint(x: center.x + 10, y: y)
            container.addChild(barBg)

            let barFill = SKShapeNode(rectOf: CGSize(width: max(2, 60 * stat.1), height: 5), cornerRadius: 2.5)
            barFill.fillColor = stat.2
            barFill.strokeColor = .clear
            barFill.position = CGPoint(x: center.x + 10 - (60 * (1 - stat.1)) / 2, y: y)
            container.addChild(barFill)
        }
    }

    func showMenu() {
        phase = .menu
        gamePaused = false
        menuOverlay?.isHidden = false
        launchOverlay?.isHidden = true
        pauseOverlay?.isHidden = true
        roundResultOverlay?.isHidden = true
        matchOverOverlay?.isHidden = true
        refreshMenuSelection()
    }

    private func refreshMenuSelection() {
        for (diff, pair) in diffButtons {
            let selected = diff == difficulty
            pair.bg.fillColor = selected ? SKColor(hex: "#4d78ff").withAlphaComponent(0.35) : SKColor(white: 1, alpha: 0.05)
        }
        for (i, card) in topCards.enumerated() {
            let selected = i == playerPresetIndex
            card.bg.fillColor = selected ? SKColor(hex: BeybladePresets.all[i].glowHex).withAlphaComponent(0.22) : SKColor(white: 1, alpha: 0.04)
            card.bg.lineWidth = selected ? 3 : 1.5
        }
    }

    // MARK: Launch overlay (pull-back gesture)

    func buildLaunchOverlay() {
        let overlay = SKNode()
        overlay.zPosition = 40

        let hint = SKLabelNode(fontNamed: "Menlo")
        hint.fontSize = 13
        hint.fontColor = SKColor(white: 1, alpha: 0.75)
        overlay.addChild(hint)
        pullHintLabel = hint

        let indicator = SKShapeNode()
        indicator.strokeColor = SKColor(hex: "#ffd27a")
        indicator.lineWidth = 3
        indicator.glowWidth = 3
        indicator.isHidden = true
        overlay.addChild(indicator)
        pullIndicator = indicator

        addChild(overlay)
        launchOverlay = overlay
    }

    func layoutLaunchOverlay(size: CGSize) {
        pullHintLabel?.position = CGPoint(x: size.width / 2, y: bottomSafeInset + 90)
    }

    func prepareNewMatch() {
        playerWins = 0
        cpuWins = 0
        roundNumber = 1
        var options = Array(BeybladePresets.all.indices)
        options.removeAll { $0 == playerPresetIndex }
        cpuPresetIndex = options.randomElement() ?? ((playerPresetIndex + 1) % BeybladePresets.all.count)
        rebuildEntities()
        startRound()
    }

    func startRound() {
        phase = .launch
        gamePaused = false
        collisionCooldown = 0
        pendingRoundEnd = nil
        menuOverlay?.isHidden = true
        pauseOverlay?.isHidden = true
        roundResultOverlay?.isHidden = true
        matchOverOverlay?.isHidden = true
        launchOverlay?.isHidden = false

        player.position = playerLaunchOrigin
        player.velocity = .zero
        player.stamina = 100
        player.spinSpeed = 0
        player.boostCharges = 3
        player.isAlive = true
        player.launched = false
        player.koReason = nil
        player.wobble = 0

        cpu.position = cpuLaunchOrigin
        cpu.velocity = .zero
        cpu.stamina = 100
        cpu.spinSpeed = 0
        cpu.isAlive = true
        cpu.launched = false
        cpu.koReason = nil
        cpu.wobble = 0

        playerNode.resetForNewRound()
        cpuNode.resetForNewRound()
        hud.roundLabel.text = "\(L.t("round")) \(roundNumber) — \(playerWins):\(cpuWins)"
    }

    private func launchPlayer(direction: CGVector, power: CGFloat) {
        player.launch(from: playerLaunchOrigin, direction: direction, power: power)
        playerNode.playLaunchPulse()
        SoundEngine.shared.playLaunch()
        Haptics.impact(0.4)
        launchOverlay?.isHidden = true
        launchCPUTop()
        phase = .battle
    }

    private func updatePullIndicator() {
        guard let indicator = pullIndicator else { return }
        indicator.isHidden = false
        let path = CGMutablePath()
        path.move(to: launchAnchor)
        path.addLine(to: dragCurrent)
        indicator.path = path
    }

    private func hidePullIndicator() {
        pullIndicator?.isHidden = true
        isDragging = false
    }

    // MARK: Pause overlay

    func buildPauseOverlay() {
        let overlay = SKNode()
        overlay.zPosition = 150
        overlay.isHidden = true
        let bg = SKShapeNode()
        bg.fillColor = SKColor(white: 0, alpha: 0.7)
        bg.strokeColor = .clear
        overlay.addChild(bg)
        buttons.append(UIButton(node: bg, id: "pause-tap"))

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.fontSize = 24
        title.fontColor = .white
        overlay.addChild(title)
        let sub = SKLabelNode(fontNamed: "Menlo")
        sub.fontSize = 13
        sub.fontColor = SKColor(white: 1, alpha: 0.7)
        overlay.addChild(sub)

        addChild(overlay)
        pauseOverlay = overlay
        pauseTitle = title
        pauseSub = sub
    }

    func layoutPauseOverlay(size: CGSize) {
        guard let overlay = pauseOverlay, let bg = overlay.children.first as? SKShapeNode else { return }
        bg.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        pauseTitle?.position = CGPoint(x: size.width / 2, y: size.height / 2 + 16)
        pauseSub?.position = CGPoint(x: size.width / 2, y: size.height / 2 - 12)
    }

    // MARK: Round result overlay

    func buildRoundResultOverlay() {
        let overlay = SKNode()
        overlay.zPosition = 120
        overlay.isHidden = true
        let bg = SKShapeNode()
        bg.fillColor = SKColor(white: 0, alpha: 0.72)
        bg.strokeColor = .clear
        overlay.addChild(bg)
        buttons.append(UIButton(node: bg, id: "round-continue"))

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.fontSize = 24
        title.fontColor = SKColor(hex: "#ffd27a")
        overlay.addChild(title)
        roundResultTitle = title

        let sub = SKLabelNode(fontNamed: "Menlo")
        sub.fontSize = 13
        sub.fontColor = SKColor(white: 1, alpha: 0.75)
        overlay.addChild(sub)
        roundResultSub = sub

        addChild(overlay)
        roundResultOverlay = overlay
    }

    func layoutRoundResultOverlay(size: CGSize) {
        guard let overlay = roundResultOverlay, let bg = overlay.children.first as? SKShapeNode else { return }
        bg.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        roundResultTitle?.position = CGPoint(x: size.width / 2, y: size.height / 2 + 16)
        roundResultSub?.position = CGPoint(x: size.width / 2, y: size.height / 2 - 14)
    }

    func showRoundResultOverlay(winner: BeybladeEntity?) {
        roundResultOverlay?.isHidden = false
        let text: String
        if winner === player { text = L.t("youWinRound") }
        else if winner === cpu { text = L.t("cpuWinRound") }
        else { text = L.t("youWinRound") }
        roundResultTitle?.text = text
        roundResultSub?.text = "\(playerWins) : \(cpuWins)   ·   \(L.t("tapToContinue"))"
    }

    // MARK: Match over overlay

    func buildMatchOverOverlay() {
        let overlay = SKNode()
        overlay.zPosition = 130
        overlay.isHidden = true
        let bg = SKShapeNode()
        bg.fillColor = SKColor(hex: "#05060f")
        bg.strokeColor = .clear
        overlay.addChild(bg)

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.fontSize = 30
        overlay.addChild(title)
        matchOverTitle = title

        let sub = SKLabelNode(fontNamed: "Menlo")
        sub.fontSize = 14
        sub.fontColor = SKColor(white: 1, alpha: 0.75)
        overlay.addChild(sub)
        matchOverSub = sub

        let again = SKShapeNode(rectOf: CGSize(width: 210, height: 46), cornerRadius: 12)
        again.fillColor = SKColor(hex: "#ffd27a")
        again.strokeColor = .clear
        overlay.addChild(again)
        let againL = SKLabelNode(fontNamed: "Menlo-Bold")
        againL.fontSize = 14
        againL.fontColor = SKColor(hex: "#05060f")
        againL.verticalAlignmentMode = .center
        againL.horizontalAlignmentMode = .center
        overlay.addChild(againL)
        matchAgainLabel = againL
        buttons.append(UIButton(node: again, id: "match-again"))

        let menuBtn = SKShapeNode(rectOf: CGSize(width: 210, height: 40), cornerRadius: 12)
        menuBtn.strokeColor = SKColor(hex: "#4d78ff")
        menuBtn.lineWidth = 1.5
        overlay.addChild(menuBtn)
        let menuL = SKLabelNode(fontNamed: "Menlo-Bold")
        menuL.fontSize = 13
        menuL.fontColor = .white
        menuL.verticalAlignmentMode = .center
        menuL.horizontalAlignmentMode = .center
        overlay.addChild(menuL)
        matchMenuLabel = menuL
        buttons.append(UIButton(node: menuBtn, id: "match-menu"))

        matchAgainBg = again
        matchMenuBg = menuBtn

        addChild(overlay)
        matchOverOverlay = overlay
    }

    func layoutMatchOverOverlay(size: CGSize) {
        guard let overlay = matchOverOverlay, let bg = overlay.children.first as? SKShapeNode else { return }
        bg.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        let cx = size.width / 2
        matchOverTitle?.position = CGPoint(x: cx, y: size.height / 2 + 60)
        matchOverSub?.position = CGPoint(x: cx, y: size.height / 2 + 20)
        matchAgainBg?.position = CGPoint(x: cx, y: size.height / 2 - 40)
        matchAgainLabel?.position = matchAgainBg?.position ?? .zero
        matchMenuBg?.position = CGPoint(x: cx, y: size.height / 2 - 96)
        matchMenuLabel?.position = matchMenuBg?.position ?? .zero
    }

    func showMatchOverOverlay() {
        matchOverOverlay?.isHidden = false
        let playerWon = playerWins > cpuWins
        matchOverTitle?.text = playerWon ? L.t("matchWinTitle") : L.t("matchLoseTitle")
        matchOverTitle?.fontColor = playerWon ? SKColor(hex: "#ffd27a") : SKColor(hex: "#ff5a3c")
        matchOverSub?.text = "\(playerWins) : \(cpuWins)"
    }

    // MARK: Text refresh (language change)

    func refreshTexts() {
        hud.langButton.text = L.current == .pt ? "PT" : "EN"
        hud.playerNameLabel.text = BeybladePresets.all[playerPresetIndex].name
        hud.cpuNameLabel.text = BeybladePresets.all[cpuPresetIndex].name
        hud.boostLabel.text = L.t("boost")

        menuTitleLabel?.text = L.t("title")
        menuTaglineLabel?.text = L.t("tagline")
        startLabel?.text = L.t("pressStart")

        for diff in Difficulty.allCases {
            diffButtons[diff]?.label.text = L.t("diff\(diff.rawValue.prefix(1).uppercased() + diff.rawValue.dropFirst())")
        }
        for (i, card) in topCards.enumerated() {
            let preset = BeybladePresets.all[i]
            card.name.text = preset.name
            card.type.text = L.typeName(preset.type)
        }

        pullHintLabel?.text = L.t("pullHint")
        pauseTitle?.text = L.t("pausedTitle")
        pauseSub?.text = L.t("pausedSub")
        matchAgainLabel?.text = L.t("playAgainBtn")
        matchMenuLabel?.text = L.t("menuBtn")

        if phase == .roundResult, let lastLoser = lastRoundLoser {
            showRoundResultOverlay(winner: lastLoser === player ? cpu : player)
        }
        if let size = view?.bounds.size { layoutMenu(size: size) }
    }

    // MARK: Button dispatch

    func handleButtonTap(_ id: String) {
        SoundEngine.shared.playUITap()
        switch id {
        case "btn-lang":
            L.toggle()
            refreshTexts()
        case "btn-pause":
            guard phase == .battle || phase == .launch else { return }
            gamePaused.toggle()
            pauseOverlay?.isHidden = !gamePaused
        case "pause-tap":
            gamePaused = false
            pauseOverlay?.isHidden = true
        case "btn-boost":
            guard phase == .battle, player.isAlive else { return }
            if player.applyBoost() {
                playerNode.playBoostPulse()
                SoundEngine.shared.playBoost()
                Haptics.impact(0.3)
            }
        case "diff-easy": difficulty = .easy; refreshMenuSelection()
        case "diff-normal": difficulty = .normal; refreshMenuSelection()
        case "diff-hard": difficulty = .hard; refreshMenuSelection()
        case "start-tap":
            prepareNewMatch()
        case "round-continue":
            guard phase == .roundResult else { return }
            roundNumber += 1
            startRound()
        case "match-again":
            prepareNewMatch()
        case "match-menu":
            showMenu()
        case "open-website":
            if let url = URL(string: "https://ividi.dev/") {
                UIApplication.shared.open(url)
            }
        case "splash-tap":
            closeSplash()
        default:
            if id.hasPrefix("top-"), let idx = Int(id.dropFirst(4)) {
                playerPresetIndex = idx
                refreshMenuSelection()
                refreshTexts()
            }
        }
    }

    // MARK: Touch handling

    func isEffectivelyVisible(_ node: SKNode) -> Bool {
        var n: SKNode? = node
        while let cur = n {
            if cur.isHidden { return false }
            n = cur.parent
        }
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let loc = touch.location(in: self)

        if let hit = buttons.first(where: { isEffectivelyVisible($0.node) && $0.node.calculateAccumulatedFrame().contains(loc) }) {
            handleButtonTap(hit.id)
            return
        }

        if phase == .launch, !player.launched, !gamePaused {
            isDragging = true
            launchAnchor = playerLaunchOrigin
            dragCurrent = loc
            updatePullIndicator()
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging, let touch = touches.first else { return }
        dragCurrent = touch.location(in: self)
        updatePullIndicator()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isDragging else { return }
        hidePullIndicator()
        let pullVec = CGVector(dx: launchAnchor.x - dragCurrent.x, dy: launchAnchor.y - dragCurrent.y)
        let pullDist = hypot(pullVec.dx, pullVec.dy)
        guard pullDist > 14 else { return }
        let maxPull: CGFloat = 150
        let power = max(0.35, min(1, pullDist / maxPull))
        let dir = CGVector(dx: pullVec.dx / pullDist, dy: pullVec.dy / pullDist)
        let direction = CGVector(dx: dir.dx * baseLaunchSpeed, dy: dir.dy * baseLaunchSpeed)
        launchPlayer(direction: direction, power: power)
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        hidePullIndicator()
    }

    // MARK: Keyboard forwarding (see GameSKView)

    func handleKeyDown(_ key: String, isRepeat: Bool) {
        guard !isRepeat else { return }
        if key == " " { handleButtonTap("btn-boost") }
        if key == "p" || key == "Escape" { handleButtonTap("btn-pause") }
    }

    func handleKeyUp(_ key: String) {}
}
