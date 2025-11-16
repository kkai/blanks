const { test, expect } = require('@playwright/test');

// Helper to wait for game to load
async function waitForGameLoad(page) {
  await page.waitForSelector('body', { timeout: 10000 });
  await page.waitForTimeout(1000);
}

test.describe('Game Collection - All Games Playability', () => {

  test('Game Launcher - should display all 15 games', async ({ page }) => {
    await page.goto('/games/index.html');
    await waitForGameLoad(page);

    // Check title
    await expect(page.locator('.main-title')).toContainText('Vocabulary Game Collection');

    // Check subtitle mentions correct numbers
    await expect(page.locator('.main-subtitle')).toContainText('15 Fun Ways');

    // Check all 15 game cards are present
    const gameCards = page.locator('.game-card');
    await expect(gameCards).toHaveCount(15);

    // Verify each game has required elements
    for (let i = 0; i < 15; i++) {
      const card = gameCards.nth(i);
      await expect(card.locator('.game-title')).toBeVisible();
      await expect(card.locator('.game-description')).toBeVisible();
      await expect(card.locator('.play-btn')).toBeVisible();
    }
  });

  test('Game 1: Word Waterfall - loads and starts', async ({ page }) => {
    await page.goto('/games/word-waterfall.html');
    await waitForGameLoad(page);

    // Check game title
    await expect(page.locator('.game-title')).toContainText('Word Waterfall');

    // Check start screen
    await expect(page.locator('button:has-text("Start Game")')).toBeVisible();

    // Start game
    await page.click('button:has-text("Start Game")');
    await page.waitForTimeout(1000);

    // Check game elements appear
    await expect(page.locator('#typingInput')).toBeVisible();
    await expect(page.locator('.lives-display')).toBeVisible();
  });

  test('Game 2: Memory Constellation - loads and is playable', async ({ page }) => {
    await page.goto('/games/memory-constellation.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Memory Constellation');

    // Check for cards
    const cards = page.locator('.memory-card');
    await expect(cards).toHaveCount(12);

    // Try clicking a card
    await cards.first().click();
    await page.waitForTimeout(300);

    // Card should flip (have flipped class or show content)
    const firstCard = cards.first();
    await expect(firstCard).toHaveClass(/flipped|show/);
  });

  test('Game 3: Definition Detective - loads and shows questions', async ({ page }) => {
    await page.goto('/games/definition-detective.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Definition Detective');

    // Check definition with blanks appears
    await expect(page.locator('#definition')).toBeVisible();

    // Check 4 options
    const options = page.locator('.option-btn');
    await expect(options).toHaveCount(4);

    // Click an option
    await options.first().click();
    await page.waitForTimeout(500);
  });

  test('Game 4: Word Chain Reaction - loads and allows selection', async ({ page }) => {
    await page.goto('/games/word-chain-reaction.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Word Chain Reaction');

    // Start game
    const startBtn = page.locator('button:has-text("Start Game")');
    if (await startBtn.isVisible()) {
      await startBtn.click();
      await page.waitForTimeout(1000);
    }

    // Check word cards appear
    const wordCards = page.locator('.word-card');
    const count = await wordCards.count();
    expect(count).toBeGreaterThan(0);
  });

  test('Game 5: Speed Synonym Swap - loads and timer works', async ({ page }) => {
    await page.goto('/games/speed-synonym-swap.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Speed Synonym Swap');

    // Start game
    await page.click('button:has-text("Start Game")');
    await page.waitForTimeout(1000);

    // Check timer is running
    const timer = page.locator('#timer');
    await expect(timer).toBeVisible();
    const initialTime = await timer.textContent();

    await page.waitForTimeout(2000);
    const newTime = await timer.textContent();
    expect(newTime).not.toBe(initialTime);
  });

  test('Game 6: Vocabulary Voyage - loads and shows path', async ({ page }) => {
    await page.goto('/games/vocabulary-voyage.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Vocabulary Voyage');

    // Check waypoints exist
    const waypoints = page.locator('.waypoint');
    await expect(waypoints.first()).toBeVisible();

    // Click first waypoint to start question
    await waypoints.first().click();
    await page.waitForTimeout(500);
  });

  test('Game 7: Word Constructor - loads and shows scrambled word', async ({ page }) => {
    await page.goto('/games/word-constructor.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Word Constructor');

    // Check scrambled letters appear
    const letters = page.locator('.letter-tile');
    const count = await letters.count();
    expect(count).toBeGreaterThan(0);

    // Check definition is shown
    await expect(page.locator('#definition')).toBeVisible();
  });

  test('Game 8: Definition Duel - loads with split screen', async ({ page }) => {
    await page.goto('/games/definition-duel.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Definition Duel');

    // Start game
    const startBtn = page.locator('button:has-text("Start Game")');
    if (await startBtn.isVisible()) {
      await startBtn.click();
      await page.waitForTimeout(1000);
    }

    // Check both sides exist
    await expect(page.locator('#leftDefinition')).toBeVisible();
    await expect(page.locator('#rightDefinition')).toBeVisible();
  });

  test('Game 9: Vocabulary Garden - loads with garden plots', async ({ page }) => {
    await page.goto('/games/vocabulary-garden.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Vocabulary Garden');

    // Check garden plots
    const plots = page.locator('.garden-plot');
    await expect(plots).toHaveCount(3);

    // Check seeds
    const seeds = page.locator('.seed-card');
    const count = await seeds.count();
    expect(count).toBeGreaterThan(0);
  });

  test('Game 10: Echo Chamber - loads and shows fading definition', async ({ page }) => {
    await page.goto('/games/echo-chamber.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Echo Chamber');

    // Check lives display
    await expect(page.locator('.hearts')).toBeVisible();

    // Check definition appears
    await expect(page.locator('#definition')).toBeVisible();
  });

  test('Game 11: Word Ladder Climb - loads with ladder visual', async ({ page }) => {
    await page.goto('/games/word-ladder-climb.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Word Ladder');

    // Check ladder exists
    await expect(page.locator('.ladder')).toBeVisible();

    // Check question area
    await expect(page.locator('#definition')).toBeVisible();

    // Check options
    const options = page.locator('.option-btn');
    await expect(options).toHaveCount(4);
  });

  test('Game 12: Crossword Quickfire - loads with grid', async ({ page }) => {
    await page.goto('/games/crossword-quickfire.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Crossword');

    // Check crossword grid
    await expect(page.locator('.crossword-grid')).toBeVisible();

    // Check clues
    await expect(page.locator('.clues-section')).toBeVisible();

    // Check cells
    const cells = page.locator('.crossword-cell');
    const count = await cells.count();
    expect(count).toBeGreaterThan(0);
  });

  test('Game 13: True or False Cascade - loads and shows pairs', async ({ page }) => {
    await page.goto('/games/true-or-false-cascade.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('True or False');

    // Check word and definition display
    await expect(page.locator('#currentWord')).toBeVisible();
    await expect(page.locator('#currentDefinition')).toBeVisible();

    // Check True/False buttons
    await expect(page.locator('button:has-text("TRUE")')).toBeVisible();
    await expect(page.locator('button:has-text("FALSE")')).toBeVisible();
  });

  test('Game 14: Word Auction - loads with bidding interface', async ({ page }) => {
    await page.goto('/games/word-auction.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Word Auction');

    // Check wallet display
    await expect(page.locator('#balance')).toBeVisible();

    // Check definition
    await expect(page.locator('#definition')).toBeVisible();

    // Check bid slider
    await expect(page.locator('#bidSlider')).toBeVisible();
  });

  test('Game 15: Timeline Challenge - loads with matching interface', async ({ page }) => {
    await page.goto('/games/timeline-challenge.html');
    await waitForGameLoad(page);

    await expect(page.locator('.game-title')).toContainText('Timeline Challenge');

    // Check timer
    await expect(page.locator('#timer')).toBeVisible();

    // Check word columns
    const words = page.locator('.word-item');
    const definitions = page.locator('.definition-item');

    await expect(words.first()).toBeVisible();
    await expect(definitions.first()).toBeVisible();
  });

  test('All games - Back button functionality', async ({ page }) => {
    const games = [
      'word-waterfall.html',
      'memory-constellation.html',
      'definition-detective.html',
      'word-chain-reaction.html',
      'speed-synonym-swap.html',
      'vocabulary-voyage.html',
      'word-constructor.html',
      'definition-duel.html',
      'vocabulary-garden.html',
      'echo-chamber.html',
      'word-ladder-climb.html',
      'crossword-quickfire.html',
      'true-or-false-cascade.html',
      'word-auction.html',
      'timeline-challenge.html'
    ];

    for (const game of games) {
      await page.goto(`/games/${game}`);
      await waitForGameLoad(page);

      // Check back button exists
      const backButton = page.locator('a[href*="index.html"], .back-btn, a:has-text("Back")');
      await expect(backButton.first()).toBeVisible();
    }
  });

  test('All games - Load shared utilities', async ({ page }) => {
    const games = [
      'word-waterfall.html',
      'memory-constellation.html',
      'definition-detective.html'
    ];

    for (const game of games) {
      await page.goto(`/games/${game}`);
      await waitForGameLoad(page);

      // Check if VocabularyGameUtils is loaded
      const hasUtils = await page.evaluate(() => {
        return typeof VocabularyGameUtils !== 'undefined';
      });

      expect(hasUtils).toBe(true);
    }
  });

  test('All games - Responsive design on mobile', async ({ page }) => {
    await page.setViewportSize({ width: 375, height: 667 });

    const games = [
      'memory-constellation.html',
      'speed-synonym-swap.html',
      'word-constructor.html'
    ];

    for (const game of games) {
      await page.goto(`/games/${game}`);
      await waitForGameLoad(page);

      // Check game container is visible
      await expect(page.locator('.game-container, body')).toBeVisible();

      // Check title is visible
      await expect(page.locator('.game-title, h1')).toBeVisible();
    }
  });
});
