import SwiftUI

struct WordCardView: View {
    let word: String
    let dropZoneCenter: CGPoint
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
                    }
                    .onEnded { value in
                        guard !isSnapping else { return }
                        let dropLocation = value.location
                        let didHit = onDropped(word, dropLocation)

                        if didHit {
                            isSnapping = true
                            isDragging = false
                            let snapOffset = CGSize(
                                width: dropZoneCenter.x - cardOrigin.x,
                                height: dropZoneCenter.y - cardOrigin.y
                            )
                            withAnimation(.interpolatingSpring(stiffness: 200, damping: 15)) {
                                offset = snapOffset
                            }
                            Task {
                                try? await Task.sleep(for: .seconds(0.7))
                                await MainActor.run {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        offset = .zero
                                        isSnapping = false
                                    }
                                }
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
    }
}
