//
//  WordModel.swift
//  Blanks
//
//  Created by Kai Kunze on 05.08.12.
//  Copyright (c) 2012 Kai Kunze. All rights reserved.
//

import Foundation

class WordModel: NSObject {
    private(set) var correct: String = ""
    private(set) var definition: String = ""
    private var difficulty: String = "average"

    private var wordsArray: [[String: Any]] = []
    private var falseWordArray: [String] = []

    override init() {
        super.init()

        // Load difficulty from UserDefaults
        if let savedDifficulty = UserDefaults.standard.string(forKey: .difficulty) {
            difficulty = savedDifficulty
        } else {
            difficulty = DifficultyLevel.average.rawValue
            UserDefaults.standard.set(difficulty, forKey: .difficulty)
        }

        // XXX TODO fix filename stuff
        difficulty = DifficultyLevel.average.rawValue

        // Load words for current difficulty
        loadWordList(for: difficulty)

        // Select initial random word
        selectNextWord()
    }

    func checkOptions() {
        if let newDifficulty = UserDefaults.standard.string(forKey: .difficulty),
           difficulty != newDifficulty {
            difficulty = newDifficulty
            loadWordList(for: difficulty)
            selectNextWord()
        }
    }

    func selectNextWord() {
        guard !wordsArray.isEmpty else { return }

        let randWordID = Int.random(in: 0..<wordsArray.count)
        let element = wordsArray[randWordID]
        self.correct = element["word"] as? String ?? ""
        self.definition = element["definition"] as? String ?? ""
        self.falseWordArray = element["false"] as? [String] ?? []
    }

    func getWords() -> [String] {
        var words: [String] = []

        guard falseWordArray.count >= 3 else {
            return [correct]
        }

        // Select 3 unique false words
        var indices: Set<Int> = []
        while indices.count < 3 {
            let randomIndex = Int.random(in: 0..<falseWordArray.count)
            indices.insert(randomIndex)
        }

        let indicesArray = Array(indices)
        words.append(falseWordArray[indicesArray[0]])
        words.append(falseWordArray[indicesArray[1]])
        words.append(falseWordArray[indicesArray[2]])
        words.append(correct)

        // Shuffle the array
        words.shuffle()

        return words
    }

    // MARK: - Private Helpers

    private func loadWordList(for difficulty: String) {
        if let path = Bundle.main.path(forResource: difficulty, ofType: "plist"),
           let array = NSArray(contentsOfFile: path) as? [[String: Any]] {
            wordsArray = array
        }
    }
}
