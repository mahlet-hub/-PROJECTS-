# GameKit Integration Checklist

Use this checklist to ensure your GameKit integration is complete and working.

## ✅ Phase 1: Files and Code (COMPLETE)

- [x] GameKitManager.swift created
- [x] AchievementsManager.swift created
- [x] LeaderboardManager.swift created
- [x] GameCenterProfileView.swift created
- [x] AchievementToastView.swift created
- [x] ChessGame+GameKit.swift created
- [x] ContentView.swift updated with Game Center button
- [x] Documentation files created

## 📋 Phase 2: Xcode Configuration (YOUR NEXT STEPS)

### Step 1: Add Game Center Capability
- [ ] Open your project in Xcode
- [ ] Select your app target
- [ ] Click "Signing & Capabilities" tab
- [ ] Click "+ Capability" button
- [ ] Search for and add "Game Center"
- [ ] Verify it appears in the capabilities list

**How to verify:** You should see "Game Center" in your capabilities list with a checkmark.

---

### Step 2: Configure Bundle Identifier
- [ ] Ensure your bundle identifier matches App Store Connect
- [ ] Example: `com.yourname.learnchess`

**Location:** Project settings → General → Identity → Bundle Identifier

---

### Step 3: Configure Signing
- [ ] Select your development team
- [ ] Ensure "Automatically manage signing" is checked
- [ ] Verify provisioning profile includes Game Center

**How to verify:** Build the app - should build without signing errors.

---

## 🌐 Phase 3: App Store Connect (REQUIRED BEFORE TESTING)

