# 🌀 iBeyblade — Launch, Spin, Battle (iOS)

> A native iOS spinning-top battle game built with Swift and SpriteKit — pick a top, pull back to launch it into a glowing arena, and outlast your rival's spin.

iBeyblade is a native iPhone/iPad game built with **Swift** and **SpriteKit** — no third-party engines, no external dependencies. Choose one of four spinning tops, each with its own Attack, Defense and Stamina profile, pull back on the arena to set your launch angle and power, then watch the battle unfold: tops drift and clash on their own physics, and your only mid-fight input is a limited-charge Boost. First to win two rounds takes the match.

## 📦 What's Inside

- 🌀 A custom top-down physics simulation — no `SKPhysicsWorld` — driving spin decay, wall bounces and top-to-top collisions
- 🎯 Four original tops — Inferno Fang (Attack), Titan Shell (Defense), Chrono Drift (Stamina), Vortex Core (Balance) — each with a distinct stat spread, spin direction and glow color
- 🔄 Authentic left-spin/right-spin mechanics: two tops spinning the same way clash softly, opposite spins clash hard
- 💥 Three ways to lose a round — **Spin-out** (stamina runs out), **Ring-out** (knocked past the arena rim), and a rare instant **Burst** on an extreme-force clash
- 🖐️ A pull-back-and-release launch gesture, like pulling a ripcord, that sets both the angle and power of your top
- ⚡ A limited-charge Boost button for mid-battle bursts of speed, at the cost of a little stamina
- 🤖 CPU rival with three difficulty levels — Easy, Normal, Hard — tuning its launch accuracy and how aggressively it uses its own boosts
- 🏆 Best-of-3 rounds per match, with a round-result and match-over overlay between fights
- 🔊 Fully synthesized sound effects via a custom `AVAudioEngine` synth — launch whoosh, clash clang, spin-out, ring-out, burst, victory fanfare — no audio files
- 📳 Haptic feedback scaled to impact strength on every clash, wall bounce and knockout
- 🇵🇹 🇬🇧 One-tap language toggle between European Portuguese and English
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
    ├── GameScene+Physics.swift   # Spin decay, wall/top collisions, spin-out/ring-out/burst
    ├── GameScene+AI.swift        # CPU launch aim and boost usage per difficulty
    ├── GameScene+UI.swift        # Menu, HUD, launch gesture, boost button, pause, overlays
    ├── GameScene+Splash.swift    # Intro presentation
    ├── Entities.swift            # Top physics model and autonomous movement
    ├── BeybladeTypes.swift       # The four top presets (stats, colors, names)
    ├── BeybladeNode.swift        # Spinning-top rendering, stamina ring, launch/boost/KO animations
    ├── HUDNodes.swift            # Battle HUD node references
    ├── SoundEngine.swift         # Synthesized battle sound effects
    ├── Haptics.swift             # Haptic feedback helpers
    ├── Localization.swift        # PT/EN strings
    └── Assets.xcassets           # App icon
```

## ⚙️ Game Mechanics

```
New Match:
  wins = 0:0, round = 1, player picks a top, CPU is assigned a different one at random

Each Round:
  both tops reset to full stamina at their launch spots on opposite sides of the arena
  player pulls back and releases to launch; the CPU launches with its own aim/power
  from then on, movement is autonomous — steering blends a light pull toward the
  opponent (stronger for Attack-type tops) with organic drift, no direct joystick control

Each Frame (while battling):
  1. Spin stamina decays over time at a rate set by the top's Stamina stat
  2. Hitting the arena wall bounces the top back, unless it's too weak or too fast —
     then it's knocked clean out of the ring (Ring-out)
  3. Colliding with the other top knocks both back, scaled by attacker's Attack vs
     defender's Defense, amplified if the two tops spin in opposite directions;
     an extreme hit can trigger an instant Burst KO on the weaker top
  4. Stamina hitting zero ends the round in a Spin-out
  5. A round win/loss updates the 0:0 score; first to 2 wins takes the match
```

## 🎡 Top Types

```
Inferno Fang (Attack)   — very high Attack, low Defense: hits hard, breaks easily
Titan Shell  (Defense)  — very high Defense, low Attack: absorbs hits, rarely knocks back
Chrono Drift (Stamina)  — very high Stamina: barely decays, but a poor brawler
Vortex Core  (Balance)  — even stats across the board: no clear weakness
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

- Language preference is stored with `UserDefaults`, so it persists between launches.

---

Developed by **David Arsénio Martins**
🌐 [ividi.dev](https://ividi.dev/)
