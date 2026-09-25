import SwiftUI

/// Game rules follow the shipped ObjC 4.3 app: a wrong answer never
/// advances the round — the same word stays on screen for retry, every
/// wrong answer counts, and nothing is revealed. Since 5.1 a correct
/// answer can pause on the meanings of all four choices, and missed
/// words come back for review.
@Observable
@MainActor
final class GameState {
    static let pauseAfterWordKey = "PauseAfterWord"
    static let reviewModeKey = "ReviewMode"
    /// Chance that a due review word replaces the next word from the deck.
    static let reviewShare = 0.35

    private let wordModel: WordModel
    private let defaults: UserDefaults
    private var deck: WordDeck
    /// MoreBlanks only: the "Review mistakes" mode can be switched on.
    let reviewModeAvailable: Bool
    let progress: ProgressStore

    var options: [String] = []
    var definition: String = ""
    var correctWord: String = ""

    var streak: Int = 0
    var correctCount: Int = 0
    var wrongCount: Int = 0

    /// Persisted like 4.3 ("HighScore"); shown on About since 5.1.
    var highScore: Int {
        didSet { defaults.set(highScore, forKey: "HighScore") }
    }

    var lastAnswerCorrect: Bool?
    var showFeedback: Bool = false

    /// True after a correct answer while the meanings of all four
    /// choices are on screen; a tap moves on.
    private(set) var isShowingMeanings = false

    /// True once any answer was given — 4.3 switches the score-bar
    /// format string after the first answer.
    private(set) var hasAnswered = false

    /// Bumped when a feedback window ends (correct or wrong) so views can
    /// reset card positions, mirroring 4.3's grow3AnimationDidStop.
    private(set) var roundID = 0

    /// Answers are ignored while feedback for the previous answer is on
    /// screen (guard against double-count races; 4.3 left input unlocked).
    private(set) var isAcceptingAnswers = true

    /// Whether the current word has had a wrong answer.
    private var missedCurrentWord = false

    /// True when the bundled word list could not be loaded.
    var contentUnavailable: Bool { wordModel.loadFailed }

    /// 4.3 percentage rule: correct/(correct+wrong), forced to 0 while
    /// correctCount is 0 — even when wrong answers exist.
    var percentValue: Double {
        guard correctCount > 0 else { return 0 }
        return Double(correctCount) / Double(correctCount + wrongCount) * 100
    }

    var pauseAfterWord: Bool {
        defaults.object(forKey: Self.pauseAfterWordKey) as? Bool ?? true
    }

    var reviewModeOn: Bool {
        reviewModeAvailable && defaults.bool(forKey: Self.reviewModeKey)
    }

    init(
        wordModel: WordModel? = nil,
        progress: ProgressStore? = nil,
        defaults: UserDefaults = .standard,
        reviewModeAvailable: Bool = false
    ) {
        let wordModel = wordModel ?? WordModel()
        self.wordModel = wordModel
        self.progress = progress ?? ProgressStore()
        self.defaults = defaults
        self.reviewModeAvailable = reviewModeAvailable
        deck = WordDeck(count: wordModel.words.count, defaults: defaults)
        highScore = defaults.integer(forKey: "HighScore")
        nextWord()
        #if DEBUG
        // "-showMeanings" opens on the meanings pause (screenshots, UI checks).
        if ProcessInfo.processInfo.arguments.contains("-showMeanings") {
            isShowingMeanings = true
            isAcceptingAnswers = false
        }
        #endif
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
            progress.record(word: correctWord, firstTry: !missedCurrentWord)
        } else {
            wrongCount += 1
            streak = 0
            missedCurrentWord = true
        }
        lastAnswerCorrect = wasCorrect
        hasAnswered = true
        showFeedback = true

        // No cancellation needed: the isAcceptingAnswers guard means at
        // most one feedback window is ever in flight.
        Task {
            try? await Task.sleep(for: .seconds(0.6))
            showFeedback = false
            if wasCorrect && pauseAfterWord {
                // Input stays locked and the cards stay put until
                // continueToNextWord().
                isShowingMeanings = true
                return
            }
            isAcceptingAnswers = true
            if wasCorrect {
                nextWord()
            }
            roundID += 1
        }
        return true
    }

    func continueToNextWord() {
        guard isShowingMeanings else { return }
        isShowingMeanings = false
        nextWord()
        isAcceptingAnswers = true
        roundID += 1
    }

    /// The four choices with their meanings, the answer first.
    var meanings: [(word: String, definition: String?, isAnswer: Bool)] {
        let ordered = [correctWord] + options.filter { $0 != correctWord }
        return ordered.map { word in
            (word, word == correctWord ? definition : wordModel.definition(of: word), word == correctWord)
        }
    }

    func definition(of word: String) -> String? {
        wordModel.definition(of: word)
    }

    func nextWord() {
        guard let entry = pickEntry() else { return }
        correctWord = entry.word
        definition = entry.definition
        options = wordModel.shuffledOptions(for: entry)
        missedCurrentWord = false
    }

    private func pickEntry() -> WordEntry? {
        let current = correctWord.isEmpty ? nil : correctWord
        if reviewModeOn,
           let word = progress.reviewWord(excluding: current),
           let entry = wordModel.entry(for: word) {
            return entry
        }
        if Double.random(in: 0..<1) < Self.reviewShare,
           let word = progress.dueWord(excluding: current),
           let entry = wordModel.entry(for: word) {
            return entry
        }
        return deck.next().map { wordModel.words[$0] }
    }
}
