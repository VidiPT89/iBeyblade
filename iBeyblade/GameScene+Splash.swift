import SpriteKit

/// A short, skippable intro presentation shown once when the app launches:
/// the title reveals, a small top spins up with orbiting sparks, then the
/// developer credit fades in before handing off to the main menu.
extension GameScene {

    func buildSplash() {
        let splash = SKNode()
        splash.zPosition = 200
        let bg = SKShapeNode()
        bg.fillColor = SKColor(hex: "#05060f")
        bg.strokeColor = .clear
        splash.addChild(bg)
        splashBg = bg
        buttons.insert(UIButton(node: bg, id: "splash-tap"), at: 0)

        let title = SKLabelNode(fontNamed: "Menlo-Bold")
        title.text = "iBEYBLADE"
        title.fontSize = 32
        title.fontColor = SKColor(hex: "#ffd27a")
        title.alpha = 0
        title.setScale(0.8)
        splash.addChild(title)
        splashTitle = title

        let top = SKShapeNode(circleOfRadius: 22)
        top.fillColor = SKColor(white: 0.08, alpha: 1)
        top.strokeColor = SKColor(hex: "#ff8a40")
        top.lineWidth = 3
        top.glowWidth = 8
        top.alpha = 0
        splash.addChild(top)
        splashTop = top

        let fins = SKNode()
        for i in 0..<6 {
            let a0 = CGFloat(i) * .pi / 3
            let path = CGMutablePath()
            let outer: CGFloat = 21, inner: CGFloat = 11
            path.move(to: CGPoint(x: cos(a0) * outer, y: sin(a0) * outer))
            path.addLine(to: CGPoint(x: cos(a0 + 0.32) * inner, y: sin(a0 + 0.32) * inner))
            path.addLine(to: CGPoint(x: cos(a0 - 0.32) * inner, y: sin(a0 - 0.32) * inner))
            path.closeSubpath()
            let fin = SKShapeNode(path: path)
            fin.fillColor = SKColor(hex: "#ff5a3c")
            fin.strokeColor = .clear
            fins.addChild(fin)
        }
        top.addChild(fins)
        splashFins = fins

        let credit = SKLabelNode(fontNamed: "Menlo")
        credit.fontSize = 13
        credit.fontColor = SKColor(white: 1, alpha: 0.75)
        credit.text = "Developed by David Arsénio Martins"
        credit.alpha = 0
        splash.addChild(credit)
        splashCredit = credit

        let link = SKLabelNode(fontNamed: "Menlo-Bold")
        link.fontSize = 14
        link.fontColor = SKColor(hex: "#6fd8ff")
        link.text = "ividi.dev"
        link.alpha = 0
        splash.addChild(link)
        splashLink = link
        buttons.insert(UIButton(node: link, id: "open-website"), at: 0)

        let skip = SKLabelNode(fontNamed: "Menlo")
        skip.fontSize = 12
        skip.fontColor = SKColor(white: 1, alpha: 0.4)
        skip.alpha = 0
        splash.addChild(skip)
        splashSkipLabel = skip

        addChild(splash)
        splashOverlay = splash
    }

    func layoutSplash(size: CGSize) {
        guard let bg = splashBg else { return }
        bg.path = CGPath(rect: CGRect(x: 0, y: 0, width: size.width, height: size.height), transform: nil)
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        splashTitle?.position = CGPoint(x: center.x, y: center.y + 60)
        splashTop?.position = CGPoint(x: center.x, y: center.y)
        splashCredit?.position = CGPoint(x: center.x, y: center.y - 70)
        splashLink?.position = CGPoint(x: center.x, y: center.y - 94)
        splashSkipLabel?.position = CGPoint(x: center.x, y: 40)
    }

    func playSplash() {
        guard let overlay = splashOverlay else { return }
        let title = splashTitle, top = splashTop, fins = splashFins
        let credit = splashCredit, link = splashLink, skip = splashSkipLabel

        title?.run(.group([.fadeIn(withDuration: 0.5), .scale(to: 1.0, duration: 0.5)]))

        top?.alpha = 1
        top?.setScale(0.3)
        top?.run(.sequence([.wait(forDuration: 0.15), .scale(to: 1.0, duration: 0.4)]))
        fins?.run(.repeatForever(.rotate(byAngle: -.pi * 2, duration: 0.5)))

        let creditDelay = 1.6
        credit?.run(.sequence([.wait(forDuration: creditDelay), .fadeAlpha(to: 0.75, duration: 0.5)]))
        link?.run(.sequence([.wait(forDuration: creditDelay), .fadeAlpha(to: 1, duration: 0.5)]))
        skip?.text = L.current == .pt ? "toca para saltar" : "tap to skip"
        skip?.run(.sequence([.wait(forDuration: 0.6), .fadeAlpha(to: 0.4, duration: 0.4)]))

        overlay.run(.sequence([.wait(forDuration: 3.6), .run { [weak self] in self?.closeSplash() }]))
    }

    func closeSplash() {
        guard let overlay = splashOverlay, !overlay.isHidden else { return }
        overlay.removeAllActions()
        overlay.run(.sequence([.fadeOut(withDuration: 0.25), .run { overlay.isHidden = true }]))
    }
}
