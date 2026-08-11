# GameKit Integration Setup Guide

## Overview
This chess app now includes full GameKit integration with:
- Apple ID authentication via Game Center
- Leaderboards for tracking wins and statistics
- Achievements for game milestones
- Player profile display

## Setup Steps

### 1. Enable Game Center in Xcode

1. Select your project in the Project Navigator
2. Select your app target
3. Go to "Signing & Capabilities" tab
4. Click "+ Capability" button
5. Add "Game Center"

### 2. Configure App Store Connect

You need to configure leaderboards and achievements in App Store Connect.

#### Leaderboards to Create:

1. **Total Wins**
   - ID: `com.learnchess.leaderboard.totalwins`
   - Sort Order: High to Low
   - Format: Integer

2. **Total Games**
   - ID: `com.learnchess.leaderboard.totalgames`
   - Sort Order: High to Low
   - Format: Integer

3. **Win Streak**
   - ID: `com.learnchess.leaderboard.winstreak`
   - Sort Order: High to Low
   - Format: Integer

4. **Fastest Win**
   - ID: `com.learnchess.leaderboard.fastestwin`
   - Sort Order: Low to High (fewest moves)
   - Format: Integer

5. **AI Wins**
   - ID: `com.learnchess.leaderboard.aiwins`
   - Sort Order: High to Low
   - Format: Integer

6. **Expert AI Wins**
   - ID: `com.learnchess.leaderboard.expertwins`
   - Sort Order: High to Low
   - Format: Integer

#### Achievements to Create:

**Basic Achievements:**
1. First Win - `com.learnchess.achievement.firstwin`
2. 10 Wins - `com.learnchess.achievement.win10`
3. 50 Wins - `com.learnchess.achievement.win50`
4. 100 Wins - `com.learnchess.achievement.win100`

**AI Difficulty Achievements:**
5. Defeat Easy AI - `com.learnchess.achievement.defeateasy`
6. Defeat Medium AI - `com.learnchess.achievement.defeatmedium`
7. Defeat Hard AI - `com.learnchess.achievement.defeathard`
8. Defeat Expert AI - `com.learnchess.achievement.defeatexpert`

**Milestone Achievements:**
9. 10 Checkmates - `com.learnchess.achievement.checkmate10`
10. 50 Checkmates - `com.learnchess.achievement.checkmate50`
11. 100 Checkmates - `com.learnchess.achievement.checkmate100`

**Special Move Achievements:**
12. First Castling - `com.learnchess.achievement.castling`
13. First En Passant - `com.learnchess.achievement.enpassant`
14. First Promotion - `com.learnchess.achievement.promotion`

**Strategy Achievements:**
15. Speedster (Win in under 20 moves) - `com.learnchess.achievement.speedster`
16. Tactician (Capture 10+ pieces in one game) - `com.learnchess.achievement.tactician`
17. Defender (Win without losing pieces) - `com.learnchess.achievement.defender`

### 3. Testing Game Center

#### Sandbox Testing:
1. Create a sandbox tester account in App Store Connect
2. Sign out of Game Center on your device (Settings > Game Center)
3. Run the app - it will prompt for Game Center login
4. Sign in with your sandbox account

#### Testing Achievements & Leaderboards:
- In development, achievements and leaderboards may not work until configured in App Store Connect
- Use the sandbox environment for testing
- Reset test data: `AchievementsManager.shared.resetAllAchievements()`

### 4. Integration Points

The GameKit integration is already wired up in these files:

**Core Managers:**
- `GameKitManager.swift` - Handles authentication
- `AchievementsManager.swift` - Manages achievements
- `LeaderboardManager.swift` - Manages leaderboards

**UI Components:**
- `ContentView.swift` - Shows Game Center button in top bar
- `GameCenterProfileView.swift` - Displays player profile and stats

**Game Integration:**
- `ChessGame+GameKit.swift` - Extension for reporting game events

### 5. Tracking Game Events

To track achievements and leaderboard scores, add these calls in your ChessGame:

```swift
// When a game ends with checkmate
if case .checkmate(let winner) = gameStatus {
    reportGameCompletion(winner: winner)
}

// When special moves occur
// For castling:
reportSpecialMove(.castling)

// For en passant:
reportSpecialMove(.enPassant)

// For pawn promotion:
reportSpecialMove(.promotion)
```

### 6. Required Info.plist Entries

No special Info.plist entries are required for basic Game Center functionality, but you may want to add:

```xml
<key>GKGameCenterEnabled</key>
<true/>
```

### 7. Privacy Considerations

Game Center automatically handles privacy. The framework will:
- Show the authentication UI when needed
- Respect user privacy settings
- Handle authentication state changes

### 8. Features Included

✅ **Authentication**
- Automatic sign-in on app launch
- Visual indicator of authentication status
- Player profile display

✅ **Leaderboards**
- Track total wins, games, and streaks
- Track fastest wins (fewest moves)
- AI-specific leaderboards

✅ **Achievements**
- 17 different achievements
- Progress tracking
- Automatic unlock notifications

✅ **UI Integration**
- Game Center button in top bar (shows green dot when authenticated)
- Full profile view with quick actions
- Native Game Center dashboard access

## Usage

### For Users:
1. Launch the app
2. Sign in with Apple ID when prompted
3. Tap the profile icon in the top bar to view stats
4. Access leaderboards and achievements

### For Developers:
The integration is automatic. Just configure App Store Connect and the app handles the rest!

## Troubleshooting

**Issue:** "Player not authenticated" in logs
**Solution:** Make sure you're signed into Game Center on the device (Settings > Game Center)

**Issue:** Achievements/Leaderboards not appearing
**Solution:** Ensure they're properly configured in App Store Connect with matching IDs

**Issue:** Sandbox account issues
**Solution:** Sign out completely from Game Center, delete the app, and sign back in

## Next Steps

1. Configure leaderboards in App Store Connect
2. Configure achievements in App Store Connect  
3. Add achievement unlock calls in your game logic
4. Test with a sandbox account
5. Add custom icons for achievements
6. Consider adding social features (challenges, multiplayer)

## Additional Features to Consider

- **Multiplayer**: Use GameKit's turn-based or real-time multiplayer
- **Challenges**: Let players challenge friends
- **Access Point**: Show Game Center widget on screen
- **Rich Presence**: Show what players are doing in Game Center
