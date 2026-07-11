import Foundation
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

enum MPError: Error {
    case notConfigured, roomNotFound, roomFull, roomFinished, createFailed, lobbyFull
}

struct MPQuickPlayResult {
    let code: String
    let isHost: Bool
}

/// Networking layer for Online mode: rooms, live battle state, input actions and presence over
/// Firestore. Mirrors beyblade-multiplayer.js's role on web — GameScene never talks to Firestore
/// directly, only through this service's callbacks.
///
/// Unlike a turn-based game, a Beyblade battle is a continuous physics simulation with per-frame
/// randomness — there's no discrete "move" to replay. Instead the room's "host" runs the
/// authoritative simulation locally and streams state snapshots; the "guest" renders those
/// snapshots instead of simulating physics itself, and sends its own input (launch / special) as
/// small action events for the host to apply. This sidesteps needing bit-identical floating point
/// determinism across three different runtimes (Swift/JS/Kotlin).
@MainActor
final class MultiplayerService: ObservableObject {
    static let shared = MultiplayerService()
    static var configured: Bool {
        guard let app = FirebaseApp.app() else { return false }
        return app.options.apiKey != nil && app.options.apiKey != "REPLACE_ME"
    }

    @Published private(set) var roomCode: String? = nil
    @Published private(set) var opponentOnline: Bool = false

    var onRoomUpdate: (([String: Any]) -> Void)? = nil
    var onOpponentJoined: (() -> Void)? = nil
    var onRemoteState: (([String: Any]) -> Void)? = nil
    var onRemoteAction: ((String, [String: Any]) -> Void)? = nil
    var onError: ((Error) -> Void)? = nil

    private(set) var myUid: String? = nil
    private(set) var role: String? = nil // "host" | "guest"
    var isHost: Bool { role == "host" }

    private var roomListener: ListenerRegistration? = nil
    private var stateListener: ListenerRegistration? = nil
    private var actionsListener: ListenerRegistration? = nil
    private var heartbeatTimer: Timer? = nil
    private var staleTimer: Timer? = nil
    private var lastOppPresence: [String: Any]? = nil
    private var sawGuest = false
    private var appliedActionIds: Set<String> = []
    private var lastStatePush: Date = .distantPast

    private let roomsCollection = "beyblade_rooms"
    private let codeAlphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789") // no 0/O/1/I/L
    private let lobbyCodes = ["LOBBYA", "LOBBYB", "LOBBYC"]
    private let presenceHeartbeat: TimeInterval = 20
    private let presenceStale: TimeInterval = 45
    private let minStatePushInterval: TimeInterval = 0.09

    private init() {}

    private func db() -> Firestore { Firestore.firestore() }

    private func randomCode() -> String {
        String((0..<6).map { _ in codeAlphabet.randomElement()! })
    }

    @discardableResult
    private func ensureSignedIn() async throws -> String {
        if let uid = Auth.auth().currentUser?.uid { return uid }
        let result = try await Auth.auth().signInAnonymously()
        return result.user.uid
    }

    private func freshRoomDoc(hostUid: String) -> [String: Any] {
        [
            "hostUid": hostUid, "guestUid": NSNull(),
            "status": "waiting", "phase": "picking",
            "hostTopIndex": NSNull(), "guestTopIndex": NSNull(),
            "hostWins": 0, "guestWins": 0, "roundNumber": 1,
            "result": NSNull(),
            "createdAt": FieldValue.serverTimestamp(), "updatedAt": FieldValue.serverTimestamp(),
            "hostPresence": ["online": true, "lastSeen": FieldValue.serverTimestamp()],
            "guestPresence": ["online": false, "lastSeen": FieldValue.serverTimestamp()],
        ]
    }

