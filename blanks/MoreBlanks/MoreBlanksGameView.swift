import SwiftUI

struct MoreBlanksGameView: View {
    @Environment(GameState.self) private var game
    @State private var showSettings = false

    var body: some View {
        NavigationStack {
            GeometryReader { _ in
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

                        Text("_____")
                            .font(.title.bold())
                            .foregroundStyle(.brown.opacity(0.5))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 8)

                        Text(game.definition)
                            .font(.title3)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .frame(maxWidth: .infinity, minHeight: 80)

                        Spacer()

                        VStack(spacing: 12) {
                            ForEach(game.options, id: \.self) { word in
                                Button {
                                    game.checkAnswer(word)
                                } label: {
                                    Text(word)
                                        .font(.title3.bold())
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 14)
                                        .background(
                                            Image("ripped")
                                                .resizable()
                                                .scaledToFill()
                                        )
                                        .clipShape(RoundedRectangle(cornerRadius: 4))
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 32)
                    }
                }
            }
            .overlay {
                if game.showFeedback, let isCorrect = game.lastAnswerCorrect {
                    FeedbackOverlayView(isCorrect: isCorrect, isVisible: game.showFeedback)
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
