import SwiftUI

@Observable
@MainActor
final class GameState {
    private let wordModel: WordModel
    private var currentEntry: WordEntry?
    private var feedbackTask: Task<Void, Never>?

    var options: [String] = []
    var definition: String = ""
    var correctWord: String = ""

    var streak: Int = 0
    var correctCount: Int = 0
    var wrongCount: Int = 0

    var highScore: Int {
        didSet { UserDefaults.standard.set(highScore, forKey: "HighScore") }
    }

    var lastAnswerCorrect: Bool?
    var showFeedback: Bool = false

    /// Answers are ignored while feedback for the previous answer is on screen.
    private(set) var isAcceptingAnswers = true

    /// True when the bundled word list could not be loaded.
    var contentUnavailable: Bool { wordModel.loadFailed }

    var correctPercentage: Int {
        let total = correctCount + wrongCount
        guard total > 0 else { return 0 }
        return Int(Double(correctCount) / Double(total) * 100)
    }

    var totalAnswered: Int {
        correctCount + wrongCount
    }

    init(wordModel: WordModel? = nil) {
        self.wordModel = wordModel ?? WordModel()
        highScore = UserDefaults.standard.integer(forKey: "HighScore")
        nextWord()
    }

    /// Scores the answer and advances to the next word after feedback.
    /// Returns false if the answer was ignored (feedback still showing).
    @discardableResult
    func checkAnswer(_ answer: String) -> Bool {
        guard isAcceptingAnswers else { return false }
        isAcceptingAnswers = false

        let wasCorrect = answer == correctWord
        if wasCorrect {
            correctCount += 1
            streak += 1
            if streak > highScore {
                highScore = streak
            }
        } else {
            wrongCount += 1
            streak = 0
        }
        lastAnswerCorrect = wasCorrect
        showFeedback = true

        // A miss reveals the correct word, so it stays up longer.
        let feedbackDuration: Duration = wasCorrect ? .seconds(0.6) : .seconds(1.4)
        feedbackTask?.cancel()
        feedbackTask = Task {
            try? await Task.sleep(for: feedbackDuration)
            guard !Task.isCancelled else { return }
            showFeedback = false
            isAcceptingAnswers = true
            nextWord()
        }
        return true
    }

    func nextWord() {
        guard let entry = wordModel.randomEntry() else { return }
        currentEntry = entry
        correctWord = entry.word
        definition = entry.definition
        options = wordModel.shuffledOptions(for: entry)
    }
}
