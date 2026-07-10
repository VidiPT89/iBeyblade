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

        hud.suddenDeathLabel.fontSize = 12
        hud.suddenDeathLabel.fontColor = SKColor(hex: "#ff4d4d")
        hud.suddenDeathLabel.horizontalAlignmentMode = .center
        hud.suddenDeathLabel.isHidden = true

        for (button, label, charges) in [(hud.boostButton, hud.boostLabel, hud.boostChargesLabel), (hud.boostButton2, hud.boostLabel2, hud.boostChargesLabel2)] {
            button.fillColor = SKColor(white: 1, alpha: 0.1)
            button.strokeColor = SKColor(hex: "#7fa8ff")
            button.lineWidth = 2
            button.glowWidth = 3
            label.fontSize = 12
            label.fontColor = .white
            label.text = "SP"
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            charges.fontSize = 10
            charges.fontColor = SKColor(white: 1, alpha: 0.7)
            charges.verticalAlignmentMode = .center
            charges.horizontalAlignmentMode = .center
        }
        hud.boostButton2.isHidden = true
        hud.boostLabel2.isHidden = true
        hud.boostChargesLabel2.isHidden = true

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
                  hud.roundLabel, hud.suddenDeathLabel,
                  hud.boostButton, hud.boostLabel, hud.boostChargesLabel,
                  hud.boostButton2, hud.boostLabel2, hud.boostChargesLabel2,
                  hud.langButton, hud.langHit, hud.pauseButton, hud.pauseLabel] {
            hud.container.addChild(n)
        }
        addChild(hud.container)

        buttons.append(UIButton(node: hud.langHit, id: "btn-lang"))
        buttons.append(UIButton(node: hud.pauseButton, id: "btn-pause"))
        buttons.append(UIButton(node: hud.pauseLabel, id: "btn-pause"))
        buttons.append(UIButton(node: hud.boostButton, id: "btn-boost"))
        buttons.append(UIButton(node: hud.boostLabel, id: "btn-boost"))
        buttons.append(UIButton(node: hud.boostButton2, id: "btn-boost2"))
        buttons.append(UIButton(node: hud.boostLabel2, id: "btn-boost2"))
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
        hud.suddenDeathLabel.position = CGPoint(x: size.width / 2, y: topY - 22)

        hud.langButton.position = CGPoint(x: size.width / 2 - 60, y: size.height - topSafeInset - 60)
        hud.langHit.position = hud.langButton.position
        hud.pauseButton.position = CGPoint(x: size.width / 2 + 60, y: size.height - topSafeInset - 60)
        hud.pauseLabel.position = hud.pauseButton.position

        hud.boostButton.position = CGPoint(x: size.width - 60, y: 60 + bottomSafeInset)
        hud.boostLabel.position = CGPoint(x: hud.boostButton.position.x, y: hud.boostButton.position.y + 6)
        hud.boostChargesLabel.position = CGPoint(x: hud.boostButton.position.x, y: hud.boostButton.position.y - 12)

        hud.boostButton2.position = CGPoint(x: size.width - 60, y: size.height - topSafeInset - 110)
        hud.boostLabel2.position = CGPoint(x: hud.boostButton2.position.x, y: hud.boostButton2.position.y + 6)
        hud.boostChargesLabel2.position = CGPoint(x: hud.boostButton2.position.x, y: hud.boostButton2.position.y - 12)
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

        let battling = phase == .battle
        hud.boostButton.isHidden = !battling
        hud.boostLabel.isHidden = !battling
        hud.boostChargesLabel.isHidden = !battling
        if battling { updateSpecialButton(hud.boostButton, charges: hud.boostChargesLabel, gauge: player.specialGauge) }

        let show2 = isLocal2P && battling
        hud.boostButton2.isHidden = !show2
        hud.boostLabel2.isHidden = !show2
        hud.boostChargesLabel2.isHidden = !show2
        if show2 { updateSpecialButton(hud.boostButton2, charges: hud.boostChargesLabel2, gauge: cpu.specialGauge) }

        hud.pauseButton.isHidden = phase != .battle && phase != .launch
        hud.pauseLabel.isHidden = hud.pauseButton.isHidden
    }

    private func updateSpecialButton(_ button: SKShapeNode, charges: SKLabelNode, gauge: CGFloat) {
        let ready = gauge >= 100
        button.strokeColor = ready ? SKColor(hex: "#ffd27a") : SKColor(hex: "#7fa8ff")
        button.glowWidth = ready ? 9 : 3
        button.alpha = ready ? 1 : 0.55 + 0.35 * (gauge / 100)
        charges.text = "\(Int(gauge))%"
    }

    // MARK: Menu

    private func typeEmoji(_ type: TopType) -> String {
        switch type {
        case .attack: return "⚔️"
        case .defense: return "🛡️"
        case .stamina: return "⏱️"
        case .balance: return "⚖️"
        }
    }

    func buildMenu() {
        let overlay = SKNode()
        overlay.zPosition = 100
        let bg = SKShapeNode()
        bg.fillColor = SKColor(hex: "#05060f")
        bg.strokeColor = .clear
        overlay.addChild(bg)

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.fontSize = 32
        title.fontColor = SKColor(hex: "#ffd27a")
        overlay.addChild(title)
        menuTitleLabel = title
        title.run(.repeatForever(.sequence([
            .fadeAlpha(to: 0.82, duration: 1.4), .fadeAlpha(to: 1.0, duration: 1.4),
        ])))

        let tagline = SKLabelNode(fontNamed: "Menlo")
        tagline.fontSize = 12
        tagline.fontColor = SKColor(white: 1, alpha: 0.7)
        tagline.numberOfLines = 2
        tagline.preferredMaxLayoutWidth = 300
        overlay.addChild(tagline)
        menuTaglineLabel = tagline

        let langHit = SKShapeNode(rectOf: CGSize(width: 56, height: 34), cornerRadius: 10)
        langHit.strokeColor = SKColor(hex: "#7fa8ff")
        langHit.lineWidth = 1.5
        langHit.fillColor = SKColor(white: 1, alpha: 0.06)
        let langLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        langLabel.fontSize = 13
        langLabel.fontColor = .white
        langLabel.verticalAlignmentMode = .center
        langLabel.horizontalAlignmentMode = .center
        overlay.addChild(langHit)
        overlay.addChild(langLabel)
        menuLangHit = langHit
        menuLangLabel = langLabel
        buttons.append(UIButton(node: langHit, id: "btn-lang"))

        let modePanel = SKShapeNode()
        modePanel.fillColor = SKColor(white: 1, alpha: 0.035)
        modePanel.strokeColor = SKColor(hex: "#4d78ff").withAlphaComponent(0.45)
        modePanel.lineWidth = 1
        overlay.addChild(modePanel)
        self.modePanel = modePanel

        let modeHeader = SKLabelNode(fontNamed: "Menlo-Bold")
        modeHeader.fontSize = 11
        modeHeader.fontColor = SKColor(white: 1, alpha: 0.55)
        overlay.addChild(modeHeader)
        modeSectionHeader = modeHeader

        for mode in [MatchMode.vsCPU, .vsPlayer] {
            let bgBtn = SKShapeNode(rectOf: CGSize(width: 130, height: 32), cornerRadius: 8)
            bgBtn.strokeColor = SKColor(hex: "#4d78ff")
            bgBtn.lineWidth = 1.5
            let label = SKLabelNode(fontNamed: "Menlo-Bold")
            label.fontSize = 12
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.fontColor = .white
            overlay.addChild(bgBtn)
            overlay.addChild(label)
            modeButtons[mode] = (bgBtn, label)
            buttons.append(UIButton(node: bgBtn, id: mode == .vsCPU ? "mode-vsCPU" : "mode-vsPlayer"))
        }

        for diff in Difficulty.allCases {
            let bgBtn = SKShapeNode(rectOf: CGSize(width: 90, height: 32), cornerRadius: 8)
            bgBtn.strokeColor = SKColor(hex: "#4d78ff")
            bgBtn.lineWidth = 1.5
            let label = SKLabelNode(fontNamed: "Menlo-Bold")
            label.fontSize = 12
            label.verticalAlignmentMode = .center
            label.horizontalAlignmentMode = .center
            label.fontColor = .white
            overlay.addChild(bgBtn)
            overlay.addChild(label)
            diffButtons[diff] = (bgBtn, label)
            buttons.append(UIButton(node: bgBtn, id: "diff-\(diff.rawValue)"))
        }

        let topPanel = SKShapeNode()
        topPanel.fillColor = SKColor(white: 1, alpha: 0.035)
        topPanel.strokeColor = SKColor(hex: "#4d78ff").withAlphaComponent(0.45)
        topPanel.lineWidth = 1
        overlay.addChild(topPanel)
        self.topPanel = topPanel

        let header = SKLabelNode(fontNamed: "Menlo-Bold")
        header.fontSize = 13
        header.fontColor = SKColor(hex: "#ffd27a")
        overlay.addChild(header)
        topSectionHeader = header

        for slot in 0..<4 {
            let card = SKShapeNode(rectOf: CGSize(width: 148, height: 88), cornerRadius: 10)
            card.lineWidth = 1.5
            let name = SKLabelNode(fontNamed: "Menlo-Bold")
            name.fontSize = 12
            name.fontColor = .white
            name.horizontalAlignmentMode = .center
            let type = SKLabelNode(fontNamed: "Menlo")
            type.fontSize = 10
            type.horizontalAlignmentMode = .center
            let stats = SKNode()
            overlay.addChild(card)
            overlay.addChild(name)
            overlay.addChild(type)
            overlay.addChild(stats)
            topCards.append((card, name, type, stats))
            buttons.append(UIButton(node: card, id: "top-slot-\(slot)"))
        }

        let prev = SKShapeNode(circleOfRadius: 16)
        prev.strokeColor = SKColor(hex: "#7fa8ff")
        prev.lineWidth = 1.5
        prev.fillColor = SKColor(white: 1, alpha: 0.05)
        let prevLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        prevLabel.text = "‹"; prevLabel.fontSize = 16; prevLabel.fontColor = .white
        prevLabel.verticalAlignmentMode = .center; prevLabel.horizontalAlignmentMode = .center
        overlay.addChild(prev); overlay.addChild(prevLabel)
        pagePrevButton = prev
        buttons.append(UIButton(node: prev, id: "page-prev"))

        let next = SKShapeNode(circleOfRadius: 16)
        next.strokeColor = SKColor(hex: "#7fa8ff")
        next.lineWidth = 1.5
        next.fillColor = SKColor(white: 1, alpha: 0.05)
        let nextLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        nextLabel.text = "›"; nextLabel.fontSize = 16; nextLabel.fontColor = .white
        nextLabel.verticalAlignmentMode = .center; nextLabel.horizontalAlignmentMode = .center
        overlay.addChild(next); overlay.addChild(nextLabel)
        pageNextButton = next
        buttons.append(UIButton(node: next, id: "page-next"))

        for _ in 0..<2 {
            let dot = SKShapeNode(circleOfRadius: 4)
            dot.strokeColor = .clear
            overlay.addChild(dot)
            pageDots.append(dot)
        }

        let start = SKShapeNode(rectOf: CGSize(width: 220, height: 50), cornerRadius: 12)
        start.fillColor = SKColor(hex: "#ffd27a")
        start.strokeColor = .clear
        start.glowWidth = 4
        overlay.addChild(start)
        let startL = SKLabelNode(fontNamed: "Menlo-Bold")
        startL.fontSize = 15
        startL.fontColor = SKColor(hex: "#05060f")
        startL.verticalAlignmentMode = .center
        startL.horizontalAlignmentMode = .center
        overlay.addChild(startL)
        startLabel = startL
        buttons.append(UIButton(node: start, id: "start-tap"))
        let pulse = SKAction.repeatForever(.sequence([
            .group([.scale(to: 1.035, duration: 0.7), .fadeAlpha(to: 0.88, duration: 0.7)]),
            .group([.scale(to: 1.0, duration: 0.7), .fadeAlpha(to: 1.0, duration: 0.7)]),
        ]))
        start.run(pulse)

        let settingsBg = SKShapeNode(circleOfRadius: 20)
        settingsBg.strokeColor = SKColor(hex: "#4d78ff")
        settingsBg.lineWidth = 1.5
        settingsBg.fillColor = SKColor(white: 1, alpha: 0.05)
        let settingsL = SKLabelNode(fontNamed: "Menlo-Bold")
        settingsL.text = "⚙"; settingsL.fontSize = 16; settingsL.fontColor = .white
        settingsL.verticalAlignmentMode = .center; settingsL.horizontalAlignmentMode = .center
        overlay.addChild(settingsBg); overlay.addChild(settingsL)
        settingsButtonBg = settingsBg
        settingsButtonLabel = settingsL
        buttons.append(UIButton(node: settingsBg, id: "btn-settings"))

        let helpBg = SKShapeNode(circleOfRadius: 20)
        helpBg.strokeColor = SKColor(hex: "#4d78ff")
        helpBg.lineWidth = 1.5
        helpBg.fillColor = SKColor(white: 1, alpha: 0.05)
        let helpL = SKLabelNode(fontNamed: "Menlo-Bold")
        helpL.text = "?"; helpL.fontSize = 16; helpL.fontColor = .white
        helpL.verticalAlignmentMode = .center; helpL.horizontalAlignmentMode = .center
        overlay.addChild(helpBg); overlay.addChild(helpL)
        helpButtonBg = helpBg
        helpButtonLabel = helpL
        buttons.append(UIButton(node: helpBg, id: "btn-help"))

        let tutBg = SKShapeNode(circleOfRadius: 20)
        tutBg.strokeColor = SKColor(hex: "#4d78ff")
        tutBg.lineWidth = 1.5
        tutBg.fillColor = SKColor(white: 1, alpha: 0.05)
        let tutLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        tutLabel.text = "🎓"
        tutLabel.fontSize = 16
        tutLabel.fontColor = .white
        tutLabel.verticalAlignmentMode = .center
        tutLabel.horizontalAlignmentMode = .center
        overlay.addChild(tutBg)
        overlay.addChild(tutLabel)
        tutorialButtonBg = tutBg
        tutorialButtonLabel = tutLabel
        buttons.append(UIButton(node: tutBg, id: "btn-tutorial"))

        addChild(overlay)
        menuOverlay = overlay
    }

    func layoutMenu(size: CGSize) {
        guard let overlay = menuOverlay, let bg = overlay.children.first as? SKShapeNode else { return }
        bg.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        let cx = size.width / 2
        var y = size.height - topSafeInset - 58
        menuTitleLabel?.position = CGPoint(x: cx, y: y)

        menuLangHit?.position = CGPoint(x: size.width - 46, y: size.height - topSafeInset - 30)
        menuLangLabel?.position = menuLangHit?.position ?? .zero

        y -= 52
        menuTaglineLabel?.position = CGPoint(x: cx, y: y)
        y -= 56

        let modeTop = y + 28
        modeSectionHeader?.position = CGPoint(x: cx, y: y)
        y -= 36

        if let vsCPU = modeButtons[.vsCPU], let vsPlayer = modeButtons[.vsPlayer] {
            vsCPU.bg.position = CGPoint(x: cx - 72, y: y)
            vsCPU.label.position = vsCPU.bg.position
            vsPlayer.bg.position = CGPoint(x: cx + 72, y: y)
            vsPlayer.label.position = vsPlayer.bg.position
        }
        y -= 52

        let diffs = Difficulty.allCases
        let diffSpacing: CGFloat = 104
        let diffStartX = cx - diffSpacing * CGFloat(diffs.count - 1) / 2
        for (i, diff) in diffs.enumerated() {
            guard let pair = diffButtons[diff] else { continue }
            let x = diffStartX + CGFloat(i) * diffSpacing
            pair.bg.position = CGPoint(x: x, y: y)
            pair.label.position = CGPoint(x: x, y: y)
        }
        let modeBottom = y - 28
        modePanel?.path = CGPath(
            roundedRect: CGRect(x: cx - 178, y: modeBottom, width: 356, height: modeTop - modeBottom),
            cornerWidth: 18, cornerHeight: 18, transform: nil
        )
        y -= 66

        let topTop = y + 30
        topSectionHeader?.position = CGPoint(x: cx, y: y)
        y -= 56

        let cols = 2
        let cardStepX: CGFloat = 168
        let cardStepY: CGFloat = 104
        let startX = cx - cardStepX * CGFloat(cols - 1) / 2
        for (i, card) in topCards.enumerated() {
            let col = i % cols
            let row = i / cols
            let x = startX + CGFloat(col) * cardStepX
            let cardY = y - CGFloat(row) * cardStepY
            card.bg.position = CGPoint(x: x, y: cardY)
            card.name.position = CGPoint(x: x, y: cardY + 16)
            card.type.position = CGPoint(x: x, y: cardY)
            layoutStatBars(card.stats, preset: BeybladePresets.all[currentTopSlotPresets[i]], center: CGPoint(x: x, y: cardY - 19))
        }
        y -= cardStepY + 58

        pagePrevButton?.position = CGPoint(x: cx - 44, y: y)
        (buttons.first(where: { $0.id == "page-prev" })?.node as? SKShapeNode)?.position = CGPoint(x: cx - 44, y: y)
        pageNextButton?.position = CGPoint(x: cx + 44, y: y)
        for (i, dot) in pageDots.enumerated() {
            dot.position = CGPoint(x: cx - 11 + CGFloat(i) * 22, y: y)
        }
        let topBottom = y - 30
        topPanel?.path = CGPath(
            roundedRect: CGRect(x: cx - 182, y: topBottom, width: 364, height: topTop - topBottom),
            cornerWidth: 18, cornerHeight: 18, transform: nil
        )
        y -= 76

        guard let start = buttons.first(where: { $0.id == "start-tap" })?.node else { return }
        start.position = CGPoint(x: cx, y: max(58 + bottomSafeInset, y))
        startLabel?.position = start.position
        y = start.position.y - 80

        settingsButtonBg?.position = CGPoint(x: cx - 96, y: y)
        settingsButtonLabel?.position = CGPoint(x: cx - 96, y: y)
        tutorialButtonBg?.position = CGPoint(x: cx, y: y)
        tutorialButtonLabel?.position = CGPoint(x: cx, y: y)
        helpButtonBg?.position = CGPoint(x: cx + 96, y: y)
        helpButtonLabel?.position = CGPoint(x: cx + 96, y: y)
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

    /// Indices into `BeybladePresets.all` for the 4 cards currently shown.
    var currentTopSlotPresets: [Int] {
        let base = topPage * 4
        return [base, base + 1, base + 2, base + 3]
    }

    func showMenu() {
        phase = .menu
        gamePaused = false
        menuStep = .main
        menuOverlay?.isHidden = false
        launchOverlay?.isHidden = true
        pauseOverlay?.isHidden = true
        roundResultOverlay?.isHidden = true
        matchOverOverlay?.isHidden = true
        refreshTexts()
        refreshMenuSelection()
    }

    func refreshMenuSelection() {
        for (mode, pair) in modeButtons {
            let selected = mode == matchMode
            pair.bg.fillColor = selected ? SKColor(hex: "#4d78ff").withAlphaComponent(0.35) : SKColor(white: 1, alpha: 0.05)
        }
        for (diff, pair) in diffButtons {
            let selected = diff == difficulty
            pair.bg.fillColor = selected ? SKColor(hex: "#4d78ff").withAlphaComponent(0.35) : SKColor(white: 1, alpha: 0.05)
            pair.bg.isHidden = matchMode == .vsPlayer || menuStep == .pickPlayer2
            pair.label.isHidden = pair.bg.isHidden
        }
        for pair in modeButtons.values {
            pair.bg.isHidden = menuStep == .pickPlayer2
            pair.label.isHidden = pair.bg.isHidden
        }
        modePanel?.isHidden = menuStep == .pickPlayer2
        modeSectionHeader?.isHidden = menuStep == .pickPlayer2
        let pickingIndex = menuStep == .pickPlayer2 ? player2PresetIndex : playerPresetIndex
        let slotPresets = currentTopSlotPresets
        for (i, card) in topCards.enumerated() {
            let presetIdx = slotPresets[i]
            let preset = BeybladePresets.all[presetIdx]
            let selected = presetIdx == pickingIndex
            card.bg.strokeColor = SKColor(hex: preset.glowHex)
            card.bg.fillColor = selected ? SKColor(hex: preset.glowHex).withAlphaComponent(0.22) : SKColor(white: 1, alpha: 0.04)
            card.bg.lineWidth = selected ? 3 : 1.5
            card.type.fontColor = SKColor(hex: preset.glowHex)
        }
        for (i, dot) in pageDots.enumerated() {
            dot.fillColor = i == topPage ? SKColor(hex: "#ffd27a") : SKColor(white: 1, alpha: 0.25)
        }
        let icons = [settingsButtonBg, helpButtonBg, tutorialButtonBg, settingsButtonLabel, helpButtonLabel, tutorialButtonLabel]
        for n in icons { n?.isHidden = menuStep == .pickPlayer2 }
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

        let hint2 = SKLabelNode(fontNamed: "Menlo")
        hint2.fontSize = 13
        hint2.fontColor = SKColor(white: 1, alpha: 0.75)
        hint2.isHidden = true
        overlay.addChild(hint2)
        pullHintLabel2 = hint2

        let indicator = SKShapeNode()
        indicator.strokeColor = SKColor(hex: "#ffd27a")
        indicator.lineWidth = 3
        indicator.glowWidth = 3
        indicator.isHidden = true
        overlay.addChild(indicator)
        pullIndicator = indicator

        let indicator2 = SKShapeNode()
        indicator2.strokeColor = SKColor(hex: "#6fd8ff")
        indicator2.lineWidth = 3
        indicator2.glowWidth = 3
        indicator2.isHidden = true
        overlay.addChild(indicator2)
        pullIndicator2 = indicator2

        addChild(overlay)
        launchOverlay = overlay
    }

    func layoutLaunchOverlay(size: CGSize) {
        pullHintLabel?.position = CGPoint(x: size.width / 2, y: bottomSafeInset + 90)
        pullHintLabel2?.position = CGPoint(x: size.width / 2, y: size.height - topSafeInset - 90)
    }

    func prepareNewMatch() {
        playerWins = 0
        cpuWins = 0
        roundNumber = 1
        if matchMode == .vsCPU {
            var options = Array(BeybladePresets.all.indices)
            options.removeAll { $0 == playerPresetIndex }
            cpuPresetIndex = options.randomElement() ?? ((playerPresetIndex + 1) % BeybladePresets.all.count)
        } else {
            cpuPresetIndex = player2PresetIndex
        }
        rebuildEntities()
        startRound()
    }

    func startRound() {
        phase = .launch
        gamePaused = false
        collisionCooldown = 0
        pendingRoundEnd = nil
        battleElapsed = 0
        suddenDeathActive = false
        hud.suddenDeathLabel.isHidden = true
        hud.suddenDeathLabel.removeAllActions()
        activeDrags.removeAll()
        menuOverlay?.isHidden = true
        pauseOverlay?.isHidden = true
        roundResultOverlay?.isHidden = true
        matchOverOverlay?.isHidden = true
        launchOverlay?.isHidden = false
        pullHintLabel2?.isHidden = !isLocal2P
        hud.playerNameLabel.text = BeybladePresets.all[playerPresetIndex].name
        hud.cpuNameLabel.text = BeybladePresets.all[cpuPresetIndex].name

        player.position = playerLaunchOrigin
        player.velocity = .zero
        player.stamina = 100
        player.spinSpeed = 0
        player.specialGauge = 0
        player.specialActiveTimer = 0
        player.isAlive = true
        player.launched = false
        player.koReason = nil
        player.wobble = 0

        cpu.position = cpuLaunchOrigin
        cpu.velocity = .zero
        cpu.stamina = 100
        cpu.spinSpeed = 0
        cpu.specialGauge = 0
        cpu.specialActiveTimer = 0
        cpu.isAlive = true
        cpu.launched = false
        cpu.koReason = nil
        cpu.wobble = 0

        playerNode.resetForNewRound()
        cpuNode.resetForNewRound()
        hud.roundLabel.text = "\(L.t("round")) \(roundNumber) — \(playerWins):\(cpuWins)"
    }

    private func releaseDrag(_ drag: DragState) {
        let pullVec = CGVector(dx: drag.anchor.x - drag.current.x, dy: drag.anchor.y - drag.current.y)
        let pullDist = hypot(pullVec.dx, pullVec.dy)
        guard pullDist > 14 else { return }
        let maxPull: CGFloat = 150
        let power = max(0.35, min(1, pullDist / maxPull))
        let dir = CGVector(dx: pullVec.dx / pullDist, dy: pullVec.dy / pullDist)
        let direction = CGVector(dx: dir.dx * baseLaunchSpeed, dy: dir.dy * baseLaunchSpeed)

        switch drag.target {
        case .player1:
            player.launch(from: playerLaunchOrigin, direction: direction, power: power)
            playerNode.playLaunchPulse()
            SoundEngine.shared.playLaunch()
            Haptics.impact(0.4)
            if !isLocal2P {
                launchCPUTop()
                phase = .battle
                launchOverlay?.isHidden = true
            } else if cpu.launched {
                phase = .battle
                launchOverlay?.isHidden = true
            }
        case .player2:
            cpu.launch(from: cpuLaunchOrigin, direction: direction, power: power)
            cpuNode.playLaunchPulse()
            SoundEngine.shared.playLaunch()
            Haptics.impact(0.4)
            if player.launched {
                phase = .battle
                launchOverlay?.isHidden = true
            }
        }
    }

    private func updatePullIndicators() {
        if let d = activeDrags.values.first(where: { $0.target == .player1 }) {
            pullIndicator?.isHidden = false
            let path = CGMutablePath()
            path.move(to: d.anchor); path.addLine(to: d.current)
            pullIndicator?.path = path
        } else {
            pullIndicator?.isHidden = true
        }
        if let d = activeDrags.values.first(where: { $0.target == .player2 }) {
            pullIndicator2?.isHidden = false
            let path = CGMutablePath()
            path.move(to: d.anchor); path.addLine(to: d.current)
            pullIndicator2?.path = path
        } else {
            pullIndicator2?.isHidden = true
        }
    }

    // MARK: Special Move

    func fireSpecialMove(for entity: BeybladeEntity, node: BeybladeNode) {
        guard entity.triggerSpecial() else { return }
        node.playSpecialBurst()
        SoundEngine.shared.playSpecialMove()
        Haptics.impact(0.6)
        showSpecialBanner(for: entity)
    }

    func showSpecialBanner(for entity: BeybladeEntity) {
        specialBanner?.removeAllActions()
        specialBanner?.removeFromParent()
        let label = SKLabelNode(fontNamed: "Menlo-Bold")
        label.text = L.spiritRising(entity.preset.spiritName)
        label.fontSize = 20
        label.fontColor = SKColor(hex: entity.preset.glowHex)
        label.position = CGPoint(x: arenaCenter.x, y: arenaCenter.y)
        label.alpha = 0
        label.setScale(0.6)
        label.zPosition = 60
        addChild(label)
        specialBanner = label
        label.run(.sequence([
            .group([.fadeIn(withDuration: 0.15), .scale(to: 1.1, duration: 0.25)]),
            .scale(to: 1.0, duration: 0.1),
            .wait(forDuration: 0.9),
            .group([.fadeOut(withDuration: 0.4), .moveBy(x: 0, y: 30, duration: 0.4)]),
            .removeFromParent(),
        ]))
    }

    func showSuddenDeathBanner() {
        hud.suddenDeathLabel.isHidden = false
        hud.suddenDeathLabel.alpha = 0
        hud.suddenDeathLabel.removeAllActions()
        hud.suddenDeathLabel.run(.sequence([.fadeIn(withDuration: 0.3), .wait(forDuration: 1.6), .fadeOut(withDuration: 0.5)]))
        Haptics.warning()
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
        title.fontSize = 22
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
        if isLocal2P {
            text = winner === cpu ? L.t("p2WinRound") : L.t("p1WinRound")
        } else {
            text = winner === cpu ? L.t("cpuWinRound") : L.t("youWinRound")
        }
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
        title.fontSize = 28
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
        if isLocal2P {
            matchOverTitle?.text = playerWon ? L.t("p1MatchWin") : L.t("p2MatchWin")
        } else {
            matchOverTitle?.text = playerWon ? L.t("matchWinTitle") : L.t("matchLoseTitle")
        }
        matchOverTitle?.fontColor = playerWon ? SKColor(hex: "#ffd27a") : SKColor(hex: "#ff5a3c")
        matchOverSub?.text = "\(playerWins) : \(cpuWins)"
    }

    // MARK: Text refresh (language change)

    func refreshTexts() {
        let langText = L.current == .pt ? "PT" : "EN"
        hud.langButton.text = langText
        menuLangLabel?.text = langText
        hud.playerNameLabel.text = BeybladePresets.all[playerPresetIndex].name
        hud.cpuNameLabel.text = BeybladePresets.all[cpuPresetIndex].name
        hud.roundLabel.text = "\(L.t("round")) \(roundNumber) — \(playerWins):\(cpuWins)"
        hud.suddenDeathLabel.text = L.t("suddenDeath")

        menuTitleLabel?.text = L.t("title")
        menuTaglineLabel?.text = L.t("tagline")
        modeSectionHeader?.text = L.t("chooseMode")
        startLabel?.text = menuStep == .pickPlayer2 ? L.t("pressStart") : L.t("pressStart")
        topSectionHeader?.text = menuStep == .pickPlayer2 ? L.t("pickTopP2") : (matchMode == .vsPlayer ? L.t("pickTopP1") : L.t("chooseTop"))

        modeButtons[.vsCPU]?.label.text = L.t("modeVsCPU")
        modeButtons[.vsPlayer]?.label.text = L.t("modeVsPlayer")

        for diff in Difficulty.allCases {
            diffButtons[diff]?.label.text = L.t("diff\(diff.rawValue.prefix(1).uppercased() + diff.rawValue.dropFirst())")
        }
        for (i, card) in topCards.enumerated() {
            let preset = BeybladePresets.all[currentTopSlotPresets[i]]
            card.name.text = preset.name
            card.type.text = "\(typeEmoji(preset.type)) \(L.typeName(preset.type))"
        }

        pullHintLabel?.text = L.t("pullHint")
        pullHintLabel2?.text = L.t("pullHint")
        pauseTitle?.text = L.t("pausedTitle")
        pauseSub?.text = L.t("pausedSub")
        matchAgainLabel?.text = L.t("playAgainBtn")
        matchMenuLabel?.text = L.t("menuBtn")

        refreshSettingsTexts()
        refreshHelpTexts()
        refreshTutorialTexts()

        if phase == .roundResult, let lastLoser = lastRoundLoser {
            showRoundResultOverlay(winner: lastLoser === player ? cpu : player)
        }
        if phase == .matchOver {
            showMatchOverOverlay()
        }
        if let size = view?.bounds.size {
            layoutMenu(size: size)
            refreshMenuSelection()
        }
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
            fireSpecialMove(for: player, node: playerNode)
        case "btn-boost2":
            guard phase == .battle, isLocal2P, cpu.isAlive else { return }
            fireSpecialMove(for: cpu, node: cpuNode)
        case "mode-vsCPU": matchMode = .vsCPU; refreshTexts()
        case "mode-vsPlayer": matchMode = .vsPlayer; refreshTexts()
        case "diff-easy": difficulty = .easy; refreshMenuSelection()
        case "diff-normal": difficulty = .normal; refreshMenuSelection()
        case "diff-hard": difficulty = .hard; refreshMenuSelection()
        case "page-prev": topPage = topPage == 0 ? 1 : 0; refreshTexts()
        case "page-next": topPage = topPage == 0 ? 1 : 0; refreshTexts()
        case "start-tap":
            if menuStep == .main, matchMode == .vsPlayer {
                menuStep = .pickPlayer2
                refreshTexts()
            } else {
                menuStep = .main
                prepareNewMatch()
            }
        case "round-continue":
            guard phase == .roundResult else { return }
            roundNumber += 1
            startRound()
        case "match-again":
            prepareNewMatch()
        case "match-menu":
            showMenu()
        case "btn-settings":
            openSettings()
        case "btn-help":
            openHelp()
        case "btn-tutorial":
            openTutorial()
        case "settings-close":
            closeSettings()
        case "settings-toggle-sound":
            let on = SoundEngine.shared.toggleSound()
            refreshSettingsTexts()
            if on { SoundEngine.shared.playUITap() }
        case "settings-toggle-haptics":
            Haptics.isEnabled.toggle()
            refreshSettingsTexts()
            Haptics.impact(0.4)
        case "settings-toggle-lang":
            L.toggle()
            refreshTexts()
        case "help-close":
            closeHelp()
        case "tutorial-next":
            advanceTutorial()
        case "tutorial-skip":
            closeTutorial()
        case "open-website":
            if let url = URL(string: "https://ividi.dev/") {
                UIApplication.shared.open(url)
            }
        case "splash-tap":
            closeSplash()
        default:
            if id.hasPrefix("top-slot-"), let slot = Int(id.dropFirst("top-slot-".count)) {
                let presetIdx = currentTopSlotPresets[slot]
                if menuStep == .pickPlayer2 { player2PresetIndex = presetIdx } else { playerPresetIndex = presetIdx }
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
        // While a blocking modal (Settings/Help/Tutorial) is up, only its own
        // buttons are tappable — otherwise taps would fall through to menu
        // buttons hidden underneath it.
        let candidateButtons = isBlockingOverlayVisible
            ? buttons.filter { $0.id.hasPrefix("settings-") || $0.id.hasPrefix("help-") || $0.id.hasPrefix("tutorial-") }
            : buttons

        for touch in touches {
            let loc = touch.location(in: self)

            if let hit = candidateButtons.first(where: { isEffectivelyVisible($0.node) && $0.node.calculateAccumulatedFrame().contains(loc) }) {
                handleButtonTap(hit.id)
                continue
            }

            guard phase == .launch, !gamePaused, !isBlockingOverlayVisible else { continue }
            let id = ObjectIdentifier(touch)
            guard activeDrags[id] == nil else { continue }

            if isLocal2P {
                if loc.y >= arenaCenter.y, !cpu.launched, !activeDrags.values.contains(where: { $0.target == .player2 }) {
                    activeDrags[id] = DragState(target: .player2, anchor: cpuLaunchOrigin, current: loc)
                } else if loc.y < arenaCenter.y, !player.launched, !activeDrags.values.contains(where: { $0.target == .player1 }) {
                    activeDrags[id] = DragState(target: .player1, anchor: playerLaunchOrigin, current: loc)
                }
            } else if !player.launched, !activeDrags.values.contains(where: { $0.target == .player1 }) {
                activeDrags[id] = DragState(target: .player1, anchor: playerLaunchOrigin, current: loc)
            }
        }
        updatePullIndicators()
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        var changed = false
        for touch in touches {
            let id = ObjectIdentifier(touch)
            guard activeDrags[id] != nil else { continue }
            activeDrags[id]?.current = touch.location(in: self)
            changed = true
        }
        if changed { updatePullIndicators() }
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let id = ObjectIdentifier(touch)
            guard let drag = activeDrags.removeValue(forKey: id) else { continue }
            releaseDrag(drag)
        }
        updatePullIndicators()
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches { activeDrags.removeValue(forKey: ObjectIdentifier(touch)) }
        updatePullIndicators()
    }

    // MARK: Keyboard forwarding (see GameSKView)

    func handleKeyDown(_ key: String, isRepeat: Bool) {
        guard !isRepeat else { return }
        if key == " " { handleButtonTap("btn-boost") }
        if key == "p" || key == "Escape" { handleButtonTap("btn-pause") }
    }

    func handleKeyUp(_ key: String) {}
}
