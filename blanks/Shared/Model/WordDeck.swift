import Foundation

/// Deals word indices in a shuffled order without replacement, so a word
/// only comes back after the whole list has been seen. The order is
/// rebuilt from a stored seed, so the position survives relaunches.
struct WordDeck {
    private static let seedKey = "DeckSeed"
    private static let positionKey = "DeckPosition"
    private static let countKey = "DeckCount"

    private let defaults: UserDefaults
    private let count: Int
    private var order: [Int] = []
    private var position: Int

    init(count: Int, defaults: UserDefaults) {
        self.defaults = defaults
        self.count = count
        position = defaults.integer(forKey: Self.positionKey)
        let seed = UInt64(max(0, defaults.integer(forKey: Self.seedKey)))
        // A new word list (count changed) or a fresh install starts a new deck.
        if seed == 0 || defaults.integer(forKey: Self.countKey) != count {
            reshuffle()
        } else {
            order = Self.shuffledIndices(count: count, seed: seed)
        }
    }

    mutating func next() -> Int? {
        guard count > 0 else { return nil }
        if position >= order.count {
            reshuffle()
        }
        let index = order[position]
        position += 1
        defaults.set(position, forKey: Self.positionKey)
        return index
    }

    private mutating func reshuffle() {
        // Stays within Int64 so it round-trips through UserDefaults.
        let seed = UInt64.random(in: 1...UInt64(Int64.max))
        order = Self.shuffledIndices(count: count, seed: seed)
        position = 0
        defaults.set(Int(seed), forKey: Self.seedKey)
        defaults.set(count, forKey: Self.countKey)
        defaults.set(0, forKey: Self.positionKey)
    }

    static func shuffledIndices(count: Int, seed: UInt64) -> [Int] {
        var rng = SplitMix64(seed: seed)
        return Array(0..<count).shuffled(using: &rng)
    }
}

/// Small deterministic generator so a deck can be rebuilt from its seed.
struct SplitMix64: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