    @discardableResult
    private func enterRoom(code: String, data: [String: Any]) async throws -> String {
        let uid = myUid!
        let hostUid = data["hostUid"] as? String
        let guestUid = data["guestUid"] as? String
        let status = data["status"] as? String

        if hostUid == uid {
            role = "host"
        } else if guestUid == uid {
            role = "guest"
        } else if guestUid == nil {
            if status == "finished" { throw MPError.roomFinished }
            do {
                try await db().collection(roomsCollection).document(code).updateData([
                    "guestUid": uid, "status": "active",
                    "guestPresence": ["online": true, "lastSeen": FieldValue.serverTimestamp()],
                    "updatedAt": FieldValue.serverTimestamp(),
                ])
            } catch {
                throw MPError.roomFull
            }
            role = "guest"
        } else {
            throw MPError.roomFull
        }

        roomCode = code
        sawGuest = guestUid != nil || role == "guest"
        opponentOnline = false
        lastOppPresence = nil
        appliedActionIds = []
        attachRoomListener()
        attachStateListener()
        attachActionsListener()
        startHeartbeat()
        return code
    }

    func createRoom() async throws -> String {
        guard Self.configured else { throw MPError.notConfigured }
        let uid = try await ensureSignedIn()
        myUid = uid
        for _ in 0..<6 {
            let code = randomCode()
            let ref = db().collection(roomsCollection).document(code)
            guard let existing = try? await ref.getDocument(), !existing.exists else { continue }
            do {
                try await ref.setData(freshRoomDoc(hostUid: uid))
            } catch { continue }
            return try await joinRoom(code)
        }
        throw MPError.createFailed
    }

    func joinRoom(_ code: String) async throws -> String {
        guard Self.configured else { throw MPError.notConfigured }
        let uid = try await ensureSignedIn()
        myUid = uid
        let ref = db().collection(roomsCollection).document(code)
        guard let snap = try? await ref.getDocument(), snap.exists, let data = snap.data() else {
            throw MPError.roomNotFound
        }
        return try await enterRoom(code: code, data: data)
    }

    /// Joins (or claims/recycles) the first available room in the fixed public lobby pool, so two
    /// people can play without coordinating a code: whoever arrives first waits as host, whoever
    /// arrives second joins immediately as guest and the match starts right away.
    func quickPlay() async throws -> MPQuickPlayResult {
        guard Self.configured else { throw MPError.notConfigured }
        let uid = try await ensureSignedIn()
        myUid = uid
        for code in lobbyCodes {
            let ref = db().collection(roomsCollection).document(code)
            let snap = try? await ref.getDocument()
            let data: [String: Any]? = (snap?.exists == true) ? snap?.data() : nil

            if data == nil || (data?["status"] as? String) == "finished" {
                do {
                    try await ref.setData(freshRoomDoc(hostUid: uid))
                } catch { continue } // someone else claimed/recycled this slot first — try the next one
                try await enterRoom(code: code, data: freshRoomDoc(hostUid: uid))
                return MPQuickPlayResult(code: code, isHost: true)
            }
            if let data, (data["hostUid"] as? String) == uid || (data["guestUid"] as? String) == uid {
                try await enterRoom(code: code, data: data) // reconnecting to my own quick-play game
                return MPQuickPlayResult(code: code, isHost: role == "host")
            }
            if let data, (data["status"] as? String) == "waiting", (data["guestUid"] as? String) == nil {
                do {
                    try await enterRoom(code: code, data: data)
                } catch { continue }
                return MPQuickPlayResult(code: code, isHost: false)
            }
            // Occupied by two other players — try reclaiming it in case it's actually an
            // abandoned game. The security rules are the real arbiter: this write only
            // succeeds if both presences are genuinely stale.
            do {
                try await ref.setData(freshRoomDoc(hostUid: uid))
            } catch { continue } // still genuinely occupied — try the next pool slot
            try await enterRoom(code: code, data: freshRoomDoc(hostUid: uid))
            return MPQuickPlayResult(code: code, isHost: true)
        }
        throw MPError.lobbyFull
    }

