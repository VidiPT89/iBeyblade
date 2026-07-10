import SpriteKit

/// Help (static rules reference) and the paged first-launch Tutorial.
extension GameScene {

    // MARK: Help

    func buildHelp() {
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
        helpTitleLabel = title

        let body = SKLabelNode(fontNamed: "Menlo")
        body.fontSize = 13
        body.fontColor = SKColor(white: 1, alpha: 0.85)
        body.numberOfLines = 0
        body.preferredMaxLayoutWidth = 300
        body.horizontalAlignmentMode = .left
        body.verticalAlignmentMode = .top
        body.lineBreakMode = .byWordWrapping
        overlay.addChild(body)
        helpBodyLabel = body

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
        helpCloseBg = close
        helpCloseLabel = closeL
        buttons.append(UIButton(node: close, id: "help-close"))

        addChild(overlay)
        helpOverlay = overlay
    }

    func layoutHelp(size: CGSize) {
        guard let overlay = helpOverlay, let bg = overlay.children.first as? SKShapeNode else { return }
        bg.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        let cx = size.width / 2
        helpTitleLabel?.position = CGPoint(x: cx, y: size.height - topSafeInset - 90)
        helpBodyLabel?.position = CGPoint(x: cx - 150, y: size.height - topSafeInset - 140)
        helpCloseBg?.position = CGPoint(x: cx, y: 70 + bottomSafeInset)
        helpCloseLabel?.position = helpCloseBg?.position ?? .zero
    }

    func refreshHelpTexts() {
        helpTitleLabel?.text = L.t("helpTitle")
        helpBodyLabel?.text = L.t("helpBody")
        helpCloseLabel?.text = L.t("closeBtn")
    }

    func openHelp() {
        helpOverlay?.isHidden = false
        refreshHelpTexts()
    }

    func closeHelp() {
        helpOverlay?.isHidden = true
    }

    // MARK: Tutorial

    func buildTutorial() {
        let overlay = SKNode()
        overlay.zPosition = 210
        overlay.isHidden = true
        let bg = SKShapeNode()
        bg.fillColor = SKColor(hex: "#05060f")
        bg.strokeColor = .clear
        overlay.addChild(bg)

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.fontSize = 20
        title.fontColor = SKColor(hex: "#ffd27a")
        overlay.addChild(title)
        tutorialTitleLabel = title

        let body = SKLabelNode(fontNamed: "Menlo")
        body.fontSize = 13
        body.fontColor = SKColor(white: 1, alpha: 0.85)
        body.numberOfLines = 0
        body.preferredMaxLayoutWidth = 300
        body.lineBreakMode = .byWordWrapping
        overlay.addChild(body)
        tutorialBodyLabel = body

        for _ in 0..<5 {
            let dot = SKShapeNode(circleOfRadius: 4)
            dot.strokeColor = .clear
            overlay.addChild(dot)
            tutorialDots.append(dot)
        }

        let skip = SKLabelNode(fontNamed: "Menlo")
        skip.fontSize = 13
        skip.fontColor = SKColor(white: 1, alpha: 0.5)
        overlay.addChild(skip)
        tutorialSkipLabel = skip
        buttons.append(UIButton(node: skip, id: "tutorial-skip"))

        let next = SKShapeNode(rectOf: CGSize(width: 160, height: 46), cornerRadius: 12)
        next.fillColor = SKColor(hex: "#ffd27a")
        next.strokeColor = .clear
        overlay.addChild(next)
        let nextL = SKLabelNode(fontNamed: "Menlo-Bold")
        nextL.fontSize = 14
        nextL.fontColor = SKColor(hex: "#05060f")
        nextL.verticalAlignmentMode = .center
        nextL.horizontalAlignmentMode = .center
        overlay.addChild(nextL)
        tutorialNextBg = next
        tutorialNextLabel = nextL
        buttons.append(UIButton(node: next, id: "tutorial-next"))

        addChild(overlay)
        tutorialOverlay = overlay
    }

    func layoutTutorial(size: CGSize) {
        guard let overlay = tutorialOverlay, let bg = overlay.children.first as? SKShapeNode else { return }
        bg.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        let cx = size.width / 2
        tutorialTitleLabel?.position = CGPoint(x: cx, y: size.height / 2 + 100)
        tutorialBodyLabel?.position = CGPoint(x: cx - 150, y: size.height / 2 + 60)
        for (i, dot) in tutorialDots.enumerated() {
            dot.position = CGPoint(x: cx - 32 + CGFloat(i) * 16, y: size.height / 2 - 70)
        }
        let nextY = max(120 + bottomSafeInset, size.height / 2 - 130)
        tutorialNextBg?.position = CGPoint(x: cx, y: nextY)
        tutorialNextLabel?.position = tutorialNextBg?.position ?? .zero
        tutorialSkipLabel?.position = CGPoint(x: cx, y: nextY - 46)
    }

    func refreshTutorialTexts() {
        tutorialTitleLabel?.text = L.tutorialTitle(tutorialPage)
        tutorialBodyLabel?.text = L.tutorialBody(tutorialPage)
        tutorialNextLabel?.text = tutorialPage < 5 ? L.t("tutorialNext") : L.t("tutorialDone")
        tutorialSkipLabel?.text = L.t("tutorialSkip")
        tutorialSkipLabel?.isHidden = tutorialPage >= 5
        for (i, dot) in tutorialDots.enumerated() {
            dot.fillColor = (i + 1) == tutorialPage ? SKColor(hex: "#ffd27a") : SKColor(white: 1, alpha: 0.25)
        }
    }

    func openTutorial() {
        tutorialPage = 1
        tutorialOverlay?.isHidden = false
        refreshTutorialTexts()
    }

    func advanceTutorial() {
        if tutorialPage < 5 {
            tutorialPage += 1
            refreshTutorialTexts()
        } else {
            closeTutorial()
        }
    }

    func closeTutorial() {
        tutorialOverlay?.isHidden = true
        UserDefaults.standard.set(true, forKey: "ibeyblade.hasSeenTutorial")
    }

    func maybeShowTutorialOnFirstLaunch() {
        guard !UserDefaults.standard.bool(forKey: "ibeyblade.hasSeenTutorial") else { return }
        openTutorial()
    }
}
