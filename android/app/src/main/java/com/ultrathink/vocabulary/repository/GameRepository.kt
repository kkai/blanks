package com.ultrathink.vocabulary.repository

import android.content.Context
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import com.ultrathink.vocabulary.model.WordEntry
import com.ultrathink.vocabulary.model.WordModel
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.InputStreamReader
import kotlin.random.Random

/**
 * Repository for loading and managing vocabulary words
 */
class GameRepository(private val context: Context) {

    private var wordEntries: List<WordEntry> = emptyList()
    private val usedWordIndices = mutableSetOf<Int>()

    /**
     * Load all words from the JSON file in assets
     * This should be called once at app startup
     */
    suspend fun loadWords(): Boolean = withContext(Dispatchers.IO) {
        try {
            val inputStream = context.assets.open("words.json")
            val reader = InputStreamReader(inputStream)

            val type = object : TypeToken<List<WordEntry>>() {}.type
            wordEntries = Gson().fromJson(reader, type)

            reader.close()
            inputStream.close()

            wordEntries.isNotEmpty()
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    /**
     * Get a random word that hasn't been used recently
     * Tracks used words to avoid repetition in short term
     */
    fun getRandomWord(): WordModel? {
        if (wordEntries.isEmpty()) {
            return null
        }

        // Reset used words if we've gone through most of the vocabulary
        if (usedWordIndices.size >= wordEntries.size * 0.8) {
            usedWordIndices.clear()
        }

        // Find an unused word
        var attempts = 0
        var randomIndex: Int

        do {
            randomIndex = Random.nextInt(wordEntries.size)
            attempts++
            // Prevent infinite loop if something goes wrong
            if (attempts > 100) {
                usedWordIndices.clear()
                randomIndex = Random.nextInt(wordEntries.size)
                break
            }
        } while (usedWordIndices.contains(randomIndex))

        usedWordIndices.add(randomIndex)

        val entry = wordEntries[randomIndex]
        return WordModel.fromWordEntry(entry)
    }

    /**
     * Get total number of words loaded
     */
    fun getTotalWords(): Int = wordEntries.size

    /**
     * Reset the used words tracker
     */
    fun resetUsedWords() {
        usedWordIndices.clear()
    }
}
