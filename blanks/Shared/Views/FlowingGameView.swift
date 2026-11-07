import SwiftUI

/// The game at accessibility text sizes, where the fixed canvas cannot hold
/// the text. Same rules, fonts and paper as the canvas, with tap answers only.
struct FlowingGameView: View {
    @Binding var showAbout: Bool

    @Environment(GameState.self) private var game
    @State private var speaker = WordSpeaker()

    private static let bodyFont = Font.custom("IowanOldStyle-Roman", size: 17, relativeTo: .body)
    private static let boldFont = Font.custom("IowanOldStyle-Bold", size: 17, relativeTo: .body)

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if game.isShowingMeanings {
                    meanings
                } else {
                    Text(game.definition)
                        .font(Self.bodyFont)
                        .accessibilityLabel("Definition: \(game.definition)")
                    feedback
                    ForEach(game.options, id: \.self) { option in
                        answerButton(option)
                    }
                }
                Text("Streak \(game.streak), word count \(game.correctCount), correct \(Int(game.percentValue.rounded()))%")
                    .font(Self.bodyFont)
                Button("About") { showAbout = true }
                    .font(Self.boldFont)
                    .tint(.black)
                    .frame(minHeight: 44)
            }
            .foregroundStyle(.black)
            .padding(20)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .background {
            ZStack {
                Color.white
                Image(decorative: "optionback")
                    .resizable()
                    .scaledToFill()
                    .opacity(0.22)
            }
            .ignoresSafeArea()
        }
    }

    @ViewBuilder
    private var feedback: some View {
        if game.showFeedback, let isCorrect = game.lastAnswerCorrect {
            Text(isCorrect ? "Correct" : "Wrong, try again")
                .font(Self.boldFont)
                .foregroundStyle(isCorrect ? Color.black : Color(red: 0.6, green: 0.1, blue: 0.1))
        }
    }

    private func answerButton(_ option: String) -> some View {
        Button {
            game.checkAnswer(option)
        } label: {
            Text(option)
                .font(Self.boldFont)
                .foregroundStyle(.black)
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.white.opacity(0.75), in: RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.black.opacity(0.5)))
        }
        .buttonStyle(.plain)
        .accessibilityHint("Selects this word as your answer")
    }

    private var meanings: some View {
        VStack(alignment: .leading, spacing: 18) {
            ForEach(game.meanings, id: \.word) { item in
                VStack(alignment: .leading, spacing: 4) {
                    Button {
                        speaker.speak(item.word)
                    } label: {
                        Label(item.word, systemImage: "speaker.wave.2")
                            .font(Self.boldFont)
                            .foregroundStyle(.black)
                            .frame(minHeight: 44, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityLabel("Pronounce \(item.word)")
                    if item.isAnswer {
                        Text("The answer")
                            .font(Self.bodyFont.italic())
                    }
                    if let definition = item.definition {
                        Text(definition)
                            .font(Self.bodyFont)
                    }
                }
                .onLongPressGesture {
                    DictionaryLookup.present(term: item.word, fallback: game.definition(of: item.word))
                }
                .accessibilityAction(named: "Look up \(item.word)") {
                    DictionaryLookup.present(term: item.word, fallback: game.definition(of: item.word))
                }
            }
            Button {
                game.continueToNextWord()
            } label: {
                Text("Next word")
                    .font(Self.boldFont)
                    .frame(maxWidth: .infinity, minHeight: 44)
            }
            .buttonStyle(.bordered)
            .tint(.black)
        }
    }
}
