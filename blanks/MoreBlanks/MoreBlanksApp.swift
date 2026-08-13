import SwiftUI

@main
struct MoreBlanksApp: App {
    @State private var gameState = GameState()
    @State private var tipStore = TipStore()

    var body: some Scene {
        WindowGroup {
            MoreBlanksGameView()
                .environment(gameState)
                .environment(tipStore)
        }
    }
}
