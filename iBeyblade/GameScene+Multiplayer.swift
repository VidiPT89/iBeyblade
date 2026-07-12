import SpriteKit
import UIKit

private func mpDouble(_ data: [String: Any], _ key: String) -> CGFloat {
    if let v = data[key] as? Double { return CGFloat(v) }
    if let v = data[key] as? Int { return CGFloat(v) }
    if let v = data[key] as? Int64 { return CGFloat(v) }
    if let v = data[key] as? NSNumber { return CGFloat(truncating: v) }
    return 0
}

private func mpBool(_ data: [String: Any], _ key: String) -> Bool { (data[key] as? Bool) ?? false }
private func mpString(_ data: [String: Any], _ key: String) -> String? { data[key] as? String }

private func mpInt(_ data: [String: Any], _ key: String) -> Int? {
    if let v = data[key] as? Int { return v }
    if let v = data[key] as? Int64 { return Int(v) }
    if let v = data[key] as? Double { return Int(v) }
    if let v = data[key] as? NSNumber { return v.intValue }
    return nil
}

/// Glue between the game engine (GameScene/GameScene+Physics/GameScene+UI) and
/// MultiplayerService. Builds and drives the Online lobby (Create Room / Join Room / Quick
/// Play), and — once a match starts — streams/applies battle state so a "host" and "guest"
/// device can share one live match. See MultiplayerService.swift for why the host is
/// authoritative and the guest only renders incoming snapshots.
///
/// The top picker is shown up front, alongside Create/Join/Quick Play (in the row the single
/// Start button normally occupies) — so picking a top and committing to a room happen as one
/// step, with no separate "opponent joined, now pick, now confirm ready" handshake.
extension GameScene {

    var isOnline: Bool { matchMode == .online }
    var isAnyMultiplayer: Bool { isLocal2P || isOnline }
    var mp: MultiplayerService { MultiplayerService.shared }

    // MARK: Lobby UI construction

    private func makePill(strokeHex: String = "#4d78ff", width: CGFloat = 220, fontSize: CGFloat = 13) -> (SKShapeNode, SKLabelNode) {
        let b = SKShapeNode(rectOf: CGSize(width: width, height: 38), cornerRadius: 10)
        b.strokeColor = SKColor(hex: strokeHex)
        b.lineWidth = 1.5
        b.fillColor = SKColor(white: 1, alpha: 0.06)
        let l = SKLabelNode(fontNamed: "Menlo-Bold")
        l.fontSize = fontSize
        l.fontColor = .white
        l.verticalAlignmentMode = .center
        l.horizontalAlignmentMode = .center
        return (b, l)
    }

    func buildLobbyOverlay() {
        guard let overlay = menuOverlay else { return }

        // Waiting panel — reuses the top-picker's rect, shown only once the host has committed
        // (Create Room / Quick Play with no one else waiting) and their top is already locked in.
        let panel = SKNode()
        panel.isHidden = true
        overlay.addChild(panel)
        lobbyPanel = panel

        let bg = SKShapeNode()
        bg.fillColor = SKColor(white: 1, alpha: 0.035)
        bg.strokeColor = SKColor(hex: "#4d78ff").withAlphaComponent(0.45)
        bg.lineWidth = 1
        panel.addChild(bg)
        lobbyBg = bg

        let waitingLabel = SKLabelNode(fontNamed: "Menlo")
        waitingLabel.fontSize = 13
        waitingLabel.fontColor = SKColor(white: 1, alpha: 0.75)
        panel.addChild(waitingLabel)
        lobbyWaitingLabel = waitingLabel

        let codeLabel = SKLabelNode(fontNamed: "Menlo-Bold")
        codeLabel.fontSize = 34
        codeLabel.fontColor = SKColor(hex: "#ffd27a")
        panel.addChild(codeLabel)
        lobbyCodeLabel = codeLabel

        let (cancelBg, cancelLabel) = makePill(strokeHex: "#ff5a3c", width: 160)
        panel.addChild(cancelBg); panel.addChild(cancelLabel)
        lobbyCancelBg = cancelBg; lobbyCancelLabel = cancelLabel
        buttons.append(UIButton(node: cancelBg, id: "lobby-cancel"))

        // Create / Join / Quick Play — sit in the same row the single Start button uses, visible
        // only while in Online mode and not yet committed to a room.
        let (createBg, createLabel) = makePill(width: 104, fontSize: 11)
        overlay.addChild(createBg); overlay.addChild(createLabel)
        lobbyCreateBg = createBg; lobbyCreateLabel = createLabel
        buttons.append(UIButton(node: createBg, id: "lobby-create"))

        let (joinBg, joinLabel) = makePill(width: 104, fontSize: 11)
        overlay.addChild(joinBg); overlay.addChild(joinLabel)
        lobbyJoinBg = joinBg; lobbyJoinLabel = joinLabel
        buttons.append(UIButton(node: joinBg, id: "lobby-join"))

        let (quickBg, quickLabel) = makePill(width: 104, fontSize: 11)
        overlay.addChild(quickBg); overlay.addChild(quickLabel)
        lobbyQuickBg = quickBg; lobbyQuickLabel = quickLabel
        buttons.append(UIButton(node: quickBg, id: "lobby-quick"))

        let status = SKLabelNode(fontNamed: "Menlo")
        status.fontSize = 11
        status.fontColor = SKColor(hex: "#ff5a5a")
        status.numberOfLines = 2
        status.preferredMaxLayoutWidth = 320
        status.isHidden = true
        overlay.addChild(status)
        lobbyStatusLabel = status
    }

