package com.ultrathink.vocabulary

import android.animation.AnimatorSet
import android.animation.ObjectAnimator
import android.app.AlertDialog
import android.graphics.Color
import android.os.Bundle
import android.view.DragEvent
import android.view.View
import android.view.animation.AccelerateDecelerateInterpolator
import android.view.animation.OvershootInterpolator
import android.widget.ImageView
import android.widget.PopupMenu
import android.widget.Toast
import androidx.activity.viewModels
import androidx.appcompat.app.AppCompatActivity
import androidx.core.content.ContextCompat
import com.google.android.material.button.MaterialButton
import com.ultrathink.vocabulary.databinding.ActivityMainBinding
import com.ultrathink.vocabulary.repository.GameRepository
import com.ultrathink.vocabulary.utils.ScoreManager

/**
 * Main game activity for the Ultrathink Vocabulary game
 * Supports both tap and drag-and-drop interaction modes
 */
class MainActivity : AppCompatActivity() {

    private lateinit var binding: ActivityMainBinding
    private lateinit var repository: GameRepository
    private lateinit var scoreManager: ScoreManager

    private val viewModel: GameViewModel by viewModels {
        GameViewModelFactory(repository, scoreManager)
    }

    private var isTappingMode = true
    private var currentDraggedWord: String? = null

    private val wordButtons by lazy {
        listOf(
            binding.wordOption1,
            binding.wordOption2,
            binding.wordOption3,
            binding.wordOption4
        )
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        binding = ActivityMainBinding.inflate(layoutInflater)
        setContentView(binding.root)

        // Initialize repository and score manager
        repository = GameRepository(this)
        scoreManager = ScoreManager(this)

        // Setup UI mode
        isTappingMode = viewModel.isTappingMode()
        setupInteractionMode()

        // Setup observers
        setupObservers()

        // Setup click listeners
        setupClickListeners()
    }

    /**
     * Setup observers for LiveData from ViewModel
     */
    private fun setupObservers() {
        // Observe current word
        viewModel.currentWord.observe(this) { wordModel ->
            displayWord(wordModel)
        }

        // Observe loading state
        viewModel.isLoading.observe(this) { isLoading ->
            binding.loadingIndicator.visibility = if (isLoading) View.VISIBLE else View.GONE
            binding.wordOptionsContainer.visibility = if (isLoading) View.GONE else View.VISIBLE
        }

        // Observe errors
        viewModel.error.observe(this) { error ->
            error?.let {
                Toast.makeText(this, it, Toast.LENGTH_LONG).show()
                viewModel.clearError()
            }
        }

        // Observe answer result
        viewModel.answerResult.observe(this) { isCorrect ->
            isCorrect?.let {
                showAnswerFeedback(it)
            }
        }

        // Observe score statistics
        viewModel.scoreStats.observe(this) { stats ->
            updateScoreDisplay(stats)
        }

        // Observe words loaded
        viewModel.wordsLoaded.observe(this) { loaded ->
            if (!loaded) {
                Toast.makeText(this, R.string.error_loading_words, Toast.LENGTH_LONG).show()
            }
        }
    }

    /**
     * Setup click listeners for buttons
     */
    private fun setupClickListeners() {
        // Settings button
        binding.settingsButton.setOnClickListener {
            showSettingsMenu(it)
        }

        // Word option buttons (for tap mode)
        wordButtons.forEachIndexed { index, button ->
            button.setOnClickListener {
                if (isTappingMode) {
                    handleWordSelection(button.text.toString())
                }
            }
        }

        // Setup drag listeners for gap zone
        if (!isTappingMode) {
            setupDragAndDrop()
        }
    }

    /**
     * Display word question with options
     */
    private fun displayWord(wordModel: com.ultrathink.vocabulary.model.WordModel) {
        // Update definition
        binding.definitionText.text = wordModel.definition

        // Update word options
        wordModel.options.forEachIndexed { index, word ->
            if (index < wordButtons.size) {
                wordButtons[index].text = word
                wordButtons[index].isEnabled = true
                // Reset button appearance
                wordButtons[index].alpha = 1f
            }
        }

        // Reset gap text
        binding.gapText.text = getString(R.string.gap_placeholder)
        binding.gapText.setTextColor(
            ContextCompat.getColor(this, R.color.md_theme_onSurfaceVariant)
        )
    }

