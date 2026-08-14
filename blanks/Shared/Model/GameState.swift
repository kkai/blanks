import SwiftUI

/// Game rules replicate the shipped ObjC 4.3 app: a wrong answer never
/// advances the round — the same word stays on screen for retry, every
/// wrong answer counts, and nothing is revealed.
@Observable
@MainActor
final class GameState {
    private let wordModel: WordModel
    private let defaults: UserDefaults

    var options: [String] = []
    var definition: String = ""
    var correctWord: String = ""

    var streak: Int = 0
    var correctCount: Int = 0
    var wrongCount: Int = 0

    /// Persisted like 4.3 ("HighScore"), but never displayed.
    var highScore: Int {
        didSet { defaults.set(highScore, forKey: "HighScore") }
    }

    var lastAnswerCorrect: Bool?
    var showFeedback: Bool = false

    /// True once any answer was given — 4.3 switches the score-bar
    /// format string after the first answer.
    private(set) var hasAnswered = false

    /// Bumped when a feedback window ends (correct or wrong) so views can
    /// reset card positions, mirroring 4.3's grow3AnimationDidStop.
    private(set) var roundID = 0

    /// Answers are ignored while feedback for the previous answer is on
    /// screen (guard against double-count races; 4.3 left input unlocked).
    private(set) var isAcceptingAnswers = true

    /// True when the bundled word list could not be loaded.
    var contentUnavailable: Bool { wordModel.loadFailed }

    /// 4.3 percentage rule: correct/(correct+wrong), forced to 0 while
    /// correctCount is 0 — even when wrong answers exist.
    var percentValue: Double {
        guard correctCount > 0 else { return 0 }
        return Double(correctCount) / Double(correctCount + wrongCount) * 100
    }

    init(wordModel: WordModel? = nil, defaults: UserDefaults = .standard) {
        self.wordModel = wordModel ?? WordModel()
        self.defaults = defaults
        highScore = defaults.integer(forKey: "HighScore")
        nextWord()
    }

    /// Scores the answer; the round only advances on a correct answer,
    /// 0.6 s later (the feedback animation length in 4.3).
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
        hasAnswered = true
        showFeedback = true

        // No cancellation needed: the isAcceptingAnswers guard means at
        // most one feedback window is ever in flight.
        Task {
            try? await Task.sleep(for: .seconds(0.6))
            showFeedback = false
            isAcceptingAnswers = true
            if wasCorrect {
                nextWord()
            }
            roundID += 1
        }
        return true
    }

    func nextWord() {
        guard let entry = wordModel.randomEntry() else { return }
        correctWord = entry.word
        definition = entry.definition
        options = wordModel.shuffledOptions(for: entry)
    }
}
