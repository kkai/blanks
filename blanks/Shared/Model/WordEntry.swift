import Foundation

struct WordEntry: Decodable {
    let word: String
    let definition: String
    let falseOptions: [String]

    enum CodingKeys: String, CodingKey {
        case word
        case definition
        case falseOptions = "false"
    }
}
