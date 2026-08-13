import Foundation

struct WordModel {
    private let words: [WordEntry]

    /// True when no usable word list is available; views show an error state.
    let loadFailed: Bool

    // Parsed once per process; the plist is 2.5 MB and identical for every instance.
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
        loadFailed = words.isEmpty
    }

    func randomEntry() -> WordEntry? {
        words.randomElement()
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
