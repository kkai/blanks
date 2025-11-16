package com.ultrathink.vocabulary.model

import kotlin.random.Random

/**
 * Model representing a word question with shuffled options
 *
 * @property correctWord The correct answer
 * @property definition The definition to display
 * @property options List of 4 word options (1 correct + 3 incorrect), shuffled
 */
data class WordModel(
    val correctWord: String,
    val definition: String,
    val options: List<String>
) {
    companion object {
        /**
         * Creates a WordModel from a WordEntry by selecting 3 random false words
         * and shuffling them with the correct word
         */
        fun fromWordEntry(entry: WordEntry): WordModel {
            // Select 3 random false words from the available options
            val selectedFalseWords = if (entry.falseWords.size <= 3) {
                entry.falseWords
            } else {
                entry.falseWords.shuffled().take(3)
            }

            // Combine correct word with false words and shuffle
            val allOptions = (selectedFalseWords + entry.word).shuffled()

            return WordModel(
                correctWord = entry.word,
                definition = entry.definition,
                options = allOptions
            )
        }
    }

    /**
     * Checks if the selected word is correct
     */
    fun isCorrect(selectedWord: String): Boolean {
        return selectedWord.equals(correctWord, ignoreCase = false)
    }
}
