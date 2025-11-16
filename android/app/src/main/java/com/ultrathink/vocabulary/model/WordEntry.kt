package com.ultrathink.vocabulary.model

import com.google.gson.annotations.SerializedName

/**
 * Represents a single word entry from the vocabulary database
 *
 * @property word The correct word
 * @property definition The definition of the word
 * @property falseWords Array of incorrect word options (typically 3-4 words)
 */
data class WordEntry(
    @SerializedName("word")
    val word: String,

    @SerializedName("definition")
    val definition: String,

    @SerializedName("false")
    val falseWords: List<String>
)
