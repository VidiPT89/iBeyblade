# 🌀 iBeyblade — Launch, Spin, Battle (iOS)

> A native iOS spinning-top battle game built with Swift and SpriteKit — pick a top, pull back to launch it into a glowing arena, and outlast your rival's spin.

iBeyblade is a native iPhone/iPad game built with **Swift** and **SpriteKit** — no third-party engines, no external dependencies. Choose one of eight spinning tops, each with its own Attack, Defense, Stamina profile and guardian spirit, pull back on the arena to set your launch angle and power, then watch the battle unfold: tops drift and clash on their own physics, and your mid-fight input is a Special Move gauge that builds up as you spin and clash. Play solo against a CPU rival with three difficulty levels, or pass-and-play locally as two humans on one device. First to win two rounds takes the match.

## 📦 What's Inside

- 🌀 A custom top-down physics simulation — no `SKPhysicsWorld` — driving spin decay, wall bounces and top-to-top collisions
- 🎯 Eight original tops, each with its own guardian spirit — Inferno Fang (Phoenix), Titan Shell (Tortoise), Chrono Drift (Serpent), Vortex Core (Wolf), Thunder Claw (Tiger), Frost Wyrm (Dragon), Sandstorm Fury (Scorpion), Abyssal Maw (Shark) — paged 4-at-a-time in the picker
- 🔄 Authentic left-spin/right-spin mechanics: two tops spinning the same way clash softly, opposite spins clash hard
- 💥 Three ways to lose a round — **Spin-out** (stamina runs out), **Ring-out** (knocked past the arena rim), and a rare instant **Burst** on an extreme-force clash
- ⏱️ A Sudden Death safety net: any round still undecided past 22s ramps up stamina decay sharply, so no fight can stall out forever
- 🖐️ A pull-back-and-release launch gesture, like pulling a ripcord, that sets both the angle and power of your top
- ✨ A Special Move gauge that fills as you spin, bounce off walls and clash — unleash it for a temporary Attack/Defense buff and a burst of your top's guardian spirit, with its own name banner and visual flourish
- 🤖 CPU rival with three difficulty levels — Easy, Normal, Hard — tuning its launch accuracy and how aggressively it uses its own Special Move
- 👥 Local 2-player mode — pass-and-play on one device, each player launches from their own half of the arena with their own Special Move gauge
- 🏆 Best-of-3 rounds per match, with a round-result and match-over overlay between fights
- 📖 A first-launch Tutorial (five swipeable pages) plus a reachable-anytime Help quick-reference and a Settings screen (sound, haptics, language, lifetime win count)
- 🔊 Fully synthesized sound effects via a custom `AVAudioEngine` synth — launch whoosh, clash clang, spin-out, ring-out, burst, Special Move flourish, victory fanfare — no audio files
- 📳 Haptic feedback scaled to impact strength on every clash, wall bounce and knockout — toggleable in Settings
- 🇵🇹 🇬🇧 One-tap language toggle between European Portuguese and English, live-updated everywhere including mid-battle
- ⌨️ Hardware keyboard support (Space to boost, P to pause) for Simulator and keyboard-connected iPads
- ⏸️ Pause/resume at any time, with a dimmed overlay
- 🎬 An animated intro presentation on launch — the title and a spinning top reveal before handing off to the main menu
- 🌌 Animated ambient starfield behind the arena, independent of the battle state
- 🖥️ Neon glow styling throughout for an authentic arcade feel

## 🛠️ Tech Stack

