# Flow Sudoku

A focus ritual app combining Sudoku puzzles with declutter writing to help users enter a flow state and start their day with clarity.

## Overview

Flow Sudoku is designed as a morning ritual for knowledge workers, creatives, and anyone who needs deep focus. Each session combines:

1. **Brain Warm-Up**: Solve Sudoku puzzles (Easy, Medium, Hard)
2. **Mind Declutter**: Write freely in an integrated text editor
3. **Flow State**: Begin your work with clarity and intention

## Project Structure

```
Flow Sudoko/
├── Flow Sudoko/
│   ├── Flow Sudoko/
│   │   ├── Assets.xcassets/         # App icons and images
│   │   ├── static/                  # Fonts (Anta-Regular.ttf)
│   │   │
│   │   ├── Flow_SudokoApp.swift     # App entry point
│   │   ├── ContentView.swift        # Root view coordinator
│   │   ├── MenuView.swift           # Main menu and navigation
│   │   │
│   │   ├── OnboardingView.swift     # Onboarding (deprecated - now using CinematicOnboardingView)
│   │   ├── CinematicOnboardingView.swift  # New cinematic onboarding
│   │   ├── BreathingView.swift      # Breathing exercise (deprecated)
│   │   ├── IntentionView.swift      # Intention setting (deprecated)
│   │   │
│   │   ├── SudokuGameView.swift     # Main game view (Sudoku + Declutter)
│   │   ├── SudokuModels.swift       # Sudoku data models and puzzle loader
│   │   ├── SudokuPuzzles.json       # Puzzle database
│   │   │
│   │   ├── SessionData.swift        # Session and user preference models
│   │   ├── SessionManager.swift     # Session persistence and management
│   │   ├── UsageTracker.swift       # Daily usage limits tracking
│   │   │
│   │   ├── AuthService.swift        # Authentication (local for MVP)
│   │   ├── CloudSyncService.swift   # Cloud sync (stub for MVP)
│   │   │
│   │   ├── PreviousSessionsView.swift  # Session history UI
│   │   ├── HowToPlayView.swift      # Tutorial and instructions
│   │   ├── SettingsView.swift       # Settings and preferences
│   │   └── UpgradePromptView.swift  # Daily limit reached UI
│   │
│   └── Flow Sudoko.xcodeproj/       # Xcode project files
│
├── PrivacyPolicy.md                 # Privacy policy for users/reviewers
├── AppStoreDescription.md           # App Store listing content
├── AppStoreSubmissionChecklist.md   # Submission guide
└── README.md                        # This file
```

## Key Features

### Implemented (v1.0.0)

- ✅ Classic Sudoku gameplay with notes, undo, erase
- ✅ Three difficulty levels (Easy, Medium, Hard)
- ✅ Integrated declutter writing space
- ✅ Session tracking and history
- ✅ Daily usage limits (1 session/day for free tier)
- ✅ Previous sessions view with filtering
- ✅ How to Play guide
- ✅ Settings with account management
- ✅ Upgrade prompts (App Store compliant)
- ✅ Local data persistence
- ✅ Clean, minimalist black/white design

### Future (v1.1.0+)

- ⏳ Cloud sync activation (when backend ready)
- ⏳ Widget support
- ⏳ Pomodoro timer (1/day free, unlimited Studio)
- ⏳ Daily goals (3/day free, unlimited Studio)
- ⏳ Theme selection (Studio only)
- ⏳ Session statistics and insights

## Tier Structure

### Free (App Store Version)

- 1 session per day
- All difficulty levels
- Session history
- Full Sudoku features
- Declutter writing
- Local storage

### Studio (Website Version)

- Unlimited sessions
- Unlimited goals & pomodoros
- Cloud sync
- Premium themes
- Full statistics
- **$2.99/month or $19/year** (processed externally)

## Technical Details

### Requirements

- **Platform**: macOS 12.0+
- **Language**: Swift 5.9+
- **Framework**: SwiftUI
- **Architecture**: MVVM with ObservableObject

### Dependencies

- No external dependencies (vanilla SwiftUI)
- Custom font: Anta-Regular.ttf

### Data Models

**SessionData**: Individual session records
- Timestamp, duration, difficulty
- Declutter text, mistake count
- Completion status, puzzle ID

**UserPreferences**: User settings
- Tier (free/studio)
- Font size, theme, notifications
- Daily goal limits

**DailyUsageStats**: Daily counters
- Sessions completed
- Goals set
- Pomodoros completed
- Resets at midnight

### Storage

**Local Storage**:
- UserDefaults for preferences and stats
- File system (JSON) for session history
- Fully functional offline

**Cloud Sync** (Future):
- REST API for session sync
- User authentication
- Conflict resolution

## Development

### Setup

1. Clone the repository
2. Open `Flow Sudoko.xcodeproj` in Xcode
3. Build and run (Cmd+R)

### Building for Release

1. Update version number in Xcode
2. Archive: Product → Archive
3. Validate: Organizer → Validate App
4. Distribute: Organizer → Distribute App

### Testing

**Manual Test Scenarios**:

1. **New User Flow**:
   - Launch app → onboarding → main menu
   - Select "Begin Flow" → complete session
   - View session in "Previous Sessions"

2. **Daily Limit**:
   - Complete one session
   - Try to start another → see upgrade prompt
   - Verify limit resets at midnight

3. **Session Tracking**:
   - Complete sessions at different difficulties
   - Verify all data saves correctly
   - Check filtering in Previous Sessions

4. **Settings**:
   - Change font size → verify persists
   - Sign in/out → verify state changes
   - Test upgrade link → opens browser

### Code Style

- SwiftUI views in separate files
- ObservableObject for state management
- Consistent naming (camelCase for vars, PascalCase for types)
- Minimal color palette (black/white only)
- Anta font for headers, system font for body

## App Store Compliance

### IAP Guidelines

✅ **Compliant**:
- No in-app purchases
- Free version is fully functional (1 session/day is the feature)
- External link clearly opens browser
- No "purchase" or "subscribe" buttons
- Studio is separate download from website

❌ **Avoid**:
- Don't add IAP for unlocking features
- Don't mention prices in-app
- Don't trick users about external links
- Don't make free version feel like a trial

### Privacy

- Privacy Policy: [flowsudoku.com/privacy](https://flowsudoku.com/privacy)
- Local-first: No data leaves device by default
- Optional account: Cloud sync requires sign-in
- No tracking: No analytics or advertising SDKs

## Support

- **Website**: https://flowsudoku.com
- **Support**: support@flowsudoku.com
- **Privacy**: privacy@flowsudoku.com

## License

Copyright © 2025 Flow Sudoku. All rights reserved.

## Version History

### 1.0.0 (Current)
- Initial release
- Core Sudoku gameplay
- Declutter writing
- Session tracking
- Daily limits
- Previous sessions view
- How to play guide
- Settings page

---

**Last Updated**: November 16, 2025
**Status**: Ready for App Store submission

