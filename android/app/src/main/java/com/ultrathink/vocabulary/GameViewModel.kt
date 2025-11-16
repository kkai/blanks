package com.ultrathink.vocabulary

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.ultrathink.vocabulary.model.WordModel
import com.ultrathink.vocabulary.repository.GameRepository
import com.ultrathink.vocabulary.utils.ScoreManager
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch

/**
 * ViewModel for managing game state and logic
 */
class GameViewModel(
    private val repository: GameRepository,
    private val scoreManager: ScoreManager
) : ViewModel() {

    // Current word being displayed
    private val _currentWord = MutableLiveData<WordModel>()
    val currentWord: LiveData<WordModel> = _currentWord

    // Loading state
    private val _isLoading = MutableLiveData<Boolean>()
    val isLoading: LiveData<Boolean> = _isLoading

    // Error state
    private val _error = MutableLiveData<String?>()
    val error: LiveData<String?> = _error

    // Answer result (true = correct, false = wrong, null = not answered yet)
    private val _answerResult = MutableLiveData<Boolean?>()
    val answerResult: LiveData<Boolean?> = _answerResult

    // Score statistics
    private val _scoreStats = MutableLiveData<ScoreStats>()
    val scoreStats: LiveData<ScoreStats> = _scoreStats

    // Words loaded successfully
    private val _wordsLoaded = MutableLiveData<Boolean>()
    val wordsLoaded: LiveData<Boolean> = _wordsLoaded

    /**
     * Data class for score statistics
     */
    data class ScoreStats(
        val streak: Int,
        val wordCount: Int,
        val accuracy: Float,
        val highScore: Int
    )

    init {
        loadWords()
    }

    /**
     * Load words from repository
     */
    private fun loadWords() {
        viewModelScope.launch {
            _isLoading.value = true
            val success = repository.loadWords()

            if (success) {
                _wordsLoaded.value = true
                loadNextWord()
            } else {
                _error.value = "Failed to load vocabulary words"
                _wordsLoaded.value = false
            }

            _isLoading.value = false
        }
    }

    /**
     * Load the next random word
     */
    fun loadNextWord() {
        val word = repository.getRandomWord()
        if (word != null) {
            _currentWord.value = word
            _answerResult.value = null // Reset answer state
            updateScoreStats()
        } else {
            _error.value = "No words available"
        }
    }

    /**
     * Check if the selected answer is correct
     */
    fun checkAnswer(selectedWord: String) {
        val current = _currentWord.value ?: return

        val isCorrect = current.isCorrect(selectedWord)
        _answerResult.value = isCorrect

        if (isCorrect) {
            scoreManager.recordCorrect()
        } else {
            scoreManager.recordWrong()
        }

        updateScoreStats()

        // Auto-advance to next word after correct answer
        if (isCorrect) {
            viewModelScope.launch {
                delay(1200) // Wait for animation to complete
                loadNextWord()
            }
        }
    }

    /**
     * Update score statistics
     */
    private fun updateScoreStats() {
        _scoreStats.value = ScoreStats(
            streak = scoreManager.currentStreak,
            wordCount = scoreManager.getCurrentWordCount(),
            accuracy = scoreManager.getCurrentAccuracy(),
            highScore = scoreManager.getHighScore()
        )
    }

    /**
     * Reset current session statistics
     */
    fun resetSession() {
        scoreManager.resetSessionStats()
        repository.resetUsedWords()
        updateScoreStats()
        loadNextWord()
    }

    /**
     * Reset all statistics including high score
     */
    fun resetAllStats() {
        scoreManager.resetAllStats()
        repository.resetUsedWords()
        updateScoreStats()
        loadNextWord()
    }

    /**
     * Get interaction mode
     */
    fun isTappingMode(): Boolean {
        return scoreManager.isTappingMode()
    }

    /**
     * Set interaction mode
     */
    fun setTappingMode(isTapping: Boolean) {
        scoreManager.setTappingMode(isTapping)
    }

    /**
     * Clear error state
     */
    fun clearError() {
        _error.value = null
    }

    /**
     * Retry after correct answer (for drag mode)
     */
    fun retryAfterWrong() {
        _answerResult.value = null
    }
}
