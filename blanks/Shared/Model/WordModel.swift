import Foundation

struct WordModel {
    let words: [WordEntry]
    private let indexByWord: [String: Int]

    /// True when no usable word list is available; views show an error state.
    let loadFailed: Bool

    // Parsed once per process; the plist is 800 KB and identical for every instance.
    private static let bundledWords: [WordEntry]? = {
        guard let url = Bundle.main.url(forResource: "average", withExtension: "plist"),
              let data = try? Data(contentsOf: url),
              let entries = try? PropertyListDecoder().decode([WordEntry].self, from: data),
              !entries.isEmpty else {
            return nil
        }
        return entries
    }()

    init() {
        self.init(words: Self.bundledWords ?? [])
    }

    init(words: [WordEntry]) {
        self.words = words
        indexByWord = Dictionary(words.enumerated().map { ($1.word, $0) },
                                 uniquingKeysWith: { first, _ in first })
        loadFailed = words.isEmpty
    }

    func randomEntry() -> WordEntry? {
        words.randomElement()
    }

    func entry(for word: String) -> WordEntry? {
        indexByWord[word].map { words[$0] }
    }

    /// Nearly every distractor is itself a headword, so its meaning is
    /// available offline.
    func definition(of word: String) -> String? {
        entry(for: word)?.definition
    }

    func shuffledOptions(for entry: WordEntry) -> [String] {
        // Some entries repeat a false option; dedupe (and drop the answer if
        // it ever appears among the distractors) before sampling.
        let distractors = Set(entry.falseOptions).subtracting([entry.word])
        var options = Array(distractors.shuffled().prefix(3))
        options.append(entry.word)
        options.shuffle()
        return options
    }
}
