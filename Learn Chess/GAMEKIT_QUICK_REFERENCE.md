# GameKit Quick Reference Card

## 🚀 Quick Start (3 Steps)

1. **Xcode:** Add "Game Center" capability
2. **App Store Connect:** Create leaderboards and achievements
3. **Test:** Use sandbox account

---

## 📋 Essential IDs (Copy-Paste Ready)

### Leaderboard IDs
```
com.learnchess.leaderboard.totalwins
com.learnchess.leaderboard.totalgames
com.learnchess.leaderboard.winstreak
com.learnchess.leaderboard.fastestwin
com.learnchess.leaderboard.aiwins
com.learnchess.leaderboard.expertwins
```

### Achievement IDs
```
com.learnchess.achievement.firstwin
com.learnchess.achievement.win10
com.learnchess.achievement.win50
com.learnchess.achievement.win100
com.learnchess.achievement.defeateasy
com.learnchess.achievement.defeatmedium
com.learnchess.achievement.defeathard
com.learnchess.achievement.defeatexpert
com.learnchess.achievement.checkmate10
com.learnchess.achievement.checkmate50
com.learnchess.achievement.checkmate100
com.learnchess.achievement.castling
com.learnchess.achievement.enpassant
com.learnchess.achievement.promotion
com.learnchess.achievement.speedster
com.learnchess.achievement.tactician
com.learnchess.achievement.defender
```

---

## 💻 Common Code Snippets

### Report Game Completion
```swift
if case .checkmate(let winner) = gameStatus {
    reportGameCompletion(winner: winner)
}
```

### Report Special Move
```swift
reportSpecialMove(.castling)
reportSpecialMove(.enPassant)
reportSpecialMove(.promotion)
```

### Show Leaderboards
```swift
GameKitManager.shared.showLeaderboards()
```

### Show Achievements
```swift
GameKitManager.shared.showAchievements()
```

### Check Authentication
```swift
if GameKitManager.shared.isAuthenticated {
    // User is signed in
}
```

### Submit Score
```swift
LeaderboardManager.shared.submitScore(100, to: .totalWins)
```

### Report Achievement
```swift
AchievementsManager.shared.reportAchievement(.firstWin)
```

### Show Achievement Toast
```swift
.achievementToast(
    isShowing: $showAchievement,
    title: "Achievement Unlocked!",
    message: "You won your first game"
)
```

---

## 🎯 Achievement Point Values

| Achievement | Points |
|------------|--------|
| First Win | 10 |
| 10 Wins | 25 |
| 50 Wins | 50 |
| 100 Wins | 100 |
| Defeat Easy AI | 10 |
| Defeat Medium AI | 25 |
| Defeat Hard AI | 50 |
| Defeat Expert AI | 100 |
| 10 Checkmates | 15 |
| 50 Checkmates | 35 |
| 100 Checkmates | 75 |
| Castling | 10 |
| En Passant | 20 |
| Promotion | 15 |
| Speedster | 50 |
| Tactician | 30 |
| Defender | 75 |
| **TOTAL** | **710** |

---

## 🧪 Testing Quick Reference

### Sandbox Account Setup
1. App Store Connect → Users and Access → Sandbox Testers
2. Create tester with fake email
3. Sign out of Game Center on device
4. Run app, sign in with sandbox account

### Reset Testing Data
```swift
AchievementsManager.shared.resetAllAchievements { _ in
    print("Reset complete")
}
```

### Clear Local Stats
```swift
UserDefaults.standard.removeObject(forKey: "totalWins")
```

---

## 📱 UI States

### Profile Icon States
- `👤` (hollow) = Not signed in
- `👤●` (filled + green dot) = Signed in
- Shows in top-right of main screen

### Profile View Sections
1. Player card (name, alias, status)
2. Quick actions (leaderboards, achievements, dashboard)
3. Recent achievements (top 3)

---

## 🔧 Files Created

| File | Purpose |
|------|---------|
| `GameKitManager.swift` | Authentication & core |
| `AchievementsManager.swift` | Achievement tracking |
| `LeaderboardManager.swift` | Leaderboard management |
| `GameCenterProfileView.swift` | UI for profile |
| `AchievementToastView.swift` | Toast notifications |
| `ChessGame+GameKit.swift` | Game integration |
| `GAMEKIT_SETUP.md` | Setup guide |
| `GAMEKIT_CHECKLIST.md` | Step-by-step checklist |
| `GameKitIntegrationExample.swift` | Code examples |

---

## ⚠️ Important Notes

- **Bundle ID:** Must match App Store Connect exactly
- **IDs:** Must match exactly (case-sensitive)
- **Sorting:** "Fastest Win" uses LOW to HIGH (lower is better)
- **Testing:** Always test with sandbox account first
- **Privacy:** Users can decline - handle gracefully
- **Offline:** App works offline, syncs when online

---

## 🆘 Common Errors & Fixes

| Error | Solution |
|-------|----------|
| "Not authenticated" | Sign into Game Center in Settings |
| Achievement won't unlock | Check ID matches exactly |
| Leaderboard not updating | Check internet connection |
| Can't add capability | Enable Game Center in App Store Connect first |

---

## 📞 Need More Help?

- **Setup:** See `GAMEKIT_CHECKLIST.md`
- **Code Examples:** See `GameKitIntegrationExample.swift`
- **UI Guide:** See `GAMEKIT_UI_GUIDE.md`
- **Detailed Docs:** See `GAMEKIT_SETUP.md`

---

## 🎮 That's It!

Your chess app now has:
✅ Game Center authentication
✅ 6 leaderboards
✅ 17 achievements
✅ Beautiful UI integration
✅ Automatic tracking

Just configure App Store Connect and you're ready to go! 🚀
