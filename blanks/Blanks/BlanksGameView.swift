import SwiftUI

struct BlanksGameView: View {
    @Environment(GameState.self) private var game
    @State private var showSettings = false
    @State private var dropZoneFrame: CGRect = .zero

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                ZStack {
                    VStack(spacing: 0) {
                        Image("top")
                            .resizable()
                            .scaledToFit()
                        Image("middle")
                            .resizable()
                            .frame(maxHeight: .infinity)
                        Image("bottom")
                            .resizable()
                            .scaledToFit()
                    }
                    .ignoresSafeArea(edges: .bottom)

                    VStack(spacing: 16) {
                        ScoreBarView(
                            streak: game.streak,
                            totalAnswered: game.totalAnswered,
                            correctPercentage: game.correctPercentage
                        )
                        .padding(.top)

                        DropZoneView(isHighlighted: false)
                            .padding(.horizontal, 40)
                            .background(
                                GeometryReader { proxy in
                                    Color.clear
                                        .onAppear {
                                            dropZoneFrame = proxy.frame(in: .named("game"))
                                        }
                                        .onChange(of: proxy.size) {
                                            dropZoneFrame = proxy.frame(in: .named("game"))
                                        }
                                }
                            )

                        Text(game.definition)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, minHeight: 80)

                        Spacer()

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(game.options, id: \.self) { word in
                                WordCardView(
                                    word: word,
                                    dropZoneCenter: CGPoint(
                                        x: dropZoneFrame.midX,
                                        y: dropZoneFrame.midY
                                    )
                                ) { droppedWord, location in
                                    if dropZoneFrame.contains(location) {
                                        game.checkAnswer(droppedWord)
                                        return true
                                    }
                                    return false
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            }
            .coordinateSpace(.named("game"))
            .overlay {
                if game.showFeedback, let isCorrect = game.lastAnswerCorrect {
                    FeedbackOverlayView(isCorrect: isCorrect, isVisible: game.showFeedback)
                }
            }
            .sensoryFeedback(.success, trigger: game.correctCount)
            .sensoryFeedback(.error, trigger: game.wrongCount)
            .navigationTitle("Blanks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showSettings = true
                    } label: {
                        Image(systemName: "gearshape")
                    }
                }
            }
            .sheet(isPresented: $showSettings) {
                SettingsView(highScore: game.highScore)
            }
        }
    }
}
