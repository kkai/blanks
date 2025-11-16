package com.ultrathink.vocabulary.utils

import android.content.Context
import android.content.SharedPreferences

/**
 * Manages score persistence and game statistics using SharedPreferences
 */
class ScoreManager(context: Context) {

    private val prefs: SharedPreferences = context.getSharedPreferences(
        PREFS_NAME,
        Context.MODE_PRIVATE
    )

    companion object {
        private const val PREFS_NAME = "ultrathink_prefs"
        private const val KEY_HIGH_SCORE = "high_score"
        private const val KEY_TOTAL_WORDS = "total_words"
        private const val KEY_CORRECT_COUNT = "correct_count"
        private const val KEY_WRONG_COUNT = "wrong_count"
        private const val KEY_IS_TAPPING_MODE = "is_tapping_mode"
    }

    /**
     * Current session statistics (not persisted)
     */
    var currentStreak: Int = 0
        private set

    var currentCorrectCount: Int = 0
        private set

    var currentWrongCount: Int = 0
        private set

    /**
     * Get the highest streak achieved
     */
    fun getHighScore(): Int {
        return prefs.getInt(KEY_HIGH_SCORE, 0)
    }

    /**
     * Update high score if current streak is higher
     */
    private fun updateHighScore(streak: Int) {
        val currentHigh = getHighScore()
        if (streak > currentHigh) {
            prefs.edit().putInt(KEY_HIGH_SCORE, streak).apply()
        }
    }

    /**
     * Get total words attempted across all sessions
     */
    fun getTotalWordsAllTime(): Int {
        return prefs.getInt(KEY_TOTAL_WORDS, 0)
    }

    /**
     * Get total correct answers across all sessions
     */
    fun getTotalCorrectAllTime(): Int {
        return prefs.getInt(KEY_CORRECT_COUNT, 0)
    }

    /**
     * Get total wrong answers across all sessions
     */
    fun getTotalWrongAllTime(): Int {
        return prefs.getInt(KEY_WRONG_COUNT, 0)
    }

    /**
     * Record a correct answer
     */
    fun recordCorrect() {
        currentStreak++
        currentCorrectCount++
        updateHighScore(currentStreak)

        // Update all-time stats
        prefs.edit().apply {
            putInt(KEY_TOTAL_WORDS, getTotalWordsAllTime() + 1)
            putInt(KEY_CORRECT_COUNT, getTotalCorrectAllTime() + 1)
            apply()
        }
    }

    /**
     * Record a wrong answer
     */
    fun recordWrong() {
        currentStreak = 0
        currentWrongCount++

        // Update all-time stats
        prefs.edit().apply {
            putInt(KEY_TOTAL_WORDS, getTotalWordsAllTime() + 1)
            putInt(KEY_WRONG_COUNT, getTotalWrongAllTime() + 1)
            apply()
        }
    }

    /**
     * Calculate current session accuracy percentage
     */
    fun getCurrentAccuracy(): Float {
        val total = currentCorrectCount + currentWrongCount
        return if (total == 0) {
            0f
        } else {
            (currentCorrectCount.toFloat() / total.toFloat()) * 100f
        }
    }

    /**
     * Calculate all-time accuracy percentage
     */
    fun getAllTimeAccuracy(): Float {
        val total = getTotalCorrectAllTime() + getTotalWrongAllTime()
        return if (total == 0) {
            0f
        } else {
            (getTotalCorrectAllTime().toFloat() / total.toFloat()) * 100f
        }
    }

    /**
     * Reset current session statistics
     */
    fun resetSessionStats() {
        currentStreak = 0
        currentCorrectCount = 0
        currentWrongCount = 0
    }

    /**
     * Reset all statistics including high score
     */
    fun resetAllStats() {
        resetSessionStats()
        prefs.edit().apply {
            putInt(KEY_HIGH_SCORE, 0)
            putInt(KEY_TOTAL_WORDS, 0)
            putInt(KEY_CORRECT_COUNT, 0)
            putInt(KEY_WRONG_COUNT, 0)
            apply()
        }
    }

    /**
     * Get interaction mode preference (tap vs drag)
     */
    fun isTappingMode(): Boolean {
        return prefs.getBoolean(KEY_IS_TAPPING_MODE, true) // Default to tapping mode
    }

    /**
     * Set interaction mode preference
     */
    fun setTappingMode(isTapping: Boolean) {
        prefs.edit().putBoolean(KEY_IS_TAPPING_MODE, isTapping).apply()
    }

    /**
     * Get current session word count
     */
    fun getCurrentWordCount(): Int {
        return currentCorrectCount + currentWrongCount
    }
}
