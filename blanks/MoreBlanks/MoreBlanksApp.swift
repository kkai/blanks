import SwiftUI

@main
struct MoreBlanksApp: App {
    // No TipStore: MoreBlanks has no reachable tip jar (as shipped in 4.4),
    // so it must not start a Transaction.updates listener either.
    @State private var gameState = GameState()

    var body: some Scene {
        WindowGroup {
            MoreBlanksGameView()
                .environment(gameState)
        }
    }
}
