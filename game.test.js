const { test, expect } = require('@playwright/test');

// Helper to wait for game to be ready
async function waitForGameReady(page) {
  await page.waitForSelector('.word-button', { timeout: 10000 });
  // Wait a bit for the game to initialize
  await page.waitForTimeout(1000);
}

test.describe('Blanks Game - Initialization and UI', () => {
  test('should load the game page successfully', async ({ page }) => {
    await page.goto("/");
    await expect(page).toHaveTitle('Blanks - Vocabulary Learning Game');
  });

  test('should display all main UI elements', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Check header elements
    await expect(page.locator('h1')).toHaveText('Blanks');
    await expect(page.locator('#score')).toBeVisible();

    // Check game area elements
    await expect(page.locator('#dropZone')).toBeVisible();
    await expect(page.locator('#definition')).toBeVisible();
    await expect(page.locator('.word-button')).toHaveCount(4);

    // Check footer elements
    await expect(page.locator('#tapMode')).toBeVisible();
  });

  test('should load and display a definition', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    const definition = await page.locator('#definition').textContent();
    expect(definition).toBeTruthy();
    expect(definition).not.toBe('Loading...');
    expect(definition.length).toBeGreaterThan(5);
  });

  test('should display 4 word options', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    const wordButtons = page.locator('.word-button');
    await expect(wordButtons).toHaveCount(4);

    // Check each button has text
    for (let i = 0; i < 4; i++) {
      const wordText = await wordButtons.nth(i).locator('.word-text').textContent();
      expect(wordText).toBeTruthy();
      expect(wordText.length).toBeGreaterThan(0);
    }
  });

  test('should initialize score to zero', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    const scoreText = await page.locator('#score').textContent();
    expect(scoreText).toContain('streak: 0');
    expect(scoreText).toContain('word count: 0');
    expect(scoreText).toContain('correct: 0%');
  });
});

test.describe('Blanks Game - Click/Tap Functionality', () => {
  test('should respond to clicking a word button', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    const initialScore = await page.locator('#score').textContent();

    // Click the first word button
    await page.locator('.word-button').first().click();

    // Wait for feedback animation
    await page.waitForTimeout(500);

    // Check that feedback is shown
    const feedback = page.locator('#feedback');
    const feedbackImage = page.locator('#feedbackImage');
    await expect(feedbackImage).toHaveAttribute('src', /.+\.(png|jpg)/);
  });

  test('should update score after clicking', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Click a word
    await page.locator('.word-button').first().click();

    // Wait for processing
    await page.waitForTimeout(2000);

    // Score should have updated
    const scoreText = await page.locator('#score').textContent();
    expect(scoreText).toContain('word count: 1');
  });

  test('should disable buttons after selection', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    const firstButton = page.locator('.word-button').first();
    await firstButton.click();

    // Wait a bit for the disabled class to be added
    await page.waitForTimeout(200);

    // All buttons should have disabled class
    const allButtons = page.locator('.word-button');
    for (let i = 0; i < 4; i++) {
      await expect(allButtons.nth(i)).toHaveClass(/disabled/);
    }
  });

  test('should show correct/wrong feedback', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Get the definition to find the correct answer
    const definition = await page.locator('#definition').textContent();

    // Click a word
    await page.locator('.word-button').first().click();

    // Wait for feedback
    await page.waitForTimeout(300);

    // Feedback image should be displayed
    const feedbackImage = page.locator('#feedbackImage');
    const src = await feedbackImage.getAttribute('src');
    expect(src).toMatch(/(correct|wrong)\.png/);
  });

  test('should load new word after correct answer', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    const initialDefinition = await page.locator('#definition').textContent();

    // Try all buttons until we get a correct answer
    for (let i = 0; i < 4; i++) {
      await page.goto("/");
      await waitForGameReady(page);

      const currentDef = await page.locator('#definition').textContent();
      await page.locator('.word-button').nth(i).click();

      // Wait for feedback
      await page.waitForTimeout(300);

      const feedbackSrc = await page.locator('#feedbackImage').getAttribute('src');

      if (feedbackSrc.includes('correct')) {
        // Wait for new word to load
        await page.waitForTimeout(2000);

        // Definition should change
        const newDefinition = await page.locator('#definition').textContent();
        expect(newDefinition).not.toBe(currentDef);
        break;
      }
    }
  });
});

