import Foundation

struct WordModel {
    private let words: [WordEntry]

    init() {
        guard let url = Bundle.main.url(forResource: "average", withExtension: "plist"),
              let data = try? Data(contentsOf: url) else {
            words = []
            return
        }
        words = (try? PropertyListDecoder().decode([WordEntry].self, from: data)) ?? []
    }

    func randomEntry() -> WordEntry? {
        words.randomElement()
    }

    func shuffledOptions(for entry: WordEntry) -> [String] {
        var selected = Set<String>()
        var falseWords: [String] = []

        let available = entry.falseOptions
        while falseWords.count < 3, falseWords.count < available.count {
            let candidate = available.randomElement()!
            if selected.insert(candidate).inserted {
                falseWords.append(candidate)
            }
        }

        var options = falseWords
        options.append(entry.word)
        options.shuffle()
        return options
    }
}
