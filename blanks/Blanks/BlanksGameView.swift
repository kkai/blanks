import SwiftUI

struct BlanksGameView: View {
    @Environment(GameState.self) private var game
    @State private var showSettings = false
    @State private var dropZoneFrame: CGRect = .zero

    // Original image dimensions in points (1x assets, 320pt wide)
    private let originalWidth: CGFloat = 320
    private let topAspect: CGFloat = 150 / 320   // top image aspect
    private let bottomAspect: CGFloat = 133 / 320 // bottom image aspect

    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                let screenWidth = geo.size.width
                let topHeight = screenWidth * topAspect
                let bottomHeight = screenWidth * bottomAspect

                ZStack {
                    // Background
                    VStack(spacing: 0) {
                        Image("top")
                            .resizable()
                            .scaledToFit()
                        Image("middle")
                            .resizable()
                            .scaledToFill()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .clipped()
                        Image("bottom")
                            .resizable()
                            .scaledToFit()
                    }
                    .ignoresSafeArea(edges: .bottom)

                    // Content overlay aligned to background sections
                    VStack(spacing: 0) {
                        // Top section: score bar + drop zone (within top image area)
                        VStack(spacing: 4) {
                            ScoreBarView(
                                streak: game.streak,
                                totalAnswered: game.totalAnswered,
                                correctPercentage: game.correctPercentage
                            )
                            Spacer()
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
                        }
                        .frame(height: topHeight)

                        // Middle section: definition (on lined paper)
                        VStack {
                            Text(game.definition)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 16)
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)

                        // Bottom section: word cards (on dark torn edge)
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
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
                        .padding(.horizontal, 16)
                        .frame(height: bottomHeight)
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
