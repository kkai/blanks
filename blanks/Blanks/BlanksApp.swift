import SwiftUI

@main
struct BlanksApp: App {
    @State private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            BlanksGameView()
                .environment(gameState)
        }
    }
}
