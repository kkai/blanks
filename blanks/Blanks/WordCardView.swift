import SwiftUI

struct WordCardView: View {
    let word: String
    let dropZoneCenter: CGPoint
    let onDropped: (String, CGPoint) -> Bool

    @State private var offset: CGSize = .zero
    @State private var isDragging = false
    @State private var isSnapping = false
    @State private var cardOrigin: CGPoint = .zero

    var body: some View {
        Text(word)
            .font(.title3.bold())
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                Image("ripped")
                    .resizable()
                    .scaledToFill()
            )
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .scaleEffect(isDragging ? 1.1 : 1.0)
            .offset(offset)
            .background(
                GeometryReader { geo in
                    Color.clear
                        .onAppear {
                            cardOrigin = CGPoint(
                                x: geo.frame(in: .named("game")).midX,
                                y: geo.frame(in: .named("game")).midY
                            )
                        }
                        .onChange(of: geo.size) {
                            cardOrigin = CGPoint(
                                x: geo.frame(in: .named("game")).midX,
                                y: geo.frame(in: .named("game")).midY
                            )
                        }
                }
            )
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
                            let snapOffset = CGSize(
                                width: dropZoneCenter.x - cardOrigin.x,
                                height: dropZoneCenter.y - cardOrigin.y
                            )
                            withAnimation(.spring(duration: 0.3, bounce: 0.4)) {
                                offset = snapOffset
                                isDragging = false
                            }
                            Task {
                                try? await Task.sleep(for: .seconds(0.8))
                                await MainActor.run {
                                    withAnimation(.easeOut(duration: 0.2)) {
                                        offset = .zero
                                        isSnapping = false
                                    }
                                }
                            }
                        } else {
                            withAnimation(.spring(duration: 0.3)) {
                                offset = .zero
                                isDragging = false
                            }
                        }
                    }
            )
            .animation(.spring(duration: 0.2), value: isDragging)
    }
}