    func layoutLobbyPanel(size: CGSize) {
        guard lobbyBg != nil else { return }
        let cx = size.width / 2
        let top = topPanelTopY
        let bottom = topPanelBottomY
        guard top > bottom else { return }
        lobbyBg?.path = CGPath(
            roundedRect: CGRect(x: cx - 182, y: bottom, width: 364, height: top - bottom),
            cornerWidth: 18, cornerHeight: 18, transform: nil
        )
        let midY = (top + bottom) / 2
        lobbyWaitingLabel?.position = CGPoint(x: cx, y: top - 34)
        lobbyCodeLabel?.position = CGPoint(x: cx, y: midY + 10)
        lobbyCancelBg?.position = CGPoint(x: cx, y: midY - 60)
        lobbyCancelLabel?.position = lobbyCancelBg?.position ?? .zero

        guard let start = buttons.first(where: { $0.id == "start-tap" })?.node else { return }
        let rowY = start.position.y
        let spacing: CGFloat = 112
        lobbyCreateBg?.position = CGPoint(x: cx - spacing, y: rowY)
        lobbyCreateLabel?.position = lobbyCreateBg?.position ?? .zero
        lobbyJoinBg?.position = CGPoint(x: cx, y: rowY)
        lobbyJoinLabel?.position = lobbyJoinBg?.position ?? .zero
        lobbyQuickBg?.position = CGPoint(x: cx + spacing, y: rowY)
        lobbyQuickLabel?.position = lobbyQuickBg?.position ?? .zero
        lobbyStatusLabel?.position = CGPoint(x: cx, y: rowY - 36)
    }

    /// Hides (or restores) the top-picker cards and paging controls — used once the online lobby
    /// has moved on from "pick a top" to "waiting for opponent" or the battle itself.
    func setTopPickerHidden(_ hidden: Bool) {
        topPanel?.isHidden = hidden
        topSectionHeader?.isHidden = hidden
        for card in topCards {
            card.bg.isHidden = hidden
            card.name.isHidden = hidden
            card.type.isHidden = hidden
            card.stats.isHidden = hidden
        }
        pagePrevButton?.isHidden = hidden
        pageNextButton?.isHidden = hidden
        for dot in pageDots { dot.isHidden = hidden }
    }

    /// Toggles between the single "TAP TO START" button (every other mode) and the Create/Join/
    /// Quick Play trio (Online mode, before committing to a room).
    private func showLobbyActionRow(_ show: Bool) {
        lobbyCreateBg?.isHidden = !show
        lobbyCreateLabel?.isHidden = !show
        lobbyJoinBg?.isHidden = !show
        lobbyJoinLabel?.isHidden = !show
        lobbyQuickBg?.isHidden = !show
        lobbyQuickLabel?.isHidden = !show
        buttons.first(where: { $0.id == "start-tap" })?.node.isHidden = show
        startLabel?.isHidden = show
    }

