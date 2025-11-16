// Game State
class BlanksGame {
    constructor() {
        this.wordsData = [];
        this.currentWord = null;
        this.currentOptions = [];
        this.correctCount = 0;
        this.wrongCount = 0;
        this.streak = 0;
        this.highestStreak = this.loadHighScore();
        this.isTapMode = false;
        this.isProcessingAnswer = false;

        this.init();
    }

    init() {
        this.loadWords();
        this.setupEventListeners();
        this.loadSettings();
    }

    loadHighScore() {
        const saved = localStorage.getItem('highestStreak');
        return saved ? parseInt(saved) : 0;
    }

    saveHighScore() {
        localStorage.setItem('highestStreak', this.highestStreak.toString());
    }

    loadSettings() {
        const tapMode = localStorage.getItem('tapMode');
        this.isTapMode = tapMode === 'true';
        document.getElementById('tapMode').checked = this.isTapMode;
    }

    saveSettings() {
        localStorage.setItem('tapMode', this.isTapMode.toString());
    }

    async loadWords() {
        try {
            const response = await fetch('words.json');
            this.wordsData = await response.json();
            this.selectNextWord();
        } catch (error) {
            console.error('Error loading words:', error);
            document.getElementById('definition').textContent = 'Error loading word data. Please refresh the page.';
        }
    }

    selectNextWord() {
        if (this.wordsData.length === 0) return;

        // Select random word
        const randomIndex = Math.floor(Math.random() * this.wordsData.length);
        this.currentWord = this.wordsData[randomIndex];

        // Get 3 random false words
        const falseWords = this.currentWord.false;
        const shuffledFalse = [...falseWords].sort(() => Math.random() - 0.5);
        const selectedFalse = shuffledFalse.slice(0, 3);

        // Create options array with correct word
        this.currentOptions = [...selectedFalse, this.currentWord.word];

        // Shuffle options
        this.currentOptions.sort(() => Math.random() - 0.5);

        // Update UI
        this.updateUI();
    }

    updateUI() {
        // Update definition
        document.getElementById('definition').textContent = this.currentWord.definition;

        // Update word buttons
        const buttons = document.querySelectorAll('.word-button');
        buttons.forEach((button, index) => {
            const wordText = button.querySelector('.word-text');
            wordText.textContent = this.currentOptions[index];
            button.classList.remove('correct', 'wrong', 'disabled');
        });

        // Update score
        this.updateScore();

        // Reset drop zone
        const dropZone = document.getElementById('dropZone');
        dropZone.querySelector('.gap-label').textContent = 'Drag or tap the correct word';
        dropZone.classList.remove('drag-over');
    }

    updateScore() {
        const totalWords = this.correctCount + this.wrongCount;
        const percentage = totalWords > 0 ? Math.round((this.correctCount / totalWords) * 100) : 0;

        document.getElementById('score').textContent =
            `streak: ${this.streak} | word count: ${totalWords} | correct: ${percentage}%`;
    }

    checkAnswer(selectedWord) {
        if (this.isProcessingAnswer) return;

        this.isProcessingAnswer = true;
        const isCorrect = selectedWord === this.currentWord.word;

        // Update statistics
        if (isCorrect) {
            this.correctCount++;
            this.streak++;

            if (this.streak > this.highestStreak) {
                this.highestStreak = this.streak;
                this.saveHighScore();
            }
        } else {
            this.wrongCount++;
            this.streak = 0;
        }

        // Show feedback
        this.showFeedback(isCorrect);

        // Highlight the selected button
        const buttons = document.querySelectorAll('.word-button');
        buttons.forEach(button => {
            const wordText = button.querySelector('.word-text').textContent;
            if (wordText === selectedWord) {
                button.classList.add(isCorrect ? 'correct' : 'wrong');
            }
            button.classList.add('disabled');
        });

        // Update drop zone
        const dropZone = document.getElementById('dropZone');
        dropZone.querySelector('.gap-label').textContent = selectedWord;

        // Move to next word after delay
        setTimeout(() => {
            if (isCorrect) {
                this.selectNextWord();
            }
            this.isProcessingAnswer = false;
        }, 1500);
    }

    showFeedback(isCorrect) {
        const feedback = document.getElementById('feedback');
        const feedbackImage = document.getElementById('feedbackImage');

        // Set the appropriate image
        if (isCorrect) {
            feedbackImage.src = 'Resources/imageexport/correct.png';
            feedbackImage.alt = 'Correct!';
        } else {
            feedbackImage.src = 'Resources/imageexport/wrong.png';
            feedbackImage.alt = 'Wrong!';
        }

        // Show feedback with animation
        feedback.classList.add('show');

        // Hide after animation
        setTimeout(() => {
            feedback.classList.remove('show');
        }, 1000);
    }

    setupEventListeners() {
        // Tap mode toggle
        document.getElementById('tapMode').addEventListener('change', (e) => {
            this.isTapMode = e.target.checked;
            this.saveSettings();
            this.updateDragEnabled();
        });

        // Word button click handlers
        const buttons = document.querySelectorAll('.word-button');
        buttons.forEach(button => {
            button.addEventListener('click', () => {
                if (!this.isProcessingAnswer) {
                    const selectedWord = button.querySelector('.word-text').textContent;
                    this.checkAnswer(selectedWord);
                }
            });

            // Drag start
            button.addEventListener('dragstart', (e) => {
                if (this.isTapMode) {
                    e.preventDefault();
                    return;
                }
                const word = button.querySelector('.word-text').textContent;
                e.dataTransfer.setData('text/plain', word);
                button.classList.add('dragging');
            });

            // Drag end
            button.addEventListener('dragend', () => {
                button.classList.remove('dragging');
            });
        });

        // Drop zone handlers
        const dropZone = document.getElementById('dropZone');

        dropZone.addEventListener('dragover', (e) => {
            if (this.isTapMode) return;
            e.preventDefault();
            dropZone.classList.add('drag-over');
        });

        dropZone.addEventListener('dragleave', () => {
            dropZone.classList.remove('drag-over');
        });

        dropZone.addEventListener('drop', (e) => {
            if (this.isTapMode) return;
            e.preventDefault();
            dropZone.classList.remove('drag-over');

            const word = e.dataTransfer.getData('text/plain');
            if (word && !this.isProcessingAnswer) {
                this.checkAnswer(word);
            }
        });
    }

    updateDragEnabled() {
        const buttons = document.querySelectorAll('.word-button');
        buttons.forEach(button => {
            button.draggable = !this.isTapMode;
        });
    }
}

// Initialize game when DOM is loaded
document.addEventListener('DOMContentLoaded', () => {
    const game = new BlanksGame();
});
