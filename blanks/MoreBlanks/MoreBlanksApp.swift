import SwiftUI

@main
struct MoreBlanksApp: App {
    @State private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            MoreBlanksGameView()
                .environment(gameState)
        }
    }
}
