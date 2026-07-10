import CoreGraphics

enum TopType: String, CaseIterable {
    case attack, defense, stamina, balance
}

enum SpinDirection {
    case cw, ccw
}

struct TopPreset: Identifiable {
    let id: String
    let name: String
    let type: TopType
    let bodyHex: String
    let glowHex: String
    /// 0...1 — how hard it hits on collision.
    let attack: CGFloat
    /// 0...1 — how much knockback/stamina loss it resists.
    let defense: CGFloat
    /// 0...1 — how slowly its spin stamina drains (1 = barely drains).
    let stamina: CGFloat
    let spin: SpinDirection
    let radius: CGFloat
    /// 0...1 — how strongly it steers toward the opponent instead of wandering.
    let aggression: CGFloat
}

enum BeybladePresets {
    static let all: [TopPreset] = [
        TopPreset(
            id: "inferno-fang", name: "Inferno Fang", type: .attack,
            bodyHex: "#ff5a3c", glowHex: "#ff8a40",
            attack: 0.92, defense: 0.30, stamina: 0.45,
            spin: .cw, radius: 34, aggression: 0.9
        ),
        TopPreset(
            id: "titan-shell", name: "Titan Shell", type: .defense,
            bodyHex: "#3ca0ff", glowHex: "#6fd8ff",
            attack: 0.32, defense: 0.94, stamina: 0.55,
            spin: .ccw, radius: 38, aggression: 0.25
        ),
        TopPreset(
            id: "chrono-drift", name: "Chrono Drift", type: .stamina,
            bodyHex: "#3cffb0", glowHex: "#7dffd0",
            attack: 0.38, defense: 0.42, stamina: 0.95,
            spin: .cw, radius: 32, aggression: 0.35
        ),
        TopPreset(
            id: "vortex-core", name: "Vortex Core", type: .balance,
            bodyHex: "#b06bff", glowHex: "#d9a8ff",
            attack: 0.62, defense: 0.62, stamina: 0.62,
            spin: .ccw, radius: 35, aggression: 0.55
        ),
    ]
}
