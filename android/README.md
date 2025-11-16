# Ultrathink Vocabulary - Android

A vocabulary learning game for Android, based on the iOS Ultrathink app. Test your vocabulary knowledge by matching definitions with the correct words.

## Features

- **8,109 vocabulary words** with definitions and multiple choice options
- **Two interaction modes:**
  - **Tap Mode**: Simply tap the correct word
  - **Drag Mode**: Long-press and drag words to the gap
- **Score tracking:**
  - Current streak counter
  - Total words attempted
  - Accuracy percentage
  - High score (best streak) persistence
- **Material Design 3 UI** with smooth animations
- **Statistics persistence** across app sessions

## Game Mechanics

1. A definition is displayed at the top of the screen
2. Four word options are presented below
3. Select the correct word by either:
   - **Tapping** the word button (Tap Mode)
   - **Long-pressing and dragging** the word to the gap (Drag Mode)
4. Visual feedback shows if your answer is correct (✓) or wrong (✗)
5. After a correct answer, the game automatically advances to the next word
6. Your streak increases with each correct answer and resets on wrong answers

## Project Structure

```
android/
├── app/
│   ├── src/main/
│   │   ├── java/com/ultrathink/vocabulary/
│   │   │   ├── MainActivity.kt              # Main game activity
│   │   │   ├── GameViewModel.kt             # Game state management
│   │   │   ├── GameViewModelFactory.kt      # ViewModel factory
│   │   │   ├── model/
│   │   │   │   ├── WordEntry.kt             # Word data from JSON
│   │   │   │   └── WordModel.kt             # Word question model
│   │   │   ├── repository/
│   │   │   │   └── GameRepository.kt        # Word loading & selection
│   │   │   └── utils/
│   │   │       └── ScoreManager.kt          # Score persistence
│   │   ├── res/
│   │   │   ├── layout/
│   │   │   │   └── activity_main.xml        # Main UI layout
│   │   │   ├── drawable/                    # Icons and graphics
│   │   │   ├── values/                      # Strings, colors, themes
│   │   │   └── menu/                        # Settings menu
│   │   └── assets/
│   │       └── words.json                   # Vocabulary database
│   └── build.gradle.kts
├── build.gradle.kts
├── settings.gradle.kts
└── README.md
```

## Technical Details

### Architecture
- **MVVM Pattern** (Model-View-ViewModel)
- **LiveData** for reactive UI updates
- **Coroutines** for asynchronous operations
- **SharedPreferences** for data persistence

### Technologies Used
- **Language**: Kotlin
- **Min SDK**: 24 (Android 7.0)
- **Target SDK**: 34 (Android 14)
- **UI**: Material Design 3, ConstraintLayout
- **Libraries**:
  - AndroidX Core, AppCompat, Activity KTX
  - Material Components
  - Lifecycle (ViewModel, LiveData)
  - Kotlin Coroutines
  - Gson (JSON parsing)

## Setup & Installation

### Prerequisites
1. **Android Studio** (Hedgehog 2023.1.1 or newer)
2. **JDK** 17 or newer
3. **Android SDK** with API level 34

### Steps

1. **Clone or copy the android project folder**

2. **Configure Android SDK path**
   - Copy `local.properties.template` to `local.properties`
   - Edit `local.properties` and set your SDK path:
     ```
     sdk.dir=/path/to/your/android/sdk
     ```

3. **Open in Android Studio**
   - Open Android Studio
   - Select "Open an Existing Project"
   - Navigate to the `android` folder
   - Wait for Gradle sync to complete

4. **Build the project**
   ```bash
   ./gradlew build
   ```

5. **Run on device or emulator**
   - Connect an Android device or start an emulator
   - Click the "Run" button in Android Studio
   - Or use: `./gradlew installDebug`

## Building Release APK

```bash
./gradlew assembleRelease
```

The APK will be generated at:
`app/build/outputs/apk/release/app-release-unsigned.apk`

### Signing the APK

For production release, you'll need to sign the APK:

1. Create a keystore:
   ```bash
   keytool -genkey -v -keystore ultrathink.keystore -alias ultrathink -keyalg RSA -keysize 2048 -validity 10000
   ```

2. Configure signing in `app/build.gradle.kts`:
   ```kotlin
   android {
       signingConfigs {
           create("release") {
               storeFile = file("ultrathink.keystore")
               storePassword = "your-password"
               keyAlias = "ultrathink"
               keyPassword = "your-password"
           }
       }
       buildTypes {
           release {
               signingConfig = signingConfigs.getByName("release")
           }
       }
   }
   ```

3. Build signed APK:
   ```bash
   ./gradlew assembleRelease
   ```

## Usage

### Switching Between Modes
1. Tap the settings icon (⚙️) in the top-right corner
2. Select either "Tap Mode" or "Drag Mode"

### Resetting Statistics
1. Tap the settings icon
2. Choose:
   - **Reset Session**: Clears current session stats (keeps high score)
   - **Reset All Stats**: Clears all statistics including high score

## Data Format

The vocabulary words are stored in `app/src/main/assets/words.json`:

```json
[
  {
    "word": "abacinate",
    "definition": "blind by holding a red-hot metal plate before someone's eyes",
    "false": [
      "reiterate",
      "illustrate",
      "hypnotize",
      "disrobe"
    ]
  },
  ...
]
```

Each entry contains:
- `word`: The correct answer
- `definition`: The definition to display
- `false`: Array of 3-4 incorrect word options

## Customization

### Adding More Words
1. Edit `app/src/main/assets/words.json`
2. Add new entries following the existing format
3. Rebuild the app

### Changing Colors
Edit `app/src/main/res/values/colors.xml` to customize:
- Primary/secondary colors
- Correct/wrong feedback colors
- Background colors

### Adjusting Animations
Modify animation durations in `MainActivity.kt`:
- Search for `duration` properties
- Adjust timing in milliseconds

## Testing

Run unit tests:
```bash
./gradlew test
```

Run instrumented tests on device:
```bash
./gradlew connectedAndroidTest
```

## Troubleshooting

### Gradle Sync Failed
- Ensure you have the correct Android SDK installed
- Check `local.properties` has the correct SDK path
- Try "File → Invalidate Caches and Restart"

### Words Not Loading
- Verify `words.json` exists in `app/src/main/assets/`
- Check JSON format is valid
- Look for errors in Logcat

### App Crashes on Launch
- Check minimum SDK version (24) is met
- View Logcat for stack traces
- Ensure all dependencies are downloaded

## Performance Notes

- The app loads all 8,109 words into memory at startup (~2-3 MB)
- Word selection uses an efficient tracking system to avoid repetition
- SharedPreferences updates happen asynchronously
- Animations use hardware acceleration

## Future Enhancements

Potential improvements:
- [ ] Dark mode support
- [ ] Difficulty levels (filter words by complexity)
- [ ] Timed challenges
- [ ] Multi-language support
- [ ] Sound effects
- [ ] Achievement system
- [ ] Share scores with friends
- [ ] Cloud sync for statistics

## License

Based on the original iOS Ultrathink app by Kai Kunze.

## Credits

- **Original iOS App**: Kai Kunze
- **Android Port**: Created as a learning exercise
- **Vocabulary Database**: 8,109 words with definitions

## Support

For issues or questions:
1. Check Logcat for error messages
2. Verify all setup steps were completed
3. Ensure Android SDK and tools are up to date

---

**Built with ❤️ using Kotlin and Material Design 3**