    /**
     * Handle word selection in tap mode
     */
    private fun handleWordSelection(selectedWord: String) {
        // Disable all buttons temporarily
        wordButtons.forEach { it.isEnabled = false }

        // Check answer
        viewModel.checkAnswer(selectedWord)
    }

    /**
     * Show answer feedback (checkmark or X)
     */
    private fun showAnswerFeedback(isCorrect: Boolean) {
        val icon = if (isCorrect) R.drawable.ic_correct else R.drawable.ic_wrong
        binding.resultIcon.setImageResource(icon)
        binding.resultIcon.visibility = View.VISIBLE

        // Animate the icon
        animateResultIcon(isCorrect)
    }

    /**
     * Animate the result icon (scale up)
     */
    private fun animateResultIcon(isCorrect: Boolean) {
        binding.resultIcon.scaleX = 0f
        binding.resultIcon.scaleY = 0f

        val scaleX = ObjectAnimator.ofFloat(binding.resultIcon, View.SCALE_X, 0f, 1.3f, 1f)
        val scaleY = ObjectAnimator.ofFloat(binding.resultIcon, View.SCALE_Y, 0f, 1.3f, 1f)

        val animatorSet = AnimatorSet()
        animatorSet.playTogether(scaleX, scaleY)
        animatorSet.duration = 600
        animatorSet.interpolator = OvershootInterpolator()

        animatorSet.start()

        // Hide icon after delay
        binding.resultIcon.postDelayed({
            binding.resultIcon.visibility = View.GONE

            // Re-enable buttons if wrong answer (in tap mode)
            if (!isCorrect && isTappingMode) {
                wordButtons.forEach { it.isEnabled = true }
            }
        }, if (isCorrect) 1200 else 1500)
    }

    /**
     * Update score display
     */
    private fun updateScoreDisplay(stats: GameViewModel.ScoreStats) {
        binding.scoreText.text = String.format(
            "Streak: %d    Words: %d    Accuracy: %.0f%%",
            stats.streak,
            stats.wordCount,
            stats.accuracy
        )
    }

    /**
     * Show settings menu
     */
    private fun showSettingsMenu(anchor: View) {
        val popup = PopupMenu(this, anchor)
        popup.menuInflater.inflate(R.menu.settings_menu, popup.menu)

        // Set current mode checkmark
        val currentModeItem = if (isTappingMode) {
            popup.menu.findItem(R.id.menu_tap_mode)
        } else {
            popup.menu.findItem(R.id.menu_drag_mode)
        }
        currentModeItem?.isChecked = true

        popup.setOnMenuItemClickListener { item ->
            when (item.itemId) {
                R.id.menu_tap_mode -> {
                    if (!isTappingMode) {
                        switchToTapMode()
                    }
                    true
                }
                R.id.menu_drag_mode -> {
                    if (isTappingMode) {
                        switchToDragMode()
                    }
                    true
                }
                R.id.menu_reset_session -> {
                    showResetSessionDialog()
                    true
                }
                R.id.menu_reset_all -> {
                    showResetAllDialog()
                    true
                }
                else -> false
            }
        }

        popup.show()
    }

    /**
     * Switch to tap mode
     */
    private fun switchToTapMode() {
        isTappingMode = true
        viewModel.setTappingMode(true)
        setupInteractionMode()
        Toast.makeText(this, R.string.tap_mode, Toast.LENGTH_SHORT).show()
    }

    /**
     * Switch to drag mode
     */
    private fun switchToDragMode() {
        isTappingMode = false
        viewModel.setTappingMode(false)
        setupInteractionMode()
        Toast.makeText(this, R.string.drag_mode, Toast.LENGTH_SHORT).show()
    }

