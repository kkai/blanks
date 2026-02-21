import SwiftUI

struct FeedbackOverlayView: View {
    let isCorrect: Bool
    let isVisible: Bool

    var body: some View {
        Image(isCorrect ? "correct" : "wrong")
            .resizable()
            .scaledToFit()
            .frame(width: 100, height: 100)
            .scaleEffect(isVisible ? 1.3 : 0.5)
            .opacity(isVisible ? 1 : 0)
            .animation(.spring(duration: 0.4), value: isVisible)
    }
}
