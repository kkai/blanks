import SwiftUI

@main
struct BlanksApp: App {
    @State private var gameState = GameState()
    @State private var tipStore = TipStore()

    var body: some Scene {
        WindowGroup {
            BlanksGameView()
                .environment(gameState)
                .environment(tipStore)
        }
    }
}
