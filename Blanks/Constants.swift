//
//  Constants.swift
//  Blanks
//
//  Created for Swift modernization
//

import Foundation

// MARK: - UserDefaults Keys

enum UserDefaultsKey: String {
    case difficulty = "Difficulty"
    case highScore = "HighScore"
    case tappingUI = "TappingUI"
}

// MARK: - Segue Identifiers

enum SegueIdentifier: String {
    case showAlternate
}

// MARK: - Difficulty Levels

enum DifficultyLevel: String {
    case average
    case easy
    case hard
}

// MARK: - UserDefaults Extension for Type Safety

extension UserDefaults {
    func string(forKey key: UserDefaultsKey) -> String? {
        return string(forKey: key.rawValue)
    }

    func bool(forKey key: UserDefaultsKey) -> Bool {
        return bool(forKey: key.rawValue)
    }

    func object(forKey key: UserDefaultsKey) -> Any? {
        return object(forKey: key.rawValue)
    }

    func double(forKey key: UserDefaultsKey) -> Double {
        return double(forKey: key.rawValue)
    }

    func set(_ value: Any?, forKey key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }
}