    func resetLobbyUI() {
        lobbyPanel?.isHidden = true
        mpClearIdleStatus()
        lobbyStatusLabel?.isHidden = true
        setTopPickerHidden(false)
        showLobbyActionRow(true)
    }

    /// Called whenever leaving Online mode (switching to vs CPU/vs Player, or back to the menu) —
    /// restores the normal single Start button and hides any lobby-specific UI.
    func hideLobbyUI() {
        showLobbyActionRow(false)
        lobbyPanel?.isHidden = true
        lobbyStatusLabel?.isHidden = true
    }

    /// Host-only: shown right after Create Room / Quick Play — the host's top was already
    /// submitted with the room, so there's nothing left to pick, just wait for someone to join.
    private func mpShowWaiting(code: String) {
        setTopPickerHidden(true)
        showLobbyActionRow(false)
        lobbyStatusLabel?.isHidden = true
        lobbyPanel?.isHidden = false
        lobbyCodeLabel?.text = code
    }

    private func mpErrorMessage(_ error: Error) -> String {
        guard let mpErr = error as? MPError else { return L.t("onlineNotConfigured") }
        switch mpErr {
        case .notConfigured, .createFailed: return L.t("onlineNotConfigured")
        case .roomNotFound: return L.t("roomNotFound")
        case .roomFull: return L.t("roomFull")
        case .roomFinished: return L.t("roomFinished")
        case .lobbyFull: return L.t("lobbyFull")
        }
    }

    private func mpShowIdleError(_ error: Error) {
        lobbyStatusLabel?.text = mpErrorMessage(error)
        lobbyStatusLabel?.isHidden = false
    }

    private func mpClearIdleStatus() {
        lobbyStatusLabel?.text = ""
        lobbyStatusLabel?.isHidden = true
    }

    // MARK: Lobby button handlers

    func mpTapCreate() {
        guard MultiplayerService.configured else { mpShowIdleError(MPError.notConfigured); return }
        mpClearIdleStatus()
        let topIndex = playerPresetIndex
        Task { @MainActor in
            do {
                let res = try await self.mp.createRoom(topIndex: topIndex)
                self.onlineActive = true
                self.mpShowWaiting(code: res.code)
            } catch {
                self.mpShowIdleError(error)
            }
        }
    }

    func mpTapJoin() {
        guard MultiplayerService.configured else { mpShowIdleError(MPError.notConfigured); return }
        presentJoinCodeAlert()
    }

    func mpTapQuickPlay() {
        guard MultiplayerService.configured else { mpShowIdleError(MPError.notConfigured); return }
        mpClearIdleStatus()
        let topIndex = playerPresetIndex
        Task { @MainActor in
            do {
                let res = try await self.mp.quickPlay(topIndex: topIndex)
                self.onlineActive = true
                if res.isHost {
                    self.mpShowWaiting(code: res.code)
                } else {
                    self.mpBeginOnlineBattle(res.data)
                }
            } catch {
                self.mpShowIdleError(error)
            }
        }
    }

    func mpTapCancel() {
        leaveOnlineRoom()
        resetLobbyUI()
    }

    private func topViewController() -> UIViewController? {
        guard let root = view?.window?.rootViewController else { return nil }
        var top = root
        while let presented = top.presentedViewController { top = presented }
        return top
    }

