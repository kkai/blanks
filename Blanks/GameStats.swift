//
//  GameStats.swift
//  Blanks
//
//  Created for Swift modernization
//

import Foundation

/// Manages game statistics including correct/wrong answers and streak tracking
///
/// GameStats tracks the player's performance including:
/// - Number of correct and incorrect answers
/// - Current streak of consecutive correct answers
/// - Highest streak achieved (persisted across sessions)
class GameStats {
    // MARK: - Properties

    /// Number of correct answers in the current session
    private(set) var correctCount: Int = 0

    /// Number of wrong answers in the current session
    private(set) var wrongCount: Int = 0

    /// Current consecutive correct answer streak
    private(set) var currentStreak: Int = 0

    /// Highest streak achieved (persisted to UserDefaults)
    @UserDefault(.highScore, defaultValue: 0)
    private(set) var highestStreak: Int

    // MARK: - Computed Properties

    /// Total number of questions answered in the current session
    var totalCount: Int {
        correctCount + wrongCount
    }

    /// Percentage of correct answers (0.0 to 1.0)
    var correctPercentage: Double {
        guard totalCount > 0 else { return 0.0 }
        return Double(correctCount) / Double(totalCount)
    }

    /// Formatted display string for UI presentation
    var displayString: String {
        String(
            format: "Streak: %d  •  Words: %d  •  Accuracy: %.0f%%",
            currentStreak,
            correctCount,
            correctPercentage * 100
        )
    }

    // MARK: - Initialization

    init() {
        // highestStreak loaded automatically via @UserDefault property wrapper
    }

    // MARK: - Public Methods

    /// Records a correct answer and updates streak
    func recordCorrectAnswer() {
        correctCount += 1
        currentStreak += 1

        if currentStreak > highestStreak {
            highestStreak = currentStreak // Auto-saves via property wrapper
        }
    }

    /// Records a wrong answer and resets streak to zero
    func recordWrongAnswer() {
        wrongCount += 1
        currentStreak = 0
    }

    /// Resets all session statistics (does not affect high score)
    func reset() {
        correctCount = 0
        wrongCount = 0
        currentStreak = 0
    }
}
