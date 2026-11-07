import Foundation

/// Per-word results with Leitner boxes. A word answered right on the first
/// try the first time it is seen counts as known (box 5). A miss puts it in
/// box 1; each later first-try answer moves it up one box. Words in boxes
/// 1–4 come back after a number of completed words that grows per box.
@Observable
@MainActor
final class ProgressStore {
    struct WordRecord: Codable, Equatable {
        var box: Int
        var seen: Int
        var firstTry: Int
        /// Value of `round` when the word was last completed.
        var lastRound: Int
        /// When the word was last missed. Nil for words from before 5.2.
        var lastMissed: Date?
    }

    struct RecentWord: Codable, Identifiable, Equatable {
        var id = UUID()
        let word: String
        let firstTry: Bool
    }

    private struct Snapshot: Codable {
        var records: [String: WordRecord]
        var recent: [RecentWord]
        var round: Int

        init(records: [String: WordRecord], recent: [RecentWord], round: Int) {
            self.records = records
            self.recent = recent
            self.round = round
        }

        /// A field that cannot be read costs that field, not the whole file.
        init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            records = (try? container.decode([String: WordRecord].self, forKey: .records)) ?? [:]
            recent = (try? container.decode([RecentWord].self, forKey: .recent)) ?? []
            round = (try? container.decode(Int.self, forKey: .round)) ?? 0
        }
    }

    static let knownBox = 5
    static let recentLimit = 50
    /// Completed words to wait before a word in box 1…4 is due again.
    static let intervals = [1: 3, 2: 8, 3: 25, 4: 60]

    private(set) var records: [String: WordRecord] = [:]
    private(set) var recent: [RecentWord] = []
    /// Completed words, ever. Drives when review words are due.
    private(set) var round = 0

    /// The current word list. A record for a word outside it, such as one
    /// removed in an update, is kept but never offered for review.
    var vocabulary: Set<String>?

    private let fileURL: URL?
    private let now: () -> Date

    /// `fileURL: nil` keeps progress in memory only (previews, tests).
    init(fileURL: URL? = ProgressStore.defaultFileURL, now: @escaping () -> Date = Date.init) {
        self.fileURL = fileURL
        self.now = now
        guard let fileURL, let data = try? Data(contentsOf: fileURL) else { return }
        guard let snapshot = try? JSONDecoder().decode(Snapshot.self, from: data) else {
            // The next save would overwrite this file, so keep a copy.
            let backup = fileURL.deletingPathExtension().appendingPathExtension("unreadable.json")
            try? data.write(to: backup, options: .atomic)
            return
        }
        records = snapshot.records
        recent = snapshot.recent
        round = snapshot.round
    }

    nonisolated static var defaultFileURL: URL? {
        guard let dir = try? FileManager.default.url(
            for: .applicationSupportDirectory, in: .userDomainMask,
            appropriateFor: nil, create: true
        ) else { return nil }
        return dir.appendingPathComponent("progress.json")
    }

    func record(word: String, firstTry: Bool) {
        round += 1
        var entry = records[word] ?? WordRecord(box: 0, seen: 0, firstTry: 0, lastRound: 0)
        if firstTry {
            entry.firstTry += 1
            entry.box = entry.seen == 0 ? Self.knownBox : min(entry.box + 1, Self.knownBox)
        } else {
            entry.box = 1
            entry.lastMissed = now()
        }
        entry.seen += 1
        entry.lastRound = round
        records[word] = entry

        recent.insert(RecentWord(word: word, firstTry: firstTry), at: 0)
        if recent.count > Self.recentLimit {
            recent.removeLast(recent.count - Self.recentLimit)
        }
        save()
    }

    /// The most pressing review word whose wait is over, if any.
    func dueWord(excluding current: String?) -> String? {
        reviewCandidates(excluding: current)
            .first { word, entry in
                round - entry.lastRound >= Self.intervals[entry.box, default: 0]
            }?.key
    }

    /// The most pressing review word, due or not (review-mistakes mode).
    func reviewWord(excluding current: String?) -> String? {
        reviewCandidates(excluding: current).first?.key
    }

    var reviewCount: Int {
        records.values.filter { $0.box < Self.knownBox }.count
    }

    var knownCount: Int {
        records.values.filter { $0.box == Self.knownBox }.count
    }

    var wordsPractised: Int { records.count }

    /// Share of completed words answered right on the first try, 0…1.
    var firstTryRate: Double {
        let seen = records.values.reduce(0) { $0 + $1.seen }
        guard seen > 0 else { return 0 }
        return Double(records.values.reduce(0) { $0 + $1.firstTry }) / Double(seen)
    }

    /// A word from `words` the player has never completed.
    func unseenWord(from words: [String], excluding current: String?) -> String? {
        words.filter { records[$0] == nil && $0 != current }.randomElement()
    }

    /// Words per Leitner box, for boxes 1 to the known box.
    var boxCounts: [Int: Int] {
        var counts = Dictionary(uniqueKeysWithValues: (1...Self.knownBox).map { ($0, 0) })
        for record in records.values where counts[record.box] != nil {
            counts[record.box, default: 0] += 1
        }
        return counts
    }

    /// Words missed in the last seven days, most recent first.
    var missedThisWeek: [String] {
        let cutoff = now().addingTimeInterval(-7 * 86_400)
        return records
            .compactMap { word, record -> (String, Date)? in
                guard let missed = record.lastMissed, missed >= cutoff else { return nil }
                return (word, missed)
            }
            .sorted { ($1.1, $0.0) < ($0.1, $1.0) }
            .map(\.0)
    }

    func reset() {
        records = [:]
        recent = []
        round = 0
        save()
    }

    /// Lowest box first, then the word waiting longest.
    private func reviewCandidates(excluding current: String?) -> [(key: String, value: WordRecord)] {
        records
            .filter { word, record in
                record.box < Self.knownBox && word != current && vocabulary?.contains(word) != false
            }
            .sorted {
                ($0.value.box, $0.value.lastRound, $0.key) < ($1.value.box, $1.value.lastRound, $1.key)
            }
    }

    private func save() {
        guard let fileURL else { return }
        let snapshot = Snapshot(records: records, recent: recent, round: round)
        guard let data = try? JSONEncoder().encode(snapshot) else { return }
        try? data.write(to: fileURL, options: .atomic)
    }
}
