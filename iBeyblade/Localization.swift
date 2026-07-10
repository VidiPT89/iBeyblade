import Foundation

enum Lang: String {
    case pt, en
}

enum L {
    static var current: Lang = {
        if let saved = UserDefaults.standard.string(forKey: "ibeyblade.lang"), let l = Lang(rawValue: saved) {
            return l
        }
        return Locale.preferredLanguages.first?.hasPrefix("pt") == true ? .pt : .en
    }() {
        didSet { UserDefaults.standard.set(current.rawValue, forKey: "ibeyblade.lang") }
    }

    static func toggle() { current = current == .pt ? .en : .pt }

    static let strings: [Lang: [String: String]] = [
        .pt: [
            "title": "iBeyblade",
            "tagline": "Escolhe o teu pião, lança-o na arena e derruba o adversário.",
            "diffEasy": "Fácil", "diffNormal": "Normal", "diffHard": "Difícil",
            "chooseTop": "ESCOLHE O TEU PIÃO",
            "chooseDifficulty": "DIFICULDADE",
            "typeAttack": "Ataque", "typeDefense": "Defesa", "typeStamina": "Resistência", "typeBalance": "Equilíbrio",
            "statAtk": "ATQ", "statDef": "DEF", "statStm": "RES",
            "pressStart": "TOCA PARA COMEÇAR",
            "pullHint": "Arrasta para trás e larga para lançar",
            "boost": "BOOST",
            "round": "Ronda",
            "pausedTitle": "PAUSA", "pausedSub": "Toca para retomar",
            "spinOutToast": "GIRO PERDIDO",
            "ringOutToast": "FORA DO RING",
            "burstToast": "BURST!",
            "youWinRound": "VENCESTE A RONDA",
            "cpuWinRound": "O ADVERSÁRIO VENCEU A RONDA",
            "matchWinTitle": "VITÓRIA!",
            "matchLoseTitle": "DERROTA",
            "playAgainBtn": "Jogar Novamente",
            "menuBtn": "Menu",
            "nextRound": "PRÓXIMA RONDA",
            "tapToContinue": "Toca para continuar",
        ],
        .en: [
            "title": "iBeyblade",
            "tagline": "Pick your top, launch it into the arena, and knock out your rival.",
            "diffEasy": "Easy", "diffNormal": "Normal", "diffHard": "Hard",
            "chooseTop": "CHOOSE YOUR TOP",
            "chooseDifficulty": "DIFFICULTY",
            "typeAttack": "Attack", "typeDefense": "Defense", "typeStamina": "Stamina", "typeBalance": "Balance",
            "statAtk": "ATK", "statDef": "DEF", "statStm": "STM",
            "pressStart": "TAP TO START",
            "pullHint": "Pull back and release to launch",
            "boost": "BOOST",
            "round": "Round",
            "pausedTitle": "PAUSED", "pausedSub": "Tap to resume",
            "spinOutToast": "SPUN OUT",
            "ringOutToast": "RING OUT",
            "burstToast": "BURST!",
            "youWinRound": "YOU WON THE ROUND",
            "cpuWinRound": "RIVAL WON THE ROUND",
            "matchWinTitle": "VICTORY!",
            "matchLoseTitle": "DEFEAT",
            "playAgainBtn": "Play Again",
            "menuBtn": "Menu",
            "nextRound": "NEXT ROUND",
            "tapToContinue": "Tap to continue",
        ],
    ]

    static func t(_ key: String) -> String {
        strings[current]?[key] ?? key
    }

    static func typeName(_ type: TopType) -> String {
        switch type {
        case .attack: return t("typeAttack")
        case .defense: return t("typeDefense")
        case .stamina: return t("typeStamina")
        case .balance: return t("typeBalance")
        }
    }
}