    private func presentJoinCodeAlert() {
        guard let vc = topViewController() else { return }
        let alert = UIAlertController(title: L.t("joinRoomBtn"), message: nil, preferredStyle: .alert)
        alert.addTextField { tf in
            tf.placeholder = L.t("roomCodePlaceholder")
            tf.autocapitalizationType = .allCharacters
            tf.autocorrectionType = .no
        }
        alert.addAction(UIAlertAction(title: L.t("cancelBtn"), style: .cancel))
        alert.addAction(UIAlertAction(title: L.t("joinBtn"), style: .default) { [weak self, weak alert] _ in
            guard let self else { return }
            let code = (alert?.textFields?.first?.text ?? "").trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
            guard !code.isEmpty else { return }
            let topIndex = self.playerPresetIndex
            self.mpClearIdleStatus()
            Task { @MainActor in
                do {
                    let data = try await self.mp.joinRoom(code, topIndex: topIndex)
                    self.onlineActive = true
                    self.mpBeginOnlineBattle(data) // the host's top is already in the room doc — start right away
                } catch {
                    self.mpShowIdleError(error)
                }
            }
        })
        vc.present(alert, animated: true)
    }

    func leaveOnlineRoom() {
        if onlineActive { mp.leaveRoom() }
        onlineActive = false
        onlineBattleStarted = false
    }

    // MARK: Networking callbacks

    func mpWireCallbacks() {
        mp.onRoomUpdate = { [weak self] data in self?.mpHandleRoomUpdate(data) }
        mp.onRemoteState = { [weak self] data in self?.mpApplyRemoteState(data) }
        mp.onRemoteAction = { [weak self] type, payload in self?.mpApplyRemoteAction(type, payload: payload) }
        mp.onError = { error in print("Multiplayer error: \(error)") }
    }

    private func mpHandleRoomUpdate(_ data: [String: Any]) {
        guard onlineActive else { return }
        let roomPhase = mpString(data, "phase") ?? "picking"

        if mp.role == "host", roomPhase == "picking",
           mpInt(data, "hostTopIndex") != nil, mpInt(data, "guestTopIndex") != nil {
            mpBeginOnlineBattle(data)
            return
        }

        if roomPhase == "launch", !onlineBattleStarted {
            mpBeginOnlineBattle(data)
        } else if roomPhase == "launch", phase != .launch, phase != .battle {
            if mp.role == "guest" {
                roundNumber = mpInt(data, "roundNumber") ?? roundNumber
                startRound()
            }
        }

        if roomPhase == "battle", phase != .battle, mp.role == "guest" {
            phase = .battle
            launchOverlay?.isHidden = true
        }

        if mp.role == "guest", onlineBattleStarted {
            if roomPhase == "roundResult", phase != .roundResult {
                phase = .roundResult
                playerWins = mpInt(data, "guestWins") ?? 0
                cpuWins = mpInt(data, "hostWins") ?? 0
                let winnerIsPlayer = mpString(data, "lastRoundWinner") == "guest"
                showRoundResultOverlay(winner: winnerIsPlayer ? player : cpu)
            }
            if roomPhase == "matchOver", phase != .matchOver {
                phase = .matchOver
                playerWins = mpInt(data, "guestWins") ?? 0
                cpuWins = mpInt(data, "hostWins") ?? 0
                showMatchOverOverlay()
            }
        }
    }

    /// First-round setup: creates local entities from the room's confirmed top picks and starts
    /// the round. Called by both sides once both `hostTopIndex`/`guestTopIndex` are known — for
    /// the guest this fires immediately on a successful join/quick-play; for the host it fires
    /// once the room listener sees a guest has claimed the room.
    private func mpBeginOnlineBattle(_ data: [String: Any]) {
        onlineBattleStarted = true
        let hostTop = mpInt(data, "hostTopIndex") ?? 0
        let guestTop = mpInt(data, "guestTopIndex") ?? 1
        playerPresetIndex = mp.role == "host" ? hostTop : guestTop
        cpuPresetIndex = mp.role == "host" ? guestTop : hostTop
        rebuildEntities()
        playerWins = mp.role == "host" ? (mpInt(data, "hostWins") ?? 0) : (mpInt(data, "guestWins") ?? 0)
        cpuWins = mp.role == "host" ? (mpInt(data, "guestWins") ?? 0) : (mpInt(data, "hostWins") ?? 0)
        roundNumber = mpInt(data, "roundNumber") ?? 1
        startRound()
        if mp.role == "host" { mp.updateRoom(["phase": "launch"]) }
    }

