//
//  Constants.swift
//  Blanks
//
//  Created for Swift modernization
//

import Foundation

// MARK: - UserDefaults Keys

/// User preference keys with type safety
enum UserDefaultsKey: String, CaseIterable {
    case difficulty = "Difficulty"
    case highScore = "HighScore"
    case tappingUI = "TappingUI"
}

// MARK: - Segue Identifiers

/// Storyboard segue identifiers
enum SegueIdentifier: String {
    case showAlternate
}

// MARK: - Difficulty Levels

/// Supported difficulty levels for word selection
enum DifficultyLevel: String, CaseIterable {
    case easy
    case average
    case hard

    /// Human-readable display name
    var displayName: String {
        rawValue.capitalized
    }
}

// MARK: - UserDefaults Property Wrapper

/// Property wrapper for type-safe UserDefaults persistence
///
/// Usage:
/// ```swift
/// @UserDefault(.tappingUI, defaultValue: false)
/// var isTappingMode: Bool
/// ```
@propertyWrapper
struct UserDefault<T> {
    let key: UserDefaultsKey
    let defaultValue: T
    let userDefaults: UserDefaults

    init(_ key: UserDefaultsKey, defaultValue: T, userDefaults: UserDefaults = .standard) {
        self.key = key
        self.defaultValue = defaultValue
        self.userDefaults = userDefaults
    }

    var wrappedValue: T {
        get {
            return userDefaults.object(forKey: key.rawValue) as? T ?? defaultValue
        }
        set {
            userDefaults.set(newValue, forKey: key.rawValue)
        }
    }
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

    func integer(forKey key: UserDefaultsKey) -> Int {
        return integer(forKey: key.rawValue)
    }

    func set(_ value: Any?, forKey key: UserDefaultsKey) {
        set(value, forKey: key.rawValue)
    }
}
