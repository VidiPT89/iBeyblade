import SwiftUI
import SpriteKit

struct GameView: UIViewRepresentable {
    func makeUIView(context: Context) -> GameSKView {
        let view = GameSKView(frame: UIScreen.main.bounds)
        view.ignoresSiblingOrder = true
        view.showsFPS = false
        view.showsNodeCount = false
        view.isMultipleTouchEnabled = true
        let scene = GameScene(size: view.bounds.size)
        scene.scaleMode = .resizeFill
        view.presentScene(scene)
        DispatchQueue.main.async { view.becomeFirstResponder() }
        return view
    }

    func updateUIView(_ uiView: GameSKView, context: Context) {
        if let scene = uiView.scene as? GameScene, scene.size != uiView.bounds.size {
            scene.size = uiView.bounds.size
        }
    }
}