    func checkOnlineBothLaunched() {
        guard mp.role == "host" else { return } // guest's phase mirrors the host's room updates instead
        guard player.launched, cpu.launched else { return }
        phase = .battle
        launchOverlay?.isHidden = true
        mp.updateRoom(["phase": "battle"])
    }

    // MARK: State + action sync

    private func koReasonString(_ r: KOReason) -> String {
        switch r {
        case .spinOut: return "spinOut"
        case .ringOut: return "ringOut"
        case .burst: return "burst"
        }
    }

    private func koReason(from raw: String) -> KOReason? {
        switch raw {
        case "spinOut": return .spinOut
        case "ringOut": return .ringOut
        case "burst": return .burst
        default: return nil
        }
    }

    private func mpApplySnapshotToEntity(_ e: BeybladeEntity, node: BeybladeNode, data: [String: Any], prefix: String) {
        let wasAlive = e.isAlive
        e.position = CGPoint(x: mpDouble(data, prefix + "X"), y: mpDouble(data, prefix + "Y"))
        e.velocity = CGVector(dx: mpDouble(data, prefix + "Vx"), dy: mpDouble(data, prefix + "Vy"))
        e.spinAngle = mpDouble(data, prefix + "SpinAngle")
        e.stamina = mpDouble(data, prefix + "Stamina")
        e.specialGauge = mpDouble(data, prefix + "SpecialGauge")
        e.launched = mpBool(data, prefix + "Launched")
        e.isAlive = mpBool(data, prefix + "Alive")
        if wasAlive, !e.isAlive, e.koReason == nil, let raw = mpString(data, prefix + "KoReason"), let reason = koReason(from: raw) {
            e.koReason = reason
            node.playKOAnimation(reason: reason)
        }
    }

    private func mpApplyRemoteState(_ data: [String: Any]) {
        guard player != nil, cpu != nil else { return }
        mpApplySnapshotToEntity(player, node: playerNode, data: data, prefix: "guest")
        mpApplySnapshotToEntity(cpu, node: cpuNode, data: data, prefix: "host")
        let sd = mpBool(data, "suddenDeathActive")
        if sd, !suddenDeathActive { showSuddenDeathBanner() }
        suddenDeathActive = sd
        battleElapsed = mpDouble(data, "battleElapsed")
    }

    private func mpApplyRemoteAction(_ type: String, payload: [String: Any]) {
        guard player != nil, cpu != nil else { return }
        if type == "launch" {
            guard !cpu.launched else { return }
            let origin = CGPoint(x: mpDouble(payload, "originX"), y: mpDouble(payload, "originY"))
            let direction = CGVector(dx: mpDouble(payload, "dirX"), dy: mpDouble(payload, "dirY"))
            let power = mpDouble(payload, "power")
            cpu.launch(from: origin, direction: direction, power: power)
            cpuNode.playLaunchPulse()
            SoundEngine.shared.playLaunch()
            checkOnlineBothLaunched()
        } else if type == "special" {
            fireSpecialMove(for: cpu, node: cpuNode)
        }
    }

    func mpPushHostState() {
        guard player != nil, cpu != nil else { return }
        var snapshot: [String: Any] = [
            "hostX": player.position.x, "hostY": player.position.y,
            "hostVx": player.velocity.dx, "hostVy": player.velocity.dy,
            "hostSpinAngle": player.spinAngle, "hostStamina": player.stamina,
            "hostSpecialGauge": player.specialGauge,
            "hostAlive": player.isAlive, "hostLaunched": player.launched,
            "guestX": cpu.position.x, "guestY": cpu.position.y,
            "guestVx": cpu.velocity.dx, "guestVy": cpu.velocity.dy,
            "guestSpinAngle": cpu.spinAngle, "guestStamina": cpu.stamina,
            "guestSpecialGauge": cpu.specialGauge,
            "guestAlive": cpu.isAlive, "guestLaunched": cpu.launched,
            "battleElapsed": battleElapsed, "suddenDeathActive": suddenDeathActive,
        ]
        if let r = player.koReason { snapshot["hostKoReason"] = koReasonString(r) }
        if let r = cpu.koReason { snapshot["guestKoReason"] = koReasonString(r) }
        mp.pushState(snapshot)
    }
}
