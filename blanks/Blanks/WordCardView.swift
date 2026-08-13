import SwiftUI

struct WordCardView: View {
    let word: String
    let dropZoneCenter: CGPoint
    let onDragMoved: (CGPoint) -> Void
    let onDropped: (String, CGPoint) -> Bool

    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    @State private var isSnapping = false
    @State private var cardOrigin: CGPoint = .zero

    private var cardScale: CGFloat {
        if isSnapping { return 0.95 }
        if isDragging { return 1.1 }
        return 1.0
    }

    var body: some View {
        Image("ripped")
            .resizable()
            .scaledToFit()
            .overlay {
                Text(word)
                    .font(.headline.bold())
                    .foregroundStyle(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .padding(.horizontal, 8)
            }
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            cardOrigin = CGPoint(
                                x: geo.frame(in: .named("game")).midX,
                                y: geo.frame(in: .named("game")).midY
                            )
                        }
                        .onChange(of: geo.frame(in: .named("game")).origin) {
                            if !isDragging && !isSnapping {
                                cardOrigin = CGPoint(
                                    x: geo.frame(in: .named("game")).midX,
                                    y: geo.frame(in: .named("game")).midY
                                )
                            }
                        }
                }
            )
            .scaleEffect(cardScale)
            .offset(offset)
            .zIndex(isDragging || isSnapping ? 1 : 0)
            .gesture(
                DragGesture(coordinateSpace: .named("game"))
                    .onChanged { value in
                        guard !isSnapping else { return }
                        offset = value.translation
                        isDragging = true
                        onDragMoved(value.location)
                    }
                    .onEnded { value in
                        guard !isSnapping else { return }
                        let didHit = onDropped(word, value.location)

                        if didHit {
                            // Seat the card in the blank for the feedback beat;
                            // the grid is replaced when the round advances.
                            isSnapping = true
                            isDragging = false
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                                offset = CGSize(
                                    width: dropZoneCenter.x - cardOrigin.x,
                                    height: dropZoneCenter.y - cardOrigin.y
                                )
                            }
                            Task {
                                // Silent reset after the longest feedback window,
                                // in case this view is reused for a future round.
                                try? await Task.sleep(for: .seconds(1.6))
                                offset = .zero
                                isSnapping = false
                            }
                        } else {
                            withAnimation(.interpolatingSpring(stiffness: 300, damping: 20)) {
                                offset = .zero
                                isDragging = false
                            }
                        }
                    }
            )
            .animation(.spring(duration: 0.2), value: cardScale)
            // VoiceOver can't perform the drag; activating the card answers directly.
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(word)
            .accessibilityHint("Selects this word as your answer")
            .accessibilityAddTraits(.isButton)
            .accessibilityAction {
                _ = onDropped(word, dropZoneCenter)
            }
    }
}
