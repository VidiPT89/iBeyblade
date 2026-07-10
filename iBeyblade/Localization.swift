import Foundation

enum Lang: String {
    case pt, en
}

enum L {
    /// Always starts in English — the PT/EN toggle only affects the current
    /// session and isn't remembered between launches.
    static var current: Lang = .en

    static func toggle() { current = current == .pt ? .en : .pt }

    static let strings: [Lang: [String: String]] = [
        .pt: [
            "title": "iBeyblade",
            "tagline": "Escolhe o teu pião, lança-o na arena e derruba o adversário.",
            "diffEasy": "Fácil", "diffNormal": "Normal", "diffHard": "Difícil",
            "chooseTop": "ESCOLHE O TEU PIÃO",
            "chooseDifficulty": "DIFICULDADE",
            "chooseMode": "MODO",
            "modeVsCPU": "vs CPU",
            "modeVsPlayer": "vs Jogador",
            "typeAttack": "Ataque", "typeDefense": "Defesa", "typeStamina": "Resistência", "typeBalance": "Equilíbrio",
            "statAtk": "ATQ", "statDef": "DEF", "statStm": "RES",
            "pressStart": "TOCA PARA COMEÇAR",
            "pullHint": "Arrasta para trás e larga para lançar",
            "round": "Ronda",
            "suddenDeath": "MORTE SÚBITA",
            "pausedTitle": "PAUSA", "pausedSub": "Toca para retomar",
            "spinOutToast": "GIRO PERDIDO",
            "ringOutToast": "FORA DO RING",
            "burstToast": "BURST!",
            "youWinRound": "VENCESTE A RONDA",
            "cpuWinRound": "O ADVERSÁRIO VENCEU A RONDA",
            "p1WinRound": "JOGADOR 1 VENCEU A RONDA",
            "p2WinRound": "JOGADOR 2 VENCEU A RONDA",
            "matchWinTitle": "VITÓRIA!",
            "matchLoseTitle": "DERROTA",
            "p1MatchWin": "JOGADOR 1 VENCE!",
            "p2MatchWin": "JOGADOR 2 VENCE!",
            "playAgainBtn": "Jogar Novamente",
            "menuBtn": "Menu",
            "nextRound": "PRÓXIMA RONDA",
            "tapToContinue": "Toca para continuar",
            "player1": "Jogador 1",
            "player2": "Jogador 2",
            "pickTopP1": "JOGADOR 1: ESCOLHE O TEU PIÃO",
            "pickTopP2": "JOGADOR 2: ESCOLHE O TEU PIÃO",
            "spiritRisingSuffix": " DESPERTA!",
            "settingsTitle": "DEFINIÇÕES",
            "soundLabel": "Som",
            "hapticsLabel": "Vibração",
            "languageLabel": "Idioma",
            "winsLabel": "Vitórias",
            "closeBtn": "Fechar",
            "helpTitle": "AJUDA",
            "helpBody": "• Arrasta para trás a partir do teu pião e larga para o lançar.\n• Perdes com Giro Perdido (resistência a zero) ou Fora do Ring.\n• Um choque muito forte pode causar um Burst instantâneo.\n• Girar e chocar enche o medidor especial — toca para libertar o espírito.\n• Vence 2 rondas para ganhar o combate.",
            "tutorialBtn": "Tutorial",
            "tutorialSkip": "Saltar",
            "tutorialNext": "Seguinte",
            "tutorialDone": "Começar",
            "tut1Title": "Escolhe o teu pião",
            "tut1Body": "Cada pião tem Ataque, Defesa e Resistência diferentes. Escolhe o estilo que preferires.",
            "tut2Title": "Lança-o na arena",
            "tut2Body": "Arrasta para trás a partir do teu pião e larga para o lançar — quanto mais puxares, mais forte sai.",
            "tut3Title": "Giro Perdido, Fora do Ring, Burst",
            "tut3Body": "Perdes se a resistência chegar a zero (Giro Perdido) ou fores empurrado para fora da arena (Fora do Ring). Um choque muito forte pode causar um Burst instantâneo!",
            "tut4Title": "Movimento Especial",
            "tut4Body": "Girar e chocar enche o teu medidor. Quando estiver cheio, toca no botão para libertar o espírito do teu pião.",
            "tut5Title": "Vence o Combate",
            "tut5Body": "Ganha 2 rondas para vencer. Boa sorte!",
        ],
        .en: [
            "title": "iBeyblade",
            "tagline": "Pick your top, launch it into the arena, and knock out your rival.",
            "diffEasy": "Easy", "diffNormal": "Normal", "diffHard": "Hard",
            "chooseTop": "CHOOSE YOUR TOP",
            "chooseDifficulty": "DIFFICULTY",
            "chooseMode": "MODE",
            "modeVsCPU": "vs CPU",
            "modeVsPlayer": "vs Player",
            "typeAttack": "Attack", "typeDefense": "Defense", "typeStamina": "Stamina", "typeBalance": "Balance",
            "statAtk": "ATK", "statDef": "DEF", "statStm": "STM",
            "pressStart": "TAP TO START",
            "pullHint": "Pull back and release to launch",
            "round": "Round",
            "suddenDeath": "SUDDEN DEATH",
            "pausedTitle": "PAUSED", "pausedSub": "Tap to resume",
            "spinOutToast": "SPUN OUT",
            "ringOutToast": "RING OUT",
            "burstToast": "BURST!",
            "youWinRound": "YOU WON THE ROUND",
            "cpuWinRound": "RIVAL WON THE ROUND",
            "p1WinRound": "PLAYER 1 WON THE ROUND",
            "p2WinRound": "PLAYER 2 WON THE ROUND",
            "matchWinTitle": "VICTORY!",
            "matchLoseTitle": "DEFEAT",
            "p1MatchWin": "PLAYER 1 WINS!",
            "p2MatchWin": "PLAYER 2 WINS!",
            "playAgainBtn": "Play Again",
            "menuBtn": "Menu",
            "nextRound": "NEXT ROUND",
            "tapToContinue": "Tap to continue",
            "player1": "Player 1",
            "player2": "Player 2",
            "pickTopP1": "PLAYER 1: CHOOSE YOUR TOP",
            "pickTopP2": "PLAYER 2: CHOOSE YOUR TOP",
            "spiritRisingSuffix": " RISING!",
            "settingsTitle": "SETTINGS",
            "soundLabel": "Sound",
            "hapticsLabel": "Haptics",
            "languageLabel": "Language",
            "winsLabel": "Wins",
            "closeBtn": "Close",
            "helpTitle": "HELP",
            "helpBody": "• Drag back from your top and release to launch it.\n• You lose with a Spin-out (stamina hits zero) or a Ring-out.\n• An extreme clash can trigger an instant Burst.\n• Spinning and clashing fills the special gauge — tap it to unleash your spirit.\n• Win 2 rounds to take the match.",
            "tutorialBtn": "Tutorial",
            "tutorialSkip": "Skip",
            "tutorialNext": "Next",
            "tutorialDone": "Start",
            "tut1Title": "Choose your top",
            "tut1Body": "Each top has different Attack, Defense and Stamina. Pick the style that suits you.",
            "tut2Title": "Launch it into the arena",
            "tut2Body": "Drag back from your top and release to launch it — the further you pull, the stronger the launch.",
            "tut3Title": "Spin-out, Ring-out, Burst",
            "tut3Body": "You lose if your stamina hits zero (Spin-out) or you're knocked out of the arena (Ring-out). An extreme clash can trigger an instant Burst!",
            "tut4Title": "Special Move",
            "tut4Body": "Spinning and clashing fills your gauge. When it's full, tap the button to unleash your top's spirit.",
            "tut5Title": "Win the Match",
            "tut5Body": "Win 2 rounds to take the match. Good luck!",
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

    static func spiritRising(_ spirit: String) -> String {
        current == .pt ? "\(spirit.uppercased())\(t("spiritRisingSuffix"))" : "\(spirit.uppercased())\(t("spiritRisingSuffix"))"
    }

    static func tutorialTitle(_ page: Int) -> String { t("tut\(page)Title") }
    static func tutorialBody(_ page: Int) -> String { t("tut\(page)Body") }
}
