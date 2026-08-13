import SwiftUI

struct MoreBlanksGameView: View {
    @Environment(GameState.self) private var game
    @State private var showSettings = false

    // Original image dimensions in points (1x assets, 320pt wide)
    private let topAspect: CGFloat = 150 / 320
    private let bottomAspect: CGFloat = 133 / 320

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
                        // Color.clear keeps layout at the proposed size; a bare
                        // scaledToFill image reports its covering size and
                        // widens the whole ZStack past the screen.
                        Color.clear
                            .overlay {
                                Image("middle")
                                    .resizable()
                                    .scaledToFill()
                            }
                            .clipped()
                        Image("bottom")
                            .resizable()
                            .scaledToFit()
                    }
                    .ignoresSafeArea(edges: .bottom)

                    // Content overlay aligned to background sections
                    VStack(spacing: 0) {
                        // Top section: score + blank indicator (within top image area)
                        VStack(spacing: 4) {
                            ScoreBarView(
                                streak: game.streak,
                                totalAnswered: game.totalAnswered,
                                correctPercentage: game.correctPercentage
                            )
                            Spacer()
                            Text("_____")
                                .font(.title.bold())
                                .foregroundStyle(.brown.opacity(0.4))
                                .accessibilityHidden(true)
                        }
                        .frame(height: topHeight)

                        // Middle section: definition (on lined paper)
                        VStack {
                            Text(game.definition)
                                .font(.title3)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                                .padding(.top, 16)
                                .accessibilityLabel("Definition: \(game.definition)")
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)

                        // Bottom section: answer buttons (on dark torn edge)
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 10) {
                            ForEach(game.options, id: \.self) { word in
                                Button {
                                    game.checkAnswer(word)
                                } label: {
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
                                }
                                .buttonStyle(.plain)
                                .accessibilityLabel(word)
                                .accessibilityHint("Selects this word as your answer")
                            }
                        }
                        .padding(.horizontal, 16)
                        .frame(height: bottomHeight)
                    }
                }
            }
            .overlay {
                if game.showFeedback, let isCorrect = game.lastAnswerCorrect {
                    FeedbackOverlayView(
                        isCorrect: isCorrect,
                        isVisible: game.showFeedback,
                        correctWord: game.correctWord
                    )
                }
            }
            .overlay {
                if game.contentUnavailable {
                    ContentUnavailableView(
                        "Word List Unavailable",
                        systemImage: "exclamationmark.triangle",
                        description: Text("The bundled word list could not be loaded. Try reinstalling the app.")
                    )
                    .background(.regularMaterial)
                }
            }
            .sensoryFeedback(.success, trigger: game.correctCount)
            .sensoryFeedback(.error, trigger: game.wrongCount)
            .navigationTitle("More Blanks")
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
