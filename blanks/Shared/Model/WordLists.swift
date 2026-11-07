import Foundation

/// The bundled `wordlists.json`, built by scripts/build_wordlists.py.
struct WordLists: Decodable {
    struct DailyEntry: Decodable, Equatable {
        let word: String
        let definition: String
    }

    /// Common words, in the game's main list, that new players see first.
    let starter: [String]
    /// The word-of-the-day widget's list.
    let daily: [DailyEntry]

    static let bundled: WordLists? = {
        guard let url = Bundle.main.url(forResource: "wordlists", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            return nil
        }
        return try? JSONDecoder().decode(WordLists.self, from: data)
    }()
}

/// The word of the day follows from the date alone, so the widget needs no
/// data from the app. A prime step visits every word before one repeats.
enum DailyWord {
    private static let step = 7919

    static func index(for date: Date, count: Int, calendar: Calendar = .current) -> Int? {
        guard count > 0 else { return nil }
        let origin = calendar.startOfDay(for: Date(timeIntervalSinceReferenceDate: 0))
        let day = calendar.dateComponents([.day], from: origin, to: calendar.startOfDay(for: date)).day ?? 0
        let position = (day % count + count) % count
        return (position * (step % count)) % count
    }

    static func nextChange(after date: Date, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: .day, value: 1, to: calendar.startOfDay(for: date)) ?? date.addingTimeInterval(86_400)
    }
}
