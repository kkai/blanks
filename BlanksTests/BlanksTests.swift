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

    @Test func noDefinitionGivesAwayItsWord() throws {
        // Guarded by scripts/content_fixes.py; keep the list clean.
        let model = WordModel()
        let leaks = model.words.filter {
            $0.definition.range(of: "\\b\($0.word)", options: [.regularExpression, .caseInsensitive]) != nil
        }
        #expect(leaks.map(\.word) == [])
    }

    @Test func distractorMeaningsAreAvailable() {
        let model = WordModel(words: [
            makeEntry(),
            WordEntry(word: "banana", definition: "a yellow fruit", falseOptions: ["apple", "cherry", "date"]),
        ])
        #expect(model.definition(of: "banana") == "a yellow fruit")
        #expect(model.definition(of: "cherry") == nil)
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

    /// The 4.3 flow: no pause on the meanings after a correct answer.
    private func makeGame(defaults: UserDefaults) -> GameState {
        defaults.set(false, forKey: GameState.pauseAfterWordKey)
        return GameState(wordModel: WordModel(words: [makeEntry()]),
                         progress: ProgressStore(fileURL: nil), defaults: defaults)
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
            let game = GameState(wordModel: WordModel(words: []),
                                 progress: ProgressStore(fileURL: nil), defaults: defaults)
            #expect(game.contentUnavailable)
            #expect(game.options.isEmpty)
        }
    }
}

@Suite struct WordDeckTests {
    private func freshDefaults(_ name: String) -> UserDefaults {
        let defaults = UserDefaults(suiteName: name)!
        defaults.removePersistentDomain(forName: name)
        return defaults
    }

    @Test func dealsEveryWordOnceBeforeRepeating() {
        let defaults = freshDefaults("DeckTests.once")
        var deck = WordDeck(count: 50, defaults: defaults)
        let first = (0..<50).compactMap { _ in deck.next() }
        #expect(Set(first) == Set(0..<50))
        let second = (0..<50).compactMap { _ in deck.next() }
        #expect(Set(second) == Set(0..<50))
    }

    @Test func positionSurvivesRelaunch() {
        let defaults = freshDefaults("DeckTests.relaunch")
        var deck = WordDeck(count: 30, defaults: defaults)
        let seen = (0..<10).compactMap { _ in deck.next() }
        var relaunched = WordDeck(count: 30, defaults: defaults)
        let rest = (0..<20).compactMap { _ in relaunched.next() }
        #expect(Set(seen + rest) == Set(0..<30))
    }

    @Test func newWordListStartsANewDeck() {
        let defaults = freshDefaults("DeckTests.count")
        var deck = WordDeck(count: 10, defaults: defaults)
        _ = (0..<9).compactMap { _ in deck.next() }
        var bigger = WordDeck(count: 12, defaults: defaults)
        let dealt = (0..<12).compactMap { _ in bigger.next() }
        #expect(Set(dealt) == Set(0..<12))
    }

    @Test func emptyDeckDealsNothing() {
        var deck = WordDeck(count: 0, defaults: freshDefaults("DeckTests.empty"))
        #expect(deck.next() == nil)
    }
}

@MainActor
@Suite struct ProgressStoreTests {
    @Test func newWordRightFirstTimeCountsAsKnown() {
        let store = ProgressStore(fileURL: nil)
        store.record(word: "apple", firstTry: true)
        #expect(store.records["apple"]?.box == ProgressStore.knownBox)
        #expect(store.reviewCount == 0)
        #expect(store.knownCount == 1)
    }

    @Test func missedWordEntersReviewAndClimbs() {
        let store = ProgressStore(fileURL: nil)
        store.record(word: "apple", firstTry: false)
        #expect(store.records["apple"]?.box == 1)
        #expect(store.reviewCount == 1)
        store.record(word: "apple", firstTry: true)
        #expect(store.records["apple"]?.box == 2)
        store.record(word: "apple", firstTry: false)
        #expect(store.records["apple"]?.box == 1)
    }

    @Test func reviewWordIsDueOnlyAfterItsInterval() {
        let store = ProgressStore(fileURL: nil)
        store.record(word: "apple", firstTry: false)
        #expect(store.dueWord(excluding: nil) == nil)
        for i in 0..<ProgressStore.intervals[1]! {
            store.record(word: "filler\(i)", firstTry: true)
        }
        #expect(store.dueWord(excluding: nil) == "apple")
        #expect(store.dueWord(excluding: "apple") == nil)
        // Review mode ignores the interval.
        store.record(word: "banana", firstTry: false)
        #expect(store.reviewWord(excluding: "apple") == "banana")
    }

