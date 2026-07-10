import SpriteKit

/// Settings modal: sound/haptics/language toggles plus a lifetime wins
/// counter, reachable from the main menu.
extension GameScene {

    var totalWins: Int { UserDefaults.standard.integer(forKey: "ibeyblade.wins") }

    func recordMatchResult(playerWon: Bool) {
        guard playerWon else { return }
        UserDefaults.standard.set(totalWins + 1, forKey: "ibeyblade.wins")
    }

    func buildSettings() {
        let overlay = SKNode()
        overlay.zPosition = 200
        overlay.isHidden = true
        let bg = SKShapeNode()
        bg.fillColor = SKColor(hex: "#05060f")
        bg.strokeColor = .clear
        overlay.addChild(bg)

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.fontSize = 22
        title.fontColor = SKColor(hex: "#ffd27a")
        overlay.addChild(title)
        settingsTitleLabel = title

        soundRow = buildSettingsRow(in: overlay, valueTapId: "settings-toggle-sound")
        hapticsRow = buildSettingsRow(in: overlay, valueTapId: "settings-toggle-haptics")
        langRow = buildSettingsRow(in: overlay, valueTapId: "settings-toggle-lang")

        let winsLabel = SKLabelNode(fontNamed: "Menlo")
        winsLabel.fontSize = 14
        winsLabel.fontColor = .white
        winsLabel.horizontalAlignmentMode = .left
        let winsValue = SKLabelNode(fontNamed: "Menlo-Bold")
        winsValue.fontSize = 14
        winsValue.fontColor = SKColor(hex: "#ffd27a")
        winsValue.horizontalAlignmentMode = .right
        overlay.addChild(winsLabel)
        overlay.addChild(winsValue)
        winsRow = (winsLabel, winsValue)

        let close = SKShapeNode(rectOf: CGSize(width: 160, height: 44), cornerRadius: 12)
        close.strokeColor = SKColor(hex: "#4d78ff")
        close.lineWidth = 1.5
        let closeL = SKLabelNode(fontNamed: "Menlo-Bold")
        closeL.fontSize = 14
        closeL.fontColor = .white
        closeL.verticalAlignmentMode = .center
        closeL.horizontalAlignmentMode = .center
        overlay.addChild(close)
        overlay.addChild(closeL)
        settingsCloseBg = close
        settingsCloseLabel = closeL
        buttons.append(UIButton(node: close, id: "settings-close"))

        addChild(overlay)
        settingsOverlay = overlay
    }

    private func buildSettingsRow(in overlay: SKNode, valueTapId: String) -> (label: SKLabelNode, bg: SKShapeNode, valueLabel: SKLabelNode) {
        let label = SKLabelNode(fontNamed: "Menlo")
        label.fontSize = 14
        label.fontColor = .white
        label.horizontalAlignmentMode = .left
        let bg = SKShapeNode(rectOf: CGSize(width: 70, height: 32), cornerRadius: 8)
        bg.strokeColor = SKColor(hex: "#4d78ff")
        bg.lineWidth = 1.5
        bg.fillColor = SKColor(white: 1, alpha: 0.05)
        let valueLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        valueLabel.fontSize = 13
        valueLabel.fontColor = SKColor(hex: "#ffd27a")
        valueLabel.verticalAlignmentMode = .center
        valueLabel.horizontalAlignmentMode = .center
        overlay.addChild(label)
        overlay.addChild(bg)
        overlay.addChild(valueLabel)
        buttons.append(UIButton(node: bg, id: valueTapId))
        return (label, bg, valueLabel)
    }

    func layoutSettings(size: CGSize) {
        guard let overlay = settingsOverlay, let bg = overlay.children.first as? SKShapeNode else { return }
        bg.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        let cx = size.width / 2
        var y = size.height - topSafeInset - 90
        settingsTitleLabel?.position = CGPoint(x: cx, y: y)
        y -= 60
        let rowW: CGFloat = 260
        for row in [soundRow, hapticsRow, langRow] {
            guard let row else { continue }
            row.label.position = CGPoint(x: cx - rowW / 2, y: y)
            row.bg.position = CGPoint(x: cx + rowW / 2 - 35, y: y)
            row.valueLabel.position = row.bg.position
            y -= 50
        }
        if let winsRow {
            winsRow.label.position = CGPoint(x: cx - rowW / 2, y: y)
            winsRow.valueLabel.position = CGPoint(x: cx + rowW / 2 - 35, y: y)
            y -= 60
        }
        settingsCloseBg?.position = CGPoint(x: cx, y: max(60 + bottomSafeInset, y))
        settingsCloseLabel?.position = settingsCloseBg?.position ?? .zero
    }

    func refreshSettingsTexts() {
        settingsTitleLabel?.text = L.t("settingsTitle")
        soundRow?.label.text = L.t("soundLabel")
        soundRow?.valueLabel.text = SoundEngine.shared.isOn ? "ON" : "OFF"
        hapticsRow?.label.text = L.t("hapticsLabel")
        hapticsRow?.valueLabel.text = Haptics.isEnabled ? "ON" : "OFF"
        langRow?.label.text = L.t("languageLabel")
        langRow?.valueLabel.text = L.current == .pt ? "PT" : "EN"
        winsRow?.label.text = L.t("winsLabel")
        winsRow?.valueLabel.text = "\(totalWins)"
        settingsCloseLabel?.text = L.t("closeBtn")
    }

    func openSettings() {
        settingsOverlay?.isHidden = false
        refreshSettingsTexts()
    }

    func closeSettings() {
        settingsOverlay?.isHidden = true
    }
}
