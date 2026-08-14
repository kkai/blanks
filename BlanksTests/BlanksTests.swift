import Testing
import Foundation
@testable import Blanks

private func makeEntry(
    word: String = "apple",
    falseOptions: [String] = ["banana", "cherry", "date", "elderberry"]
) -> WordEntry {
    WordEntry(word: word, definition: "a test definition", falseOptions: falseOptions)
}

@MainActor
@Suite struct WordModelTests {
    @Test func optionsContainAnswerAndAreUnique() {
        let options = WordModel(words: []).shuffledOptions(for: makeEntry())
        #expect(options.count == 4)
        #expect(Set(options).count == 4)
        #expect(options.contains("apple"))
    }

    @Test func duplicatedDistractorsAreDeduped() {
        // 31 of the 8,109 shipped entries repeat a false option.
        let entry = makeEntry(falseOptions: ["banana", "cherry", "banana", "date"])
        let options = WordModel(words: []).shuffledOptions(for: entry)
        #expect(options.count == 4)
        #expect(Set(options).count == 4)
    }

    @Test func fewDistinctDistractorsDoNotHang() {
        // The old rejection-sampling loop hung forever on this input.
        let entry = makeEntry(falseOptions: ["banana", "banana", "cherry", "cherry"])
        let options = WordModel(words: []).shuffledOptions(for: entry)
        #expect(options.count == 3)
        #expect(Set(options).count == 3)
        #expect(options.contains("apple"))
    }

    @Test func answerIsNeverDuplicatedFromDistractors() {
        let entry = makeEntry(falseOptions: ["apple", "banana", "cherry", "date"])
        let options = WordModel(words: []).shuffledOptions(for: entry)
        #expect(options.filter { $0 == "apple" }.count == 1)
    }

    @Test func emptyWordListFailsLoudly() {
        let model = WordModel(words: [])
        #expect(model.loadFailed)
        #expect(model.randomEntry() == nil)
    }

    @Test func bundledWordListDecodes() throws {
        let url = try #require(Bundle.main.url(forResource: "average", withExtension: "plist"))
        let data = try Data(contentsOf: url)
        let entries = try PropertyListDecoder().decode([WordEntry].self, from: data)
        #expect(entries.count > 8000)
        #expect(entries.allSatisfy { !$0.word.isEmpty && !$0.definition.isEmpty })
        #expect(entries.allSatisfy { !Set($0.falseOptions).subtracting([$0.word]).isEmpty })
    }
}

@MainActor
@Suite(.serialized) struct GameStateTests {
    private static let highScoreKey = "HighScore"
    private static let suiteName = "BlanksTests"

    /// A throwaway defaults suite so tests never touch the app's real
    /// HighScore, even if a test run crashes mid-flight.
    private func withCleanHighScore(_ body: (UserDefaults) async throws -> Void) async rethrows {
        let defaults = UserDefaults(suiteName: Self.suiteName)!
        defaults.removePersistentDomain(forName: Self.suiteName)
        defer { defaults.removePersistentDomain(forName: Self.suiteName) }
        try await body(defaults)
    }

    private func makeGame(defaults: UserDefaults) -> GameState {
        GameState(wordModel: WordModel(words: [makeEntry()]), defaults: defaults)
    }

    @Test func correctAnswerScoresAndRaisesHighScore() async {
        await withCleanHighScore { defaults in
            let game = makeGame(defaults: defaults)
            #expect(game.checkAnswer("apple"))
            #expect(game.correctCount == 1)
            #expect(game.streak == 1)
            #expect(game.lastAnswerCorrect == true)
            #expect(Int(game.percentValue) == 100)
            #expect(game.highScore == 1)
            #expect(defaults.integer(forKey: Self.highScoreKey) == 1)
        }
    }

    @Test func wrongAnswerDoesNotAdvanceAndLocksBriefly() async {
        await withCleanHighScore { defaults in
            let game = makeGame(defaults: defaults)
            let wordBefore = game.correctWord
            #expect(game.checkAnswer("banana"))
            #expect(game.wrongCount == 1)
            #expect(game.streak == 0)
            #expect(game.lastAnswerCorrect == false)
            // Same word stays on screen (4.3: retry, no reveal).
            #expect(game.correctWord == wordBefore)

            // Answers during the 0.6s feedback window are ignored.
            #expect(!game.checkAnswer("apple"))
            #expect(game.correctCount == 0)
        }
    }

    @Test func retryAfterWrongAnswerScoresOnSameWord() async throws {
        try await withCleanHighScore { defaults in
            let game = makeGame(defaults: defaults)
            let wordBefore = game.correctWord
            game.checkAnswer("banana")
            try await Task.sleep(for: .seconds(1))
            #expect(!game.showFeedback)
            #expect(game.isAcceptingAnswers)
            // Round did not advance — retrying the SAME word succeeds.
            #expect(game.correctWord == wordBefore)
            #expect(game.checkAnswer("apple"))
            #expect(game.correctCount == 1)
            #expect(game.streak == 1)
            // 4.3 percentage: 1 correct / 2 answered = 50%.
            #expect(Int(game.percentValue) == 50)
        }
    }

    @Test func percentageIsZeroWhileNoCorrectAnswers() async {
        await withCleanHighScore { defaults in
            let game = makeGame(defaults: defaults)
            game.checkAnswer("banana")
            // 4.3 forces 0% while correctCount == 0, despite wrong answers.
            #expect(game.percentValue == 0)
        }
    }

    @Test func highScoreLoadsFromDefaultsAndOnlyRises() async {
        await withCleanHighScore { defaults in
            defaults.set(5, forKey: Self.highScoreKey)
            let game = makeGame(defaults: defaults)
            #expect(game.highScore == 5)

            // A streak of 1 must not lower a high score of 5.
            game.checkAnswer("apple")
            #expect(game.highScore == 5)
        }
    }

    @Test func roundIDAdvancesOnBothOutcomesAndLockRecovers() async throws {
        try await withCleanHighScore { defaults in
            let game = makeGame(defaults: defaults)
            #expect(game.roundID == 0)

            game.checkAnswer("banana")
            #expect(!game.isAcceptingAnswers)
            try await Task.sleep(for: .seconds(1))
            // Wrong outcome: cards reset (roundID bumps), input unlocked.
            #expect(game.roundID == 1)
            #expect(game.isAcceptingAnswers)

            game.checkAnswer("apple")
            try await Task.sleep(for: .seconds(1))
            // Correct outcome: roundID bumps again.
            #expect(game.roundID == 2)
            #expect(game.isAcceptingAnswers)
        }
    }

    @Test func missingContentIsSurfaced() async {
        await withCleanHighScore { defaults in
            let game = GameState(wordModel: WordModel(words: []), defaults: defaults)
            #expect(game.contentUnavailable)
            #expect(game.options.isEmpty)
        }
    }
}
