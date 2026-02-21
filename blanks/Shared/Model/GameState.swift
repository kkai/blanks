import SwiftUI

@Observable
final class GameState {
    private let wordModel = WordModel()
    private var currentEntry: WordEntry?

    var options: [String] = []
    var definition: String = ""
    var correctWord: String = ""

    var streak: Int = 0
    var correctCount: Int = 0
    var wrongCount: Int = 0

    var highScore: Int {
        get { UserDefaults.standard.integer(forKey: "HighScore") }
        set { UserDefaults.standard.set(newValue, forKey: "HighScore") }
    }

    var lastAnswerCorrect: Bool?
    var showFeedback: Bool = false

    var correctPercentage: Int {
        let total = correctCount + wrongCount
        guard total > 0 else { return 0 }
        return Int(Double(correctCount) / Double(total) * 100)
    }

    var totalAnswered: Int {
        correctCount + wrongCount
    }

    init() {
        nextWord()
    }

    func checkAnswer(_ answer: String) {
        if answer == correctWord {
            correctCount += 1
            streak += 1
            lastAnswerCorrect = true
            if streak > highScore {
                highScore = streak
            }
        } else {
            wrongCount += 1
            streak = 0
            lastAnswerCorrect = false
        }

        showFeedback = true

        let wasCorrect = lastAnswerCorrect == true
        Task {
            try? await Task.sleep(for: .seconds(0.6))
            await MainActor.run {
                self.showFeedback = false
                if wasCorrect {
                    self.nextWord()
                }
            }
        }
    }

    func nextWord() {
        guard let entry = wordModel.randomEntry() else { return }
        currentEntry = entry
        correctWord = entry.word
        definition = entry.definition
        options = wordModel.shuffledOptions(for: entry)
    }
}
