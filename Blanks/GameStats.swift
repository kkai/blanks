//
//  GameStats.swift
//  Blanks
//
//  Created for Swift modernization
//

import Foundation

/// Manages game statistics including correct/wrong answers and streak tracking
class GameStats {
    // MARK: - Properties

    private(set) var correctCount: Int = 0
    private(set) var wrongCount: Int = 0
    private(set) var currentStreak: Double = 0.0
    private(set) var highestStreak: Double = 0.0

    // MARK: - Computed Properties

    var totalCount: Int {
        return correctCount + wrongCount
    }

    var correctPercentage: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(correctCount) / Double(totalCount)
    }

    var displayString: String {
        return String(format: "streak: %5.0f\t\tword count: %d\t\tcorrect: %.0f%%",
                     currentStreak, correctCount, correctPercentage * 100)
    }

    // MARK: - Initialization

    init() {
        loadHighScore()
    }

    // MARK: - Public Methods

    /// Records a correct answer and updates streak
    func recordCorrectAnswer() {
        correctCount += 1
        currentStreak += 1

        if currentStreak > highestStreak {
            highestStreak = currentStreak
            saveHighScore()
        }
    }

    /// Records a wrong answer and resets streak
    func recordWrongAnswer() {
        wrongCount += 1
        currentStreak = 0.0
    }

    /// Resets all statistics
    func reset() {
        correctCount = 0
        wrongCount = 0
        currentStreak = 0.0
    }

    // MARK: - Private Methods

    private func loadHighScore() {
        highestStreak = UserDefaults.standard.double(forKey: .highScore)
    }

    private func saveHighScore() {
        UserDefaults.standard.set(highestStreak, forKey: .highScore)
    }
}