![Swift](https://img.shields.io/badge/Swift-F05138?style=flat&logo=swift&logoColor=white)
![SpriteKit](https://img.shields.io/badge/SpriteKit-000000?style=flat&logo=apple&logoColor=white)
![iOS](https://img.shields.io/badge/iOS-16%2B-black?style=flat&logo=ios&logoColor=white)
![Xcode](https://img.shields.io/badge/Xcode-147EFB?style=flat&logo=xcode&logoColor=white)

## 🏗️ Project Structure

```
iBeyblade/
├── project.yml                # XcodeGen project spec (source of truth for the .xcodeproj)
├── iBeyblade.xcodeproj         # Generated Xcode project — open this in Xcode
└── iBeyblade/
    ├── iBeybladeApp.swift       # SwiftUI app entry point
    ├── GameView.swift           # UIViewRepresentable hosting the SpriteKit view
    ├── GameSKView.swift          # SKView subclass, forwards hardware keyboard input
    ├── GameScene.swift           # Scene setup, arena rendering, render loop
    ├── GameScene+Physics.swift   # Spin decay, wall/top collisions, Sudden Death, Special Move gauge fill
    ├── GameScene+AI.swift        # CPU launch aim and Special Move usage per difficulty
    ├── GameScene+UI.swift        # Menu, HUD, launch gesture (single + local 2P), overlays
    ├── GameScene+Splash.swift    # Intro presentation
    ├── GameScene+Settings.swift  # Sound/haptics/language toggles, win counter
    ├── GameScene+Tutorial.swift  # First-launch tutorial + Help quick-reference
    ├── Entities.swift            # Top physics model, autonomous movement, Special Move state
    ├── BeybladeTypes.swift       # The eight top presets (stats, colors, spirits)
    ├── BeybladeNode.swift        # Spinning-top rendering, stamina ring, launch/special/KO animations
    ├── HUDNodes.swift            # Battle HUD node references (both players)
    ├── SoundEngine.swift         # Synthesized battle sound effects
    ├── Haptics.swift             # Haptic feedback helpers
    ├── Localization.swift        # PT/EN strings
    └── Assets.xcassets           # App icon
```

## ⚙️ Game Mechanics

```
New Match:
  wins = 0:0, round = 1
  vs CPU  → player picks a top, CPU is assigned a different one at random
  vs Player → Player 1 picks a top, then Player 2 picks a top

Each Round:
  both tops reset to full stamina/gauge at their launch spots on opposite sides
  each side pulls back and releases to launch; battle starts once both are launched
  from then on, movement is autonomous — steering blends a light pull toward the
  opponent (stronger for Attack-type tops) with organic drift, no direct joystick control

Each Frame (while battling):
  1. Spin stamina decays over time at a rate set by the top's Stamina stat
     (decay ramps up sharply after 22s of Sudden Death)
  2. Hitting the arena wall bounces the top back, unless it's too weak or too fast —
     then it's knocked clean out of the ring (Ring-out) — and fills a little Special gauge
  3. Colliding with the other top knocks both back, scaled by attacker's Attack vs
     defender's Defense (boosted while a Special Move is active), amplified if the two
     tops spin in opposite directions, and fills both tops' Special gauges
  4. A full Special gauge can be spent for a 2.5s Attack/Defense buff and a spirit burst
  5. An extreme hit can trigger an instant Burst KO on the weaker top
  6. Stamina hitting zero ends the round in a Spin-out
  7. A round win/loss updates the 0:0 score; first to 2 wins takes the match
```

## 🎡 Top Types & Spirits

```
Inferno Fang   (Attack)            Phoenix  — very high Attack, low Defense
Thunder Claw   (Attack, glass cannon) Tiger — highest Attack, lowest Stamina
Titan Shell    (Defense)           Tortoise — very high Defense, low Attack
Frost Wyrm     (Defense + Stamina) Dragon   — high Defense and Stamina, low Attack
Chrono Drift   (Stamina)           Serpent  — barely decays, but a poor brawler
Sandstorm Fury (Stamina + Attack)  Scorpion — high Stamina with a real bite
Vortex Core    (Balance)           Wolf     — even stats, no clear weakness
Abyssal Maw    (Balance, aggressive) Shark  — strong all-round, Attack-biased
```

## 🚀 How to Run

```bash
# 1. Clone the repository
git clone https://github.com/VidiPT89/iBeyblade.git
cd iBeyblade

# 2. Open the Xcode project
open iBeyblade.xcodeproj

# 3. Pick an iPhone/iPad simulator (or a real device), press ⌘R
```

Requires Xcode 16+ and iOS 16+. No third-party dependencies or package managers involved.

If you add or remove Swift files and use [XcodeGen](https://github.com/yonaskolb/XcodeGen), regenerate the project from `project.yml`:

```bash
xcodegen generate
```

## 📝 Notes

- Language, sound, haptics preferences and the lifetime win count are stored with `UserDefaults`, so they persist between launches.
- Local 2-player is pass-and-play on one device: Player 1 launches from the bottom half of the arena, Player 2 from the top half, each with their own drag gesture and Special Move button.

---

Developed by **David Arsénio Martins**
🌐 [ividi.dev](https://ividi.dev/)
