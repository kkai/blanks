# Quick Start Guide - Ultrathink Vocabulary Android

This guide will get you up and running with the Ultrathink Vocabulary Android app in 5 minutes.

## Prerequisites

- Android Studio (Hedgehog 2023.1.1 or newer)
- Android SDK installed
- An Android device or emulator

## Step-by-Step Setup

### 1. Configure SDK Path

Create a file named `local.properties` in the `android` folder:

```properties
sdk.dir=/path/to/your/android/sdk
```

**Common SDK paths:**
- **macOS**: `/Users/[username]/Library/Android/sdk`
- **Linux**: `/home/[username]/Android/Sdk`
- **Windows**: `C:\\Users\\[username]\\AppData\\Local\\Android\\Sdk`

### 2. Open in Android Studio

1. Launch Android Studio
2. Click "Open an Existing Project"
3. Navigate to the `android` folder
4. Click "OK"
5. Wait for Gradle sync to complete (may take 2-5 minutes first time)

### 3. Run the App

**Option A: Using Android Studio**
1. Connect an Android device (with USB debugging enabled) or start an emulator
2. Click the green "Run" button (▶️) in the toolbar
3. Select your device from the list
4. Wait for the app to build and install

**Option B: Using Command Line**
```bash
cd android
./gradlew installDebug
```

### 4. Start Playing!

1. The app will open showing a definition
2. Choose your interaction mode (Settings icon ⚙️ → Tap Mode or Drag Mode)
3. Select the correct word that matches the definition
4. Watch your streak grow!

## Troubleshooting

### "SDK location not found"
- Make sure `local.properties` exists and has the correct path
- Verify the path actually points to your Android SDK directory

### "Gradle sync failed"
- Check your internet connection (Gradle downloads dependencies)
- Try: File → Invalidate Caches and Restart
- Ensure you have Android SDK Platform 34 installed

### "App won't install"
- Check device is connected: `adb devices`
- Ensure USB debugging is enabled on your device
- Try uninstalling any previous version first

### "Words don't load"
- The `words.json` file should be ~10MB
- Check Logcat for error messages
- Rebuild the project: Build → Rebuild Project

## Building for Production

To create a release APK:

```bash
cd android
./gradlew assembleRelease
```

The unsigned APK will be at:
`app/build/outputs/apk/release/app-release-unsigned.apk`

## Key Features to Try

1. **Tap Mode**: Simply tap the correct word button
2. **Drag Mode**: Long-press and drag words to the gap
3. **Score Tracking**: Your streak, word count, and accuracy are always displayed
4. **High Score**: Your best streak is automatically saved
5. **Reset Options**: Reset your session or all statistics from the settings menu

## Project Statistics

- **Total Words**: 8,109 vocabulary words
- **Kotlin Files**: 7
- **XML Files**: 10
- **Target Android Versions**: 7.0 (API 24) to 14 (API 34)

## Next Steps

- Customize colors in `res/values/colors.xml`
- Add more words to `assets/words.json`
- Adjust animation timing in `MainActivity.kt`
- Check out the full README.md for advanced topics

## Need Help?

1. Check the full [README.md](README.md) for detailed documentation
2. View Logcat in Android Studio for error messages
3. Verify all files are present (see file list below)

## Essential Files Checklist

- [ ] `local.properties` (you must create this)
- [x] `app/src/main/assets/words.json` (8,109 words)
- [x] `app/src/main/java/com/ultrathink/vocabulary/MainActivity.kt`
- [x] `app/src/main/res/layout/activity_main.xml`
- [x] `app/build.gradle.kts`
- [x] `settings.gradle.kts`

If all files are present and `local.properties` is configured, you're ready to go!

---

**Happy Learning! 📚**
