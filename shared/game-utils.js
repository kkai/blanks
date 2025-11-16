// Shared utilities for all vocabulary games
class VocabularyGameUtils {
    constructor() {
        this.allWords = [];
        this.loaded = false;
    }

    // Load words from JSON
    async loadWords() {
        if (this.loaded) return this.allWords;

        try {
            const response = await fetch('../words.json');
            this.allWords = await response.json();
            this.loaded = true;
            return this.allWords;
        } catch (error) {
            console.error('Error loading words:', error);
            return [];
        }
    }

    // Get random words
    getRandomWords(count) {
        const shuffled = [...this.allWords].sort(() => Math.random() - 0.5);
        return shuffled.slice(0, count);
    }

    // Get a random word
    getRandomWord() {
        return this.allWords[Math.floor(Math.random() * this.allWords.length)];
    }

    // Get word with options
    getWordWithOptions() {
        const word = this.getRandomWord();
        const falseWords = [...word.false].sort(() => Math.random() - 0.5).slice(0, 3);
        const allOptions = [...falseWords, word.word].sort(() => Math.random() - 0.5);

        return {
            word: word.word,
            definition: word.definition,
            options: allOptions,
            falseOptions: word.false
        };
    }

    // Shuffle array
    shuffle(array) {
        const newArray = [...array];
        for (let i = newArray.length - 1; i > 0; i--) {
            const j = Math.floor(Math.random() * (i + 1));
            [newArray[i], newArray[j]] = [newArray[j], newArray[i]];
        }
        return newArray;
    }

    // Format time (seconds to mm:ss)
    formatTime(seconds) {
        const mins = Math.floor(seconds / 60);
        const secs = Math.floor(seconds % 60);
        return `${mins}:${secs.toString().padStart(2, '0')}`;
    }

    // Save high score
    saveHighScore(gameName, score) {
        const key = `highscore_${gameName}`;
        const current = this.getHighScore(gameName);
        if (score > current) {
            localStorage.setItem(key, score.toString());
            return true; // New high score
        }
        return false;
    }

    // Get high score
    getHighScore(gameName) {
        const key = `highscore_${gameName}`;
        const score = localStorage.getItem(key);
        return score ? parseInt(score) : 0;
    }

    // Play sound (placeholder for future audio)
    playSound(soundName) {
        // Could implement Web Audio API here
        console.log(`Sound: ${soundName}`);
    }

    // Show feedback animation
    showFeedback(element, isCorrect) {
        element.classList.remove('correct', 'wrong');
        element.classList.add(isCorrect ? 'correct' : 'wrong');

        setTimeout(() => {
            element.classList.remove('correct', 'wrong');
        }, 1000);
    }

    // Create a word pair for matching games
    createWordPair() {
        const word = this.getRandomWord();
        return {
            id: Math.random().toString(36).substr(2, 9),
            word: word.word,
            definition: word.definition
        };
    }

    // Get words that share letters (for chain games)
    getWordsWithSharedLetters(startWord, count) {
        const results = [];
        const startLetters = new Set(startWord.toLowerCase().split(''));

        for (const wordObj of this.allWords) {
            if (results.length >= count) break;
            if (wordObj.word === startWord) continue;

            const wordLetters = new Set(wordObj.word.toLowerCase().split(''));
            const intersection = new Set([...startLetters].filter(x => wordLetters.has(x)));

            if (intersection.size > 0) {
                results.push(wordObj);
            }
        }

        return results;
    }

    // Scramble word letters
    scrambleWord(word) {
        return this.shuffle(word.split('')).join('');
    }

    // Calculate score with combo multiplier
    calculateScore(basePoints, comboCount) {
        const multiplier = Math.min(1 + (comboCount * 0.5), 5); // Max 5x multiplier
        return Math.floor(basePoints * multiplier);
    }

    // Get difficulty level based on word length and definition complexity
    getDifficulty(wordObj) {
        const wordLength = wordObj.word.length;
        const defLength = wordObj.definition.length;

        if (wordLength <= 6 && defLength <= 50) return 'easy';
        if (wordLength <= 10 && defLength <= 100) return 'medium';
        return 'hard';
    }

    // Parse definition to create blanks
    createBlankedDefinition(definition) {
        const words = definition.split(' ');
        const blankedWords = [];
        const blankCount = Math.min(3, Math.floor(words.length / 4));

        // Randomly select words to blank (skip short words)
        const indices = [];
        for (let i = 0; i < words.length; i++) {
            if (words[i].length > 3) {
                indices.push(i);
            }
        }

        const shuffledIndices = this.shuffle(indices).slice(0, blankCount);

        for (let i = 0; i < words.length; i++) {
            if (shuffledIndices.includes(i)) {
                blankedWords.push('_____');
            } else {
                blankedWords.push(words[i]);
            }
        }

        return blankedWords.join(' ');
    }
}

// Export for use in games
if (typeof window !== 'undefined') {
    window.VocabularyGameUtils = VocabularyGameUtils;
}