    /**
     * Setup interaction mode (tap or drag)
     */
    private fun setupInteractionMode() {
        if (isTappingMode) {
            // Enable buttons, disable drag
            wordButtons.forEach { button ->
                button.isEnabled = true
                button.setOnLongClickListener(null)
            }
            binding.gapZone.setOnDragListener(null)
        } else {
            // Enable drag and drop
            setupDragAndDrop()
        }
    }

    /**
     * Setup drag and drop functionality
     */
    private fun setupDragAndDrop() {
        // Setup long click listeners for dragging
        wordButtons.forEach { button ->
            button.setOnLongClickListener { view ->
                currentDraggedWord = (view as MaterialButton).text.toString()

                // Create drag shadow
                val shadowBuilder = View.DragShadowBuilder(view)
                view.startDragAndDrop(null, shadowBuilder, view, 0)

                // Reduce alpha during drag
                view.alpha = 0.5f

                true
            }
        }

        // Setup drop listener for gap zone
        binding.gapZone.setOnDragListener { view, event ->
            when (event.action) {
                DragEvent.ACTION_DRAG_STARTED -> {
                    true
                }
                DragEvent.ACTION_DRAG_ENTERED -> {
                    // Highlight drop zone
                    binding.gapText.setTextColor(
                        ContextCompat.getColor(this, R.color.md_theme_primary)
                    )
                    true
                }
                DragEvent.ACTION_DRAG_EXITED -> {
                    // Remove highlight
                    binding.gapText.setTextColor(
                        ContextCompat.getColor(this, R.color.md_theme_onSurfaceVariant)
                    )
                    true
                }
                DragEvent.ACTION_DROP -> {
                    // Handle drop
                    currentDraggedWord?.let { word ->
                        handleWordDrop(word)
                    }
                    true
                }
                DragEvent.ACTION_DRAG_ENDED -> {
                    // Reset alpha for all buttons
                    wordButtons.forEach { it.alpha = 1f }

                    // Reset gap color
                    binding.gapText.setTextColor(
                        ContextCompat.getColor(this, R.color.md_theme_onSurfaceVariant)
                    )
                    true
                }
                else -> false
            }
        }
    }

    /**
     * Handle word drop in drag mode
     */
    private fun handleWordDrop(word: String) {
        // Update gap text
        binding.gapText.text = word
        binding.gapText.setTextColor(
            ContextCompat.getColor(this, R.color.md_theme_onSurface)
        )

        // Animate word to gap
        animateWordToGap()

        // Check answer
        viewModel.checkAnswer(word)
    }

    /**
     * Animate word moving to gap
     */
    private fun animateWordToGap() {
        val scaleX = ObjectAnimator.ofFloat(binding.gapText, View.SCALE_X, 0.8f, 1f)
        val scaleY = ObjectAnimator.ofFloat(binding.gapText, View.SCALE_Y, 0.8f, 1f)

        val animatorSet = AnimatorSet()
        animatorSet.playTogether(scaleX, scaleY)
        animatorSet.duration = 300
        animatorSet.interpolator = AccelerateDecelerateInterpolator()
        animatorSet.start()
    }

    /**
     * Show reset session dialog
     */
    private fun showResetSessionDialog() {
        AlertDialog.Builder(this)
            .setTitle(R.string.reset_session)
            .setMessage(R.string.reset_session_confirm_message)
            .setPositiveButton(R.string.yes) { _, _ ->
                viewModel.resetSession()
                Toast.makeText(this, "Session reset", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton(R.string.no, null)
            .show()
    }

    /**
     * Show reset all statistics dialog
     */
    private fun showResetAllDialog() {
        AlertDialog.Builder(this)
            .setTitle(R.string.reset_confirm_title)
            .setMessage(R.string.reset_confirm_message)
            .setPositiveButton(R.string.yes) { _, _ ->
                viewModel.resetAllStats()
                Toast.makeText(this, "All statistics reset", Toast.LENGTH_SHORT).show()
            }
            .setNegativeButton(R.string.no, null)
            .show()
    }
}
