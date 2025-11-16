//
//  WordModel.swift
//  Blanks
//
//  Created by Kai Kunze on 05.08.12.
//  Copyright (c) 2012 Kai Kunze. All rights reserved.
//

import Foundation

class WordModel: NSObject {
    var correct: String = ""
    var definition: String = ""
    var difficulty: String = "average"

    private var wordsArray: [[String: Any]] = []
    private var falseWordArray: [String] = []

    override init() {
        super.init()

        // Seed the random number generator
        srand48(time(nil))

        var filename = "average"

        // Load difficulty from UserDefaults
        if let savedDifficulty = UserDefaults.standard.string(forKey: "Difficulty") {
            difficulty = savedDifficulty
            filename = savedDifficulty
        } else {
            difficulty = "average"
            UserDefaults.standard.set(difficulty, forKey: "Difficulty")
        }

        // XXX TODO fix filename stuff
        filename = "average"

        // Load words array from plist
        if let path = Bundle.main.path(forResource: filename, ofType: "plist"),
           let array = NSArray(contentsOfFile: path) as? [[String: Any]] {
            wordsArray = array
        }

        // Select initial random word
        if !wordsArray.isEmpty {
            let randWordID = Int(drand48() * Double(wordsArray.count))
            let element = wordsArray[randWordID]
            self.correct = element["word"] as? String ?? ""
            self.definition = element["definition"] as? String ?? ""
            self.falseWordArray = element["false"] as? [String] ?? []
        }
    }

    func didListChange() -> Bool {
        if let newDifficulty = UserDefaults.standard.string(forKey: "Difficulty") {
            return difficulty != newDifficulty
        }
        return false
    }

    // XXX TODO  XXX fix duplicate code
    func checkOptions() {
        if let newDifficulty = UserDefaults.standard.string(forKey: "Difficulty"),
           difficulty != newDifficulty {
            difficulty = newDifficulty

            if let path = Bundle.main.path(forResource: difficulty, ofType: "plist"),
               let array = NSArray(contentsOfFile: path) as? [[String: Any]] {
                wordsArray = array
            }

            srand48(time(nil))
            selectNextWord()
        }
    }

    func selectNextWord() {
        guard !wordsArray.isEmpty else { return }

        let randWordID = Int(drand48() * Double(wordsArray.count))
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
            let randomIndex = Int(drand48() * Double(falseWordArray.count))
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
}