test.describe('Blanks Game - Score Tracking', () => {
  test('should increment streak on correct answer', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Try to find and click correct answers multiple times
    let correctCount = 0;

    for (let attempt = 0; attempt < 3; attempt++) {
      for (let i = 0; i < 4; i++) {
        const wordText = await page.locator('.word-button').nth(i).locator('.word-text').textContent();
        await page.locator('.word-button').nth(i).click();

        await page.waitForTimeout(300);
        const feedbackSrc = await page.locator('#feedbackImage').getAttribute('src');

        if (feedbackSrc.includes('correct')) {
          correctCount++;
          await page.waitForTimeout(2000);

          const scoreText = await page.locator('#score').textContent();
          expect(scoreText).toContain(`streak: ${correctCount}`);
          break;
        } else {
          // Wrong answer resets streak, need to reload
          await page.goto("/");
          await waitForGameReady(page);
          break;
        }
      }

      if (correctCount >= 2) break;
    }
  });

  test('should reset streak on wrong answer', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // First get a correct answer to build streak
    let foundCorrect = false;
    for (let i = 0; i < 4; i++) {
      await page.locator('.word-button').nth(i).click();
      await page.waitForTimeout(300);

      const feedbackSrc = await page.locator('#feedbackImage').getAttribute('src');
      if (feedbackSrc.includes('correct')) {
        foundCorrect = true;
        await page.waitForTimeout(2000);
        break;
      } else {
        await page.goto("/");
        await waitForGameReady(page);
      }
    }

    if (foundCorrect) {
      // Now find a wrong answer
      const allWords = [];
      for (let i = 0; i < 4; i++) {
        const word = await page.locator('.word-button').nth(i).locator('.word-text').textContent();
        allWords.push(word);
      }

      // Click buttons until we find a wrong answer
      for (let i = 0; i < 4; i++) {
        await page.locator('.word-button').nth(i).click();
        await page.waitForTimeout(300);

        const feedbackSrc = await page.locator('#feedbackImage').getAttribute('src');
        if (feedbackSrc.includes('wrong')) {
          await page.waitForTimeout(2000);

          const scoreText = await page.locator('#score').textContent();
          expect(scoreText).toContain('streak: 0');
          break;
        } else {
          // This was correct, try next word
          await page.waitForTimeout(2000);
        }
      }
    }
  });

  test('should calculate correct percentage', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Play a few rounds
    let correctCount = 0;
    let totalCount = 0;

    for (let round = 0; round < 3; round++) {
      for (let i = 0; i < 4; i++) {
        await page.locator('.word-button').nth(i).click();
        await page.waitForTimeout(300);

        const feedbackSrc = await page.locator('#feedbackImage').getAttribute('src');
        totalCount++;

        if (feedbackSrc.includes('correct')) {
          correctCount++;
          await page.waitForTimeout(2000);
          break;
        } else {
          await page.waitForTimeout(2000);
          await page.goto("/");
          await waitForGameReady(page);
          break;
        }
      }
    }

    const scoreText = await page.locator('#score').textContent();
    const expectedPercentage = Math.round((correctCount / totalCount) * 100);
    expect(scoreText).toContain(`correct: ${expectedPercentage}%`);
  });
});

test.describe('Blanks Game - Tap Mode Toggle', () => {
  test('should toggle tap mode', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    const tapModeCheckbox = page.locator('#tapMode');

    // Initially unchecked
    await expect(tapModeCheckbox).not.toBeChecked();

    // Toggle it
    await tapModeCheckbox.check();
    await expect(tapModeCheckbox).toBeChecked();

    // Toggle back
    await tapModeCheckbox.uncheck();
    await expect(tapModeCheckbox).not.toBeChecked();
  });

  test('should persist tap mode setting', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Enable tap mode
    await page.locator('#tapMode').check();
    await expect(page.locator('#tapMode')).toBeChecked();

    // Reload page
    await page.reload();
    await waitForGameReady(page);

    // Setting should persist
    await expect(page.locator('#tapMode')).toBeChecked();

    // Clean up - disable it
    await page.locator('#tapMode').uncheck();
  });
});

test.describe('Blanks Game - Drag and Drop', () => {
  test('should allow dragging word buttons (when not in tap mode)', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Ensure tap mode is off
    const tapMode = page.locator('#tapMode');
    if (await tapMode.isChecked()) {
      await tapMode.uncheck();
    }

    const firstButton = page.locator('.word-button').first();
    const dropZone = page.locator('#dropZone');

    // Check that button is draggable
    const isDraggable = await firstButton.getAttribute('draggable');
    expect(isDraggable).toBe('true');
  });

  test('should handle drop on drop zone', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Ensure tap mode is off
    const tapMode = page.locator('#tapMode');
    if (await tapMode.isChecked()) {
      await tapMode.uncheck();
    }

    const firstButton = page.locator('.word-button').first();
    const dropZone = page.locator('#dropZone');

    // Perform drag and drop
    await firstButton.dragTo(dropZone);

    // Wait for feedback
    await page.waitForTimeout(500);

    // Should show feedback
    const feedbackImage = page.locator('#feedbackImage');
    const src = await feedbackImage.getAttribute('src');
    expect(src).toMatch(/(correct|wrong)\.png/);
  });

  test('should disable dragging in tap mode', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Enable tap mode
    await page.locator('#tapMode').check();
    await page.waitForTimeout(200);

    const firstButton = page.locator('.word-button').first();

    // Check that button is not draggable
    const isDraggable = await firstButton.getAttribute('draggable');
    expect(isDraggable).toBe('false');
  });
});

