//
//  WordModel.swift
//  Blanks
//
//  Created by Kai Kunze on 05.08.12.
//  Copyright (c) 2012 Kai Kunze. All rights reserved.
//

import Foundation

// MARK: - Word Model

/// Represents a vocabulary word with definition and incorrect options
struct Word: Codable, Equatable {
    let word: String
    let definition: String
    let falseWords: [String]

    enum CodingKeys: String, CodingKey {
        case word
        case definition
        case falseWords = "false"
    }

    /// Returns an array of word options including the correct word and 3 random false words
    /// - Parameter count: Number of false words to include (default: 3)
    /// - Returns: Shuffled array of word options
    func options(falseWordCount count: Int = 3) -> [String] {
        guard falseWords.count >= count else {
            return [word]
        }

        var result = Array(falseWords.shuffled().prefix(count))
        result.append(word)
        return result.shuffled()
    }
}

// MARK: - Word Loading Error

/// Errors that can occur during word list loading
enum WordLoadingError: Error, LocalizedError {
    case fileNotFound(String)
    case invalidFormat
    case decodingFailed(Error)

    var errorDescription: String? {
        switch self {
        case .fileNotFound(let filename):
            return "Could not find word list file: \(filename)"
        case .invalidFormat:
            return "Word list file has invalid format"
        case .decodingFailed(let error):
            return "Failed to decode word list: \(error.localizedDescription)"
        }
    }
}

// MARK: - Word Model

/// Manages vocabulary words and provides random word selection
///
/// WordModel handles loading words from plist files and maintaining the current word state.
/// It uses Codable for type-safe deserialization and provides clean APIs for word selection.
class WordModel {
    // MARK: - Properties

    /// Current correct word
    private(set) var correct: String = ""

    /// Definition for the current word
    private(set) var definition: String = ""

    /// Current difficulty level (persisted to UserDefaults)
    @UserDefault(.difficulty, defaultValue: DifficultyLevel.average.rawValue)
    private var difficulty: String

    /// Array of all loaded words for the current difficulty
    private var words: [Word] = []

    /// Currently selected word options (including false words)
    private var currentOptions: [String] = []

    // MARK: - Initialization

    init() {
        // Note: Due to limitations with difficulty file loading,
        // we currently hardcode to "average" difficulty
        // TODO: Implement proper difficulty file management
        difficulty = DifficultyLevel.average.rawValue

        do {
            try loadWordList(for: difficulty)
            selectNextWord()
        } catch {
            print("Error loading word list: \(error.localizedDescription)")
            // Provide a fallback empty state
            words = []
        }
    }

    // MARK: - Public Methods

    /// Checks if difficulty setting has changed and reloads if needed
    func checkOptions() {
        if let newDifficulty = UserDefaults.standard.string(forKey: .difficulty),
           difficulty != newDifficulty {
            difficulty = newDifficulty

            do {
                try loadWordList(for: difficulty)
                selectNextWord()
            } catch {
                print("Error reloading word list: \(error.localizedDescription)")
            }
        }
    }

    /// Selects a new random word and generates options
    func selectNextWord() {
        guard let word = words.randomElement() else {
            correct = ""
            definition = ""
            currentOptions = []
            return
        }

        correct = word.word
        definition = word.definition
        currentOptions = word.options()
    }

    /// Returns the current word options (1 correct + 3 false words, shuffled)
    func getWords() -> [String] {
        guard !currentOptions.isEmpty else {
            selectNextWord()
            return currentOptions
        }
        return currentOptions
    }

    // MARK: - Private Helpers

    /// Loads word list from plist file for the given difficulty
    /// - Parameter difficulty: Difficulty level string (matches plist filename)
    /// - Throws: WordLoadingError if loading or decoding fails
    private func loadWordList(for difficulty: String) throws {
        guard let url = Bundle.main.url(forResource: difficulty, withExtension: "plist") else {
            throw WordLoadingError.fileNotFound("\(difficulty).plist")
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = PropertyListDecoder()
            words = try decoder.decode([Word].self, from: data)

            guard !words.isEmpty else {
                throw WordLoadingError.invalidFormat
            }
        } catch let error as DecodingError {
            throw WordLoadingError.decodingFailed(error)
        } catch {
            throw error
        }
    }
}
