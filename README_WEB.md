# Blanks - Web Version

A JavaScript-based vocabulary learning game that can be hosted on any static website.

## About

Blanks is a simple yet effective vocabulary learning game where players:
- Read a word definition
- Choose the correct word from 4 options
- Get immediate feedback
- Track their learning progress

## Features

- **8,109 vocabulary words** with definitions
- **Drag & Drop or Tap** interaction modes
- **Score tracking** with streak counter
- **Responsive design** works on desktop and mobile
- **Local storage** saves high scores and preferences
- **No backend required** - pure static website

## How to Play

1. Open `index.html` in a web browser
2. Read the definition displayed
3. Either:
   - **Drag** a word to the drop zone, or
   - **Tap/Click** on the correct word
4. Get instant feedback (correct/wrong)
5. Continue building your streak!

## Game Modes

- **Drag Mode** (default): Drag words to the answer area
- **Tap Mode**: Simply click/tap on the correct word

Toggle between modes using the checkbox at the bottom.

## Files

- `index.html` - Main game interface
- `style.css` - All styling and animations
- `game.js` - Game logic and interactivity
- `words.json` - 8,109 words with definitions (converted from iOS version)
- `Resources/imageexport/` - Feedback images (correct/wrong icons)

## Hosting

Since this is a static website, you can host it on:

- **GitHub Pages**: Push to a repo and enable Pages
- **Netlify**: Drag and drop the folder
- **Vercel**: Deploy with one command
- **Any web server**: Upload files via FTP
- **Local**: Just open `index.html` in a browser

### Quick Deploy to GitHub Pages

```bash
# Already on the branch
git add .
git commit -m "Add JavaScript web version of Blanks game"
git push -u origin claude/javascript-game-version-01UVGMxWzc5zMiCN7E2oJwhY

# Then enable GitHub Pages in repository settings
```

## Browser Compatibility

Works on all modern browsers:
- Chrome/Edge (latest)
- Firefox (latest)
- Safari (latest)
- Mobile browsers (iOS Safari, Chrome Mobile)

## Statistics Tracked

- **Streak**: Consecutive correct answers
- **Word Count**: Total words attempted
- **Correct %**: Percentage of correct answers
- **High Score**: Best streak (saved in browser)

## Development

The game uses vanilla JavaScript with no dependencies. It's built with:

- ES6 Classes for game logic
- Fetch API for loading words
- LocalStorage for persistence
- CSS Grid for responsive layout
- CSS Animations for feedback

## Original Version

This is a web port of the iOS app. The original iOS version was built with Objective-C and UIKit.

## License

See LICENSE file for details.

## Credits

Original iOS app created by Kai Kunze (2012-2013)
Web version ported in 2025