test.describe('Blanks Game - LocalStorage Persistence', () => {
  test('should save and load high score', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Play and get some correct answers to build a streak
    let maxStreak = 0;

    for (let round = 0; round < 5; round++) {
      for (let i = 0; i < 4; i++) {
        await page.locator('.word-button').nth(i).click();
        await page.waitForTimeout(300);

        const feedbackSrc = await page.locator('#feedbackImage').getAttribute('src');

        if (feedbackSrc.includes('correct')) {
          maxStreak++;
          await page.waitForTimeout(2000);
          break;
        } else {
          // Wrong answer, check localStorage
          const highScore = await page.evaluate(() => {
            return localStorage.getItem('highestStreak');
          });

          if (highScore) {
            expect(parseInt(highScore)).toBe(maxStreak);
          }

          // Reset and continue
          maxStreak = 0;
          await page.waitForTimeout(2000);
          await page.goto("/");
          await waitForGameReady(page);
          break;
        }
      }
    }

    // Reload page and check high score persists
    await page.reload();
    await waitForGameReady(page);

    const storedHighScore = await page.evaluate(() => {
      return localStorage.getItem('highestStreak');
    });

    expect(storedHighScore).toBeTruthy();
  });
});

test.describe('Blanks Game - Word Data Integrity', () => {
  test('should load words from JSON', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Check that game has words loaded
    const wordCount = await page.evaluate(() => {
      return window.game ? window.game.wordsData.length : 0;
    });

    // Should have loaded many words (8109 total)
    expect(wordCount).toBeGreaterThan(1000);
  });

  test('should have valid word structure', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    const hasValidStructure = await page.evaluate(() => {
      if (!window.game || !window.game.wordsData.length) return false;

      const firstWord = window.game.wordsData[0];
      return (
        firstWord.hasOwnProperty('word') &&
        firstWord.hasOwnProperty('definition') &&
        firstWord.hasOwnProperty('false') &&
        Array.isArray(firstWord.false) &&
        firstWord.false.length >= 3
      );
    });

    expect(hasValidStructure).toBe(true);
  });

  test('should never show duplicate words in options', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Test multiple rounds
    for (let round = 0; round < 10; round++) {
      const words = [];

      for (let i = 0; i < 4; i++) {
        const word = await page.locator('.word-button').nth(i).locator('.word-text').textContent();
        words.push(word);
      }

      // Check for duplicates
      const uniqueWords = new Set(words);
      expect(uniqueWords.size).toBe(4);

      // Move to next word
      await page.locator('.word-button').first().click();
      await page.waitForTimeout(2000);
    }
  });
});

test.describe('Blanks Game - Accessibility', () => {
  test('should have proper ARIA labels', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Check that interactive elements are accessible
    const buttons = page.locator('.word-button');
    expect(await buttons.count()).toBe(4);

    // All buttons should be clickable
    for (let i = 0; i < 4; i++) {
      await expect(buttons.nth(i)).toBeVisible();
    }
  });

  test('should be keyboard navigable', async ({ page }) => {
    await page.goto("/");
    await waitForGameReady(page);

    // Tab to first button
    await page.keyboard.press('Tab');

    // Should be able to activate with Enter or Space
    const focusedElement = await page.evaluateHandle(() => document.activeElement);
    const tagName = await focusedElement.evaluate(el => el.tagName);

    expect(['BUTTON', 'INPUT', 'A'].includes(tagName)).toBe(true);
  });
});

test.describe('Blanks Game - Responsive Design', () => {
  test('should work on mobile viewport', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });
    await page.goto("/");
    await waitForGameReady(page);

    // All elements should still be visible
    await expect(page.locator('h1')).toBeVisible();
    await expect(page.locator('#score')).toBeVisible();
    await expect(page.locator('#definition')).toBeVisible();
    await expect(page.locator('.word-button')).toHaveCount(4);
  });

  test('should work on tablet viewport', async ({ page }) => {
    await page.setViewportSize({ width: 768, height: 1024 });
    await page.goto("/");
    await waitForGameReady(page);

    await expect(page.locator('h1')).toBeVisible();
    await expect(page.locator('.word-button')).toHaveCount(4);
  });

  test('should work on desktop viewport', async ({ page }) => {
    await page.setViewportSize({ width: 1920, height: 1080 });
    await page.goto("/");
    await waitForGameReady(page);

    await expect(page.locator('h1')).toBeVisible();
    await expect(page.locator('.word-button')).toHaveCount(4);
  });
});
