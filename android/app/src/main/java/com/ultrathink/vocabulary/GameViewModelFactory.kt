package com.ultrathink.vocabulary

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.ultrathink.vocabulary.repository.GameRepository
import com.ultrathink.vocabulary.utils.ScoreManager

/**
 * Factory for creating GameViewModel with dependencies
 */
class GameViewModelFactory(
    private val repository: GameRepository,
    private val scoreManager: ScoreManager
) : ViewModelProvider.Factory {

    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(GameViewModel::class.java)) {
            return GameViewModel(repository, scoreManager) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