### Step 1: Access Game Center Configuration
- [ ] Log in to [App Store Connect](https://appstoreconnect.apple.com)
- [ ] Select your app (or create it if new)
- [ ] Navigate to "Services" → "Game Center"

---

### Step 2: Create 6 Leaderboards

Copy these exact IDs to avoid errors:

#### Leaderboard 1: Total Wins
- [ ] Click "+" to add leaderboard
- [ ] **Leaderboard Reference Name:** Total Wins
- [ ] **Leaderboard ID:** `com.learnchess.leaderboard.totalwins`
- [ ] **Score Format Type:** Integer
- [ ] **Sort Order:** High to Low
- [ ] **Score Range:** 0 to 999999
- [ ] Add localization (English)
  - **Name:** Total Wins
  - **Score Format:** %d wins
  - **Score Format (Singular):** %d win

#### Leaderboard 2: Total Games
- [ ] **Leaderboard Reference Name:** Total Games
- [ ] **Leaderboard ID:** `com.learnchess.leaderboard.totalgames`
- [ ] **Score Format Type:** Integer
- [ ] **Sort Order:** High to Low
- [ ] **Name:** Total Games Played
- [ ] **Score Format:** %d games

#### Leaderboard 3: Win Streak
- [ ] **Leaderboard Reference Name:** Win Streak
- [ ] **Leaderboard ID:** `com.learnchess.leaderboard.winstreak`
- [ ] **Score Format Type:** Integer
- [ ] **Sort Order:** High to Low
- [ ] **Name:** Best Win Streak
- [ ] **Score Format:** %d wins

#### Leaderboard 4: Fastest Win
- [ ] **Leaderboard Reference Name:** Fastest Win
- [ ] **Leaderboard ID:** `com.learnchess.leaderboard.fastestwin`
- [ ] **Score Format Type:** Integer
- [ ] **Sort Order:** Low to High ⚠️ (Lower is better!)
- [ ] **Name:** Fastest Checkmate
- [ ] **Score Format:** %d moves

#### Leaderboard 5: AI Wins
- [ ] **Leaderboard Reference Name:** AI Wins
- [ ] **Leaderboard ID:** `com.learnchess.leaderboard.aiwins`
- [ ] **Score Format Type:** Integer
- [ ] **Sort Order:** High to Low
- [ ] **Name:** AI Victories
- [ ] **Score Format:** %d wins

#### Leaderboard 6: Expert AI Wins
- [ ] **Leaderboard Reference Name:** Expert AI Wins
- [ ] **Leaderboard ID:** `com.learnchess.leaderboard.expertwins`
- [ ] **Score Format Type:** Integer
- [ ] **Sort Order:** High to Low
- [ ] **Name:** Expert AI Defeated
- [ ] **Score Format:** %d wins

---

### Step 3: Create 17 Achievements

Copy these exact IDs:

#### Basic Win Achievements

**Achievement 1: First Win**
- [ ] **Achievement Reference Name:** First Win
- [ ] **Achievement ID:** `com.learnchess.achievement.firstwin`
- [ ] **Points:** 10
- [ ] **Hidden:** No
- [ ] **Achievable More Than Once:** No
- [ ] **Name:** First Victory
- [ ] **Pre-earned Description:** Win your first game
- [ ] **Earned Description:** You won your first game!

**Achievement 2: 10 Wins**
- [ ] **Achievement ID:** `com.learnchess.achievement.win10`
- [ ] **Points:** 25
- [ ] **Name:** Novice Champion
- [ ] **Description:** Win 10 games

**Achievement 3: 50 Wins**
- [ ] **Achievement ID:** `com.learnchess.achievement.win50`
- [ ] **Points:** 50
- [ ] **Name:** Experienced Player
- [ ] **Description:** Win 50 games

**Achievement 4: 100 Wins**
- [ ] **Achievement ID:** `com.learnchess.achievement.win100`
- [ ] **Points:** 100
- [ ] **Name:** Master of Chess
- [ ] **Description:** Win 100 games

#### AI Difficulty Achievements

**Achievement 5: Defeat Easy AI**
- [ ] **Achievement ID:** `com.learnchess.achievement.defeateasy`
- [ ] **Points:** 10
- [ ] **Name:** Beginner's Luck
- [ ] **Description:** Defeat the Easy AI

**Achievement 6: Defeat Medium AI**
- [ ] **Achievement ID:** `com.learnchess.achievement.defeatmedium`
- [ ] **Points:** 25
- [ ] **Name:** Rising Star
- [ ] **Description:** Defeat the Medium AI

**Achievement 7: Defeat Hard AI**
- [ ] **Achievement ID:** `com.learnchess.achievement.defeathard`
- [ ] **Points:** 50
- [ ] **Name:** Chess Warrior
- [ ] **Description:** Defeat the Hard AI

**Achievement 8: Defeat Expert AI**
- [ ] **Achievement ID:** `com.learnchess.achievement.defeatexpert`
- [ ] **Points:** 100
- [ ] **Name:** Grandmaster
- [ ] **Description:** Defeat the Expert AI

#### Checkmate Achievements

**Achievement 9: 10 Checkmates**
- [ ] **Achievement ID:** `com.learnchess.achievement.checkmate10`
- [ ] **Points:** 15
- [ ] **Name:** Checkmate Apprentice
- [ ] **Description:** Deliver 10 checkmates

**Achievement 10: 50 Checkmates**
- [ ] **Achievement ID:** `com.learnchess.achievement.checkmate50`
- [ ] **Points:** 35
- [ ] **Name:** Checkmate Expert
- [ ] **Description:** Deliver 50 checkmates

**Achievement 11: 100 Checkmates**
- [ ] **Achievement ID:** `com.learnchess.achievement.checkmate100`
- [ ] **Points:** 75
- [ ] **Name:** Checkmate Master
- [ ] **Description:** Deliver 100 checkmates

#### Special Move Achievements

**Achievement 12: First Castling**
- [ ] **Achievement ID:** `com.learnchess.achievement.castling`
- [ ] **Points:** 10
- [ ] **Name:** Castle Guard
- [ ] **Description:** Perform a castling move

**Achievement 13: First En Passant**
- [ ] **Achievement ID:** `com.learnchess.achievement.enpassant`
- [ ] **Points:** 20
- [ ] **Name:** En Passant Connoisseur
- [ ] **Description:** Capture using en passant

**Achievement 14: First Promotion**
- [ ] **Achievement ID:** `com.learnchess.achievement.promotion`
- [ ] **Points:** 15
- [ ] **Name:** Pawn Promotion
- [ ] **Description:** Promote a pawn to a queen

#### Strategy Achievements

**Achievement 15: Speedster**
- [ ] **Achievement ID:** `com.learnchess.achievement.speedster`
- [ ] **Points:** 50
- [ ] **Name:** Speed Chess
- [ ] **Description:** Win in under 20 moves

**Achievement 16: Tactician**
- [ ] **Achievement ID:** `com.learnchess.achievement.tactician`
- [ ] **Points:** 30
- [ ] **Name:** Master Tactician
- [ ] **Description:** Capture 10 pieces in one game

**Achievement 17: Defender**
- [ ] **Achievement ID:** `com.learnchess.achievement.defender`
- [ ] **Points:** 75
- [ ] **Name:** Perfect Defense
- [ ] **Description:** Win without losing any pieces

**Total Points Available:** 710 points

---

## 🧪 Phase 4: Testing Setup

### Step 1: Create Sandbox Tester Account
- [ ] In App Store Connect, go to "Users and Access"
- [ ] Click "Sandbox Testers"
- [ ] Click "+" to add tester
- [ ] Fill in details:
  - [ ] First name
  - [ ] Last name
  - [ ] Email (use a new email, not your real one)
  - [ ] Password
  - [ ] Country/Region
- [ ] Click "Add"

**Note:** Use a unique email like `chesstest1@example.com` - it doesn't need to be real.

---

### Step 2: Configure Test Device
- [ ] On your iPhone/iPad, go to Settings
- [ ] Scroll to "Game Center"
- [ ] **Sign out** of your personal account
- [ ] Delete your app if already installed
- [ ] Build and run from Xcode

---

### Step 3: First Test Run
- [ ] App launches
- [ ] Game Center login prompt appears
- [ ] Sign in with sandbox tester account
- [ ] Green dot appears on profile icon ✅

**Troubleshooting:** If login doesn't appear, check:
- Game Center is enabled in Settings
- You're signed out of personal account
- App has Game Center capability

---

## 🎮 Phase 5: Integration Testing

### Test 1: Authentication
- [ ] Open app
- [ ] See Game Center authentication prompt
- [ ] Sign in successfully
- [ ] Profile icon shows green dot
- [ ] Tap profile icon
- [ ] See player name and "Game Center" badge

### Test 2: Basic Gameplay Tracking
- [ ] Play a game
- [ ] Win the game
- [ ] Check if "First Win" achievement unlocks
- [ ] Tap profile → Achievements
- [ ] Verify achievement appears

### Test 3: Leaderboards
- [ ] Win a game
- [ ] Tap profile → Leaderboards
- [ ] Verify "Total Wins" shows 1
- [ ] Play another game
- [ ] Check if count increases

### Test 4: Special Moves
- [ ] Perform castling
- [ ] Check if "Castle Guard" achievement unlocks
- [ ] Try en passant (if possible)
- [ ] Try pawn promotion

### Test 5: AI Victories
- [ ] Enable AI (Easy difficulty)
- [ ] Win against AI
- [ ] Check if "Beginner's Luck" achievement unlocks
- [ ] Try different difficulty levels

---

## 🔧 Phase 6: Code Integration (Optional but Recommended)

### Add Game Tracking to ChessGame.swift

See `GameKitIntegrationExample.swift` for complete examples.

**Minimum Required:**
```swift
// When game ends with checkmate
if case .checkmate(let winner) = gameStatus {
    reportGameCompletion(winner: winner)
}
```

**Optional Enhancements:**
- [ ] Track special moves (castling, en passant, promotion)
- [ ] Track win streaks
- [ ] Show custom achievement toasts
- [ ] Track game statistics locally

---

## ✨ Phase 7: Polish and Launch Prep

### UI Enhancements
- [ ] Test achievement toast notifications
- [ ] Verify all UI states (signed in/out)
- [ ] Test on different device sizes
- [ ] Check dark mode appearance

### Achievement Icons
- [ ] Design custom icons for achievements (512x512px)
- [ ] Upload to App Store Connect
- [ ] Test how they look in Game Center

### Localization (if supporting multiple languages)
- [ ] Translate achievement names
- [ ] Translate leaderboard names
- [ ] Test in different languages

---

## 🚀 Phase 8: Production Release

### Pre-Release Checks
- [ ] All leaderboards configured ✅
- [ ] All achievements configured ✅
- [ ] Sandbox testing complete ✅
- [ ] No hardcoded test values
- [ ] Game Center capability enabled ✅
- [ ] App icons and screenshots prepared

### App Store Submission
- [ ] Submit app for review
- [ ] Include Game Center in app description
- [ ] Mention achievements and leaderboards
- [ ] Provide test account for reviewers

### Post-Launch
- [ ] Monitor achievement unlock rates
- [ ] Check leaderboard participation
- [ ] Gather user feedback
- [ ] Consider adding more achievements

---

## 📊 Monitoring and Maintenance

### Analytics to Track
- [ ] % of users who sign in to Game Center
- [ ] Most/least unlocked achievements
- [ ] Leaderboard participation rate
- [ ] Average game completion time

### Potential Updates
- [ ] Add seasonal achievements
- [ ] Create achievement groups
- [ ] Add challenge system
- [ ] Implement multiplayer

---

## ❓ Troubleshooting Common Issues

### "Player not authenticated" errors
✅ **Fix:** Ensure signed into Game Center in Settings

### Achievements not unlocking
✅ **Fix:** Check IDs match exactly in App Store Connect

### Leaderboards not updating
✅ **Fix:** Verify internet connection and authentication

### Can't sign in with sandbox account
✅ **Fix:** Sign out completely, delete app, reinstall

### Capabilities error
✅ **Fix:** Re-add Game Center capability and clean build

---

## 📚 Resources

- [GameKit Documentation](https://developer.apple.com/documentation/gamekit)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)
- [Game Center Design Guidelines](https://developer.apple.com/design/human-interface-guidelines/game-center)
- Your integration files:
  - `GAMEKIT_SETUP.md` - Detailed setup guide
  - `GAMEKIT_INTEGRATION_SUMMARY.md` - Feature overview
  - `GAMEKIT_UI_GUIDE.md` - Visual reference
  - `GameKitIntegrationExample.swift` - Code examples

---

## 🎯 Quick Start (Bare Minimum)

If you just want to get it working quickly:

1. ✅ Add Game Center capability in Xcode
2. ✅ Create ONE leaderboard in App Store Connect (Total Wins)
3. ✅ Create ONE achievement in App Store Connect (First Win)
4. ✅ Create sandbox tester account
5. ✅ Sign out of Game Center on device
6. ✅ Run app and sign in with sandbox account
7. ✅ Play and win one game
8. ✅ Check if achievement unlocks

Once this works, you can add the rest of the leaderboards and achievements!

---

**Need Help?** Check `GAMEKIT_SETUP.md` for detailed instructions and troubleshooting.

**Ready to Code?** See `GameKitIntegrationExample.swift` for integration patterns.

Good luck! 🚀
