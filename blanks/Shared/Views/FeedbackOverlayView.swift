import SwiftUI

struct FeedbackOverlayView: View {
    let isCorrect: Bool
    let isVisible: Bool
    var correctWord: String?

    var body: some View {
        VStack(spacing: 12) {
            Image(isCorrect ? "correct" : "wrong")
                .resizable()
                .scaledToFit()
                .frame(width: 100, height: 100)

            if !isCorrect, let correctWord {
                Text(correctWord)
                    .font(.title3.bold())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Capsule().fill(.thinMaterial))
            }
        }
        .scaleEffect(isVisible ? 1.3 : 0.5)
        .opacity(isVisible ? 1 : 0)
        .animation(.spring(duration: 0.4), value: isVisible)
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(
            isCorrect
                ? "Correct"
                : "Wrong. The answer is \(correctWord ?? "unknown")."
        )
    }
}