    private func attachRoomListener() {
        roomListener?.remove()
        guard let code = roomCode else { return }
        roomListener = db().collection(roomsCollection).document(code).addSnapshotListener { [weak self] snap, _ in
            guard let self, let data = snap?.data() else { return }
            Task { @MainActor in self.handleRoomUpdate(data) }
        }
        staleTimer?.invalidate()
        staleTimer = Timer.scheduledTimer(withTimeInterval: 8, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.recomputePresence() }
        }
    }

    private func handleRoomUpdate(_ data: [String: Any]) {
        let guestUid = data["guestUid"] as? String
        if guestUid != nil, !sawGuest {
            sawGuest = true
            onOpponentJoined?()
        }
        lastOppPresence = (role == "host" ? data["guestPresence"] : data["hostPresence"]) as? [String: Any]
        recomputePresence()
        onRoomUpdate?(data)
    }

    private func recomputePresence() {
        var online = false
        if let p = lastOppPresence, (p["online"] as? Bool) == true, let ts = p["lastSeen"] as? Timestamp {
            online = Date().timeIntervalSince(ts.dateValue()) < presenceStale
        }
        if online != opponentOnline { opponentOnline = online }
    }

    private func attachStateListener() {
        stateListener?.remove()
        guard let code = roomCode else { return }
        stateListener = db().collection(roomsCollection).document(code).collection("state").document("live")
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let data = snap?.data() else { return }
                Task { @MainActor in
                    guard self.role == "guest" else { return } // host is authoritative; it doesn't consume its own stream
                    self.onRemoteState?(data)
                }
            }
    }

    private func attachActionsListener() {
        actionsListener?.remove()
        guard let code = roomCode else { return }
        actionsListener = db().collection(roomsCollection).document(code).collection("actions")
            .order(by: "sentAt")
            .addSnapshotListener { [weak self] snap, _ in
                guard let self, let changes = snap?.documentChanges else { return }
                Task { @MainActor in
                    for change in changes where change.type == .added {
                        self.handleActionDoc(id: change.document.documentID, data: change.document.data())
                    }
                }
            }
    }

    private func handleActionDoc(id: String, data: [String: Any]) {
        guard !appliedActionIds.contains(id) else { return }
        appliedActionIds.insert(id)
        guard (data["by"] as? String) != myUid else { return } // my own action, applied locally already
        guard let type = data["type"] as? String else { return }
        onRemoteAction?(type, data)
    }

    private func presenceField() -> String { role == "host" ? "hostPresence" : "guestPresence" }

    private func sendHeartbeat(online: Bool) {
        guard let code = roomCode else { return }
        db().collection(roomsCollection).document(code).updateData([
            presenceField(): ["online": online, "lastSeen": FieldValue.serverTimestamp()],
            "updatedAt": FieldValue.serverTimestamp(),
        ])
    }

    private func startHeartbeat() {
        sendHeartbeat(online: true)
        heartbeatTimer?.invalidate()
        heartbeatTimer = Timer.scheduledTimer(withTimeInterval: presenceHeartbeat, repeats: true) { [weak self] _ in
            Task { @MainActor in self?.sendHeartbeat(online: true) }
        }
    }

    func updateRoom(_ fields: [String: Any]) {
        guard let code = roomCode else { return }
        var withTimestamp = fields
        withTimestamp["updatedAt"] = FieldValue.serverTimestamp()
        db().collection(roomsCollection).document(code).updateData(withTimestamp)
    }

    /// Host-only: streams a full battle snapshot, throttled so Firestore write volume stays sane.
    func pushState(_ snapshot: [String: Any]) {
        guard let code = roomCode, role == "host" else { return }
        let now = Date()
        guard now.timeIntervalSince(lastStatePush) >= minStatePushInterval else { return }
        lastStatePush = now
        var withSeq = snapshot
        withSeq["seq"] = now.timeIntervalSince1970
        db().collection(roomsCollection).document(code).collection("state").document("live").setData(withSeq)
    }

    func sendAction(_ type: String, payload: [String: Any]) {
        guard let code = roomCode, let uid = myUid else { return }
        var doc = payload
        doc["type"] = type
        doc["by"] = uid
        doc["sentAt"] = FieldValue.serverTimestamp()
        db().collection(roomsCollection).document(code).collection("actions").addDocument(data: doc) { [weak self] error in
            if let error { Task { @MainActor in self?.onError?(error) } }
        }
    }

    func leaveRoom() {
        sendHeartbeat(online: false)
        roomListener?.remove(); roomListener = nil
        stateListener?.remove(); stateListener = nil
        actionsListener?.remove(); actionsListener = nil
        heartbeatTimer?.invalidate(); heartbeatTimer = nil
        staleTimer?.invalidate(); staleTimer = nil
        roomCode = nil
        role = nil
        opponentOnline = false
        lastOppPresence = nil
        sawGuest = false
        appliedActionIds = []
    }
}
