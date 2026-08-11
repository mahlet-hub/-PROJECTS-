# Points System Guide

## 🎯 Overview

Your chess app now has a complete **points and leveling system** that rewards players for their achievements!

## ✨ Features

### 1. Points System
- Earn points for wins, captures, special moves, and more
- Multiple ways to earn points (see table below)
- Points accumulate over time

### 2. Leveling System
- Start at Level 1
- Earn experience (XP) to level up
- Each level requires more XP
- Level up bonuses: Level × 50 points

### 3. Player Titles
Based on your level:
- **Level 1-5:** Beginner
- **Level 6-10:** Novice
- **Level 11-15:** Intermediate
- **Level 16-20:** Advanced
- **Level 21-30:** Expert
- **Level 31-40:** Master
- **Level 41-50:** Grandmaster
- **Level 51+:** Chess Legend

### 4. Statistics Tracking
- Total points
- Games played
- Games won
- Win rate percentage
- Current win streak
- Best win streak

## 💰 How to Earn Points

### Game Results
| Action | Points |
|--------|--------|
| Win a game | 100 |
| Draw | 25 |
| Loss (participation) | 10 |

### AI Difficulty Bonuses
| Difficulty | Bonus Points |
|------------|--------------|
| Easy AI | +50 |
| Medium AI | +100 |
| Hard AI | +200 |
| Expert AI | +400 |

### Piece Captures
| Piece | Points |
|-------|--------|
| Pawn | 5 |
| Knight | 15 |
| Bishop | 15 |
| Rook | 25 |
| Queen | 50 |

### Special Moves
| Move | Points |
|------|--------|
| Castling | 20 |
| En Passant | 30 |
| Pawn Promotion | 40 |
| Check | 15 |
| Checkmate | 100 |

### Speed Bonuses
| Achievement | Points |
|-------------|--------|
| Win in under 10 moves | 150 |
| Win in under 15 moves | 100 |
| Win in under 20 moves | 50 |

### Strategy Bonuses
| Achievement | Points |
|-------------|--------|
| Perfect Game (no pieces lost) | 200 |
| Dominating Victory (5+ piece advantage) | 100 |
| Comeback Victory | 150 |

### Win Streaks
| Streak | Bonus Points |
|--------|--------------|
| 3 wins | 75 |
| 5 wins | 150 |
| 10 wins | 300 |

### Daily Bonuses
| Action | Points |
|--------|--------|
| First game of the day | 25 |
| Playing today | 10 |

## 📱 UI Features

### Points Display (Top Bar)
- Compact display showing level and points
- Progress bar to next level
- Tap to see full details

### Points Detail View
- Large level badge
- Player title
- Total points
- Progress to next level
- Statistics grid
- Point earning guide

### Notifications
- **Points Award:** Appears when you earn points
- **Level Up:** Animated celebration when you level up
- Auto-dismisses after a few seconds

## 🔧 Integration with Your Game

### When a game ends:
```swift
// In your ChessGame, call this when the game finishes
game.trackGameCompletionWithPoints()
```

### When capturing a piece:
```swift
// Call this when a piece is captured
game.trackCaptureWithPoints(piece: capturedPiece)
```

### When performing special moves:
```swift
// Call these when special moves happen
game.trackSpecialMoveWithPoints("castling")
game.trackSpecialMoveWithPoints("enpassant")
game.trackSpecialMoveWithPoints("promotion")
game.trackSpecialMoveWithPoints("check")
```

## 📊 Example Point Earnings

### Scenario 1: Quick Victory vs Expert AI
- Win game: **100 pts**
- Defeat Expert AI: **+400 pts**
- Win in 12 moves: **+100 pts**
- Checkmate: **+100 pts**
- 3 captures (Queen, Rook, Bishop): **+90 pts**
- Castling: **+20 pts**
- **TOTAL: 810 points!** 🎉

### Scenario 2: Perfect Game
- Win game: **100 pts**
- Perfect game (no losses): **+200 pts**
- Checkmate: **+100 pts**
- 5 captures: **~75 pts**
- **TOTAL: 475 points!**

### Scenario 3: Win Streak Bonus
- Win game: **100 pts**
- 10 win streak: **+300 pts**
- Other bonuses: **~200 pts**
- **TOTAL: 600+ points!**

## 🎮 Tips to Maximize Points

1. **Play Against AI**: Higher difficulty = more points
2. **Win Quickly**: Speed bonuses are lucrative
3. **Don't Lose Pieces**: Perfect game bonus is huge
4. **Build Win Streaks**: Consistency pays off
5. **Use Special Moves**: Extra points add up
6. **Play Daily**: Daily bonuses accumulate
7. **Capture High-Value Pieces**: Queens and Rooks worth more

## 📈 Leveling Progression

| Level | XP Required | Cumulative XP |
|-------|-------------|---------------|
| 1→2 | 100 | 100 |
| 2→3 | 150 | 250 |
| 3→4 | 200 | 450 |
| 4→5 | 250 | 700 |
| 5→6 | 300 | 1,000 |
| 10→11 | 550 | ~3,500 |
| 20→21 | 1,050 | ~14,000 |

Formula: `XP needed = 100 × level + (level - 1) × 50`

## 🎊 Level Up Bonuses

When you level up:
- 🎉 Animated celebration
- 💰 Bonus points = Level × 50
- 🏆 New title (at certain milestones)
- 📊 Stats saved

Example:
- Level 10 → **500 bonus points**
- Level 20 → **1,000 bonus points**
- Level 50 → **2,500 bonus points**

## 🔄 Synergy with GameKit

The points system works **alongside** GameKit:
- Points = Local progression
- GameKit = Global competition
- Both track your achievements
- Both reward your success

**Best of both worlds!**

## 🛠️ For Developers

### Files Added
- `PointsManager.swift` - Core points logic
- `PointsDisplayView.swift` - UI components
- `ChessGame+Points.swift` - Game integration

### Key Classes
- `PointsManager.shared` - Singleton for points
- `PointsDisplayView` - Compact display
- `PointsDetailView` - Full stats view
- `LevelUpView` - Level up animation

### Notifications
- `"PointsAwarded"` - When points are earned
- `"LevelUp"` - When player levels up

### UserDefaults Keys
All data stored locally:
- `totalPoints`
- `playerLevel`
- `playerExperience`
- `currentWinStreak`
- `bestWinStreak`
- `lastPlayedDate`

## 🎯 Future Enhancements

Potential additions:
- [ ] Daily challenges (bonus points)
- [ ] Weekly tournaments
- [ ] Point multiplier events
- [ ] Achievement badges
- [ ] Leaderboards for points
- [ ] Unlockable content
- [ ] Premium titles
- [ ] Point shop (spend points on themes, etc.)

## 🚀 Getting Started

Everything is already integrated! Just:

1. **Play games** - Points are awarded automatically
2. **Check your progress** - Tap the level badge in top bar
3. **Watch for notifications** - See points and level-ups
4. **Track statistics** - View in the points detail screen

The system works immediately with zero configuration needed! 🎉

## 💡 Pro Tips

### Maximizing XP Gain
- Play multiple games daily
- Maintain win streaks
- Challenge yourself with harder AI
- Try for perfect games

### Fastest Way to Level Up
1. Play Expert AI (most points)
2. Win quickly (speed bonus)
3. Don't lose pieces (perfect game)
4. Maintain streaks (streak bonus)
5. Play daily (daily bonus)

### Statistics Tracking
Your stats are tracked automatically:
- Every game updates your record
- Win rate calculated in real-time
- Streaks tracked automatically
- Points awarded instantly

Enjoy your new points and leveling system! 🎮✨
