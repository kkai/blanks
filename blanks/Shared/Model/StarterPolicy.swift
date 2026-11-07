import Foundation

/// New players see common words first, so the opening minutes do not feel like
/// a test of obscure vocabulary. Someone doing very well moves on early, and
/// someone finding it hard stays longer. Afterwards the whole list is in play.
enum StarterPolicy {
    static let shortest = 15
    static let usual = 40
    static let longest = 80

    static func isActive(round: Int, firstTryRate: Double) -> Bool {
        if round < shortest { return true }
        if round >= longest { return false }
        if round < usual { return firstTryRate < 0.9 }
        return firstTryRate < 0.5
    }
}