    @Test func firstTryRateCountsEveryCompletion() {
        let store = ProgressStore(fileURL: nil)
        store.record(word: "apple", firstTry: true)
        store.record(word: "banana", firstTry: false)
        #expect(store.firstTryRate == 0.5)
    }

    @Test func recentListIsNewestFirstAndCapped() {
        let store = ProgressStore(fileURL: nil)
        for i in 0..<(ProgressStore.recentLimit + 5) {
            store.record(word: "w\(i)", firstTry: true)
        }
        #expect(store.recent.count == ProgressStore.recentLimit)
        #expect(store.recent.first?.word == "w\(ProgressStore.recentLimit + 4)")
    }

    @Test func progressPersistsAndResets() throws {
        let url = FileManager.default.temporaryDirectory
            .appendingPathComponent("progress-\(UUID().uuidString).json")
        defer { try? FileManager.default.removeItem(at: url) }
        let store = ProgressStore(fileURL: url)
        store.record(word: "apple", firstTry: false)
        let reloaded = ProgressStore(fileURL: url)
        #expect(reloaded.records == store.records)
        #expect(reloaded.recent == store.recent)
        #expect(reloaded.round == 1)
        reloaded.reset()
        #expect(ProgressStore(fileURL: url).wordsPractised == 0)
    }
}

@MainActor
@Suite(.serialized) struct GameFlowTests {
    private static let suiteName = "BlanksFlowTests"

    private func makeGame(
        words: [WordEntry] = [makeEntry()],
        pause: Bool,
        review: Bool = false,
        progress: ProgressStore? = nil
    ) -> GameState {
        let defaults = UserDefaults(suiteName: Self.suiteName)!
        defaults.removePersistentDomain(forName: Self.suiteName)
        defaults.set(pause, forKey: GameState.pauseAfterWordKey)
        defaults.set(review, forKey: GameState.reviewModeKey)
        return GameState(wordModel: WordModel(words: words),
                         progress: progress ?? ProgressStore(fileURL: nil),
                         defaults: defaults, reviewModeAvailable: review)
    }

    @Test func correctAnswerPausesOnMeaningsUntilContinue() async throws {
        let game = makeGame(pause: true)
        game.checkAnswer("apple")
        try await Task.sleep(for: .seconds(1))
        #expect(game.isShowingMeanings)
        #expect(game.roundID == 0)
        #expect(!game.checkAnswer("apple"))

        let meanings = game.meanings
        #expect(meanings.first?.word == "apple")
        #expect(meanings.first?.isAnswer == true)
        #expect(meanings.count == 4)

        game.continueToNextWord()
        #expect(!game.isShowingMeanings)
        #expect(game.roundID == 1)
        #expect(game.isAcceptingAnswers)
    }

    @Test func wrongAnswerNeverPauses() async throws {
        let game = makeGame(pause: true)
        game.checkAnswer("banana")
        try await Task.sleep(for: .seconds(1))
        #expect(!game.isShowingMeanings)
        #expect(game.roundID == 1)
    }

    @Test func missThenRightIsRecordedAsNotFirstTry() async throws {
        let progress = ProgressStore(fileURL: nil)
        let game = makeGame(pause: false, progress: progress)
        game.checkAnswer("banana")
        try await Task.sleep(for: .seconds(1))
        game.checkAnswer("apple")
        #expect(progress.records["apple"]?.box == 1)
        #expect(progress.recent.first?.firstTry == false)
    }

    @Test func reviewModeServesMissedWords() {
        let words = (0..<20).map { makeEntry(word: "word\($0)") }
        let progress = ProgressStore(fileURL: nil)
        progress.record(word: "word7", firstTry: false)
        let game = makeGame(words: words, pause: false, review: true, progress: progress)
        #expect(game.correctWord == "word7")
    }

    @Test func reviewModeIsIgnoredWhereUnavailable() {
        let defaults = UserDefaults(suiteName: Self.suiteName)!
        defaults.removePersistentDomain(forName: Self.suiteName)
        defaults.set(true, forKey: GameState.reviewModeKey)
        let game = GameState(wordModel: WordModel(words: [makeEntry()]),
                             progress: ProgressStore(fileURL: nil), defaults: defaults)
        #expect(!game.reviewModeOn)
    }
}
