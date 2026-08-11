//
//  GameKitIntegrationExample.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//
//  This file shows examples of how to integrate GameKit tracking
//  into your ChessGame logic. Copy these patterns into your actual
//  ChessGame.swift file where appropriate.
//

import Foundation

// MARK: - Example Integration Points

/*
 
 // ========================================
 // EXAMPLE 1: Track Game Completion
 // ========================================
 
 // Add this in your ChessGame when the game ends
 func handleGameEnd() {
     switch gameStatus {
     case .checkmate(let winner):
         // Report the game completion to GameKit
         reportGameCompletion(winner: winner)
         
         // Optional: Show a custom achievement notification
         // (You would add @State var in your view)
         if winner == .white && aiColor == .black {
             // Player won against AI
             showAchievementNotification(
                 title: "Victory!",
                 message: "You defeated the \(difficultyName) AI"
             )
         }
         
     case .stalemate:
         // Track draws/stalemates
         let draws = UserDefaults.standard.integer(forKey: "totalDraws") + 1
         UserDefaults.standard.set(draws, forKey: "totalDraws")
         
     default:
         break
     }
 }
 
 // ========================================
 // EXAMPLE 2: Track Special Moves
 // ========================================
 
 // When performing castling
 func performCastling(king: Position, rook: Position) {
     // ... your existing castling logic ...
     
     // Track for GameKit achievement
     reportSpecialMove(.castling)
     
     // Optional: Track locally for statistics
     let castlingCount = UserDefaults.standard.integer(forKey: "castlingCount") + 1
     UserDefaults.standard.set(castlingCount, forKey: "castlingCount")
 }
 
 // When performing en passant
 func performEnPassant(from: Position, to: Position) {
     // ... your existing en passant logic ...
     
     // Track for GameKit achievement
     reportSpecialMove(.enPassant)
 }
 
 // When promoting a pawn
 func promotePawn(at position: Position, to pieceType: PieceType) {
     // ... your existing promotion logic ...
     
     // Track for GameKit achievement
     reportSpecialMove(.promotion)
 }
 
 // ========================================
 // EXAMPLE 3: Track Win Streaks
 // ========================================
 
 func updateWinStreak(didWin: Bool) {
     let currentStreak = UserDefaults.standard.integer(forKey: "currentWinStreak")
     
     if didWin {
         let newStreak = currentStreak + 1
         UserDefaults.standard.set(newStreak, forKey: "currentWinStreak")
         
         // Update leaderboard
         LeaderboardManager.shared.updateWinStreak(newStreak)
         
         // Check for streak achievements (you could add these)
         if newStreak == 3 {
             // 3 game win streak achievement
         } else if newStreak == 5 {
             // 5 game win streak achievement
         }
     } else {
         // Reset streak on loss
         UserDefaults.standard.set(0, forKey: "currentWinStreak")
     }
 }
 
 // ========================================
 // EXAMPLE 4: Track Total Games Statistics
 // ========================================
 
 func trackGameStatistics() {
     // Increment total games
     let totalGames = UserDefaults.standard.integer(forKey: "totalGames") + 1
     UserDefaults.standard.set(totalGames, forKey: "totalGames")
     
     // Track by game type
     if ai.isEnabled {
         let aiGames = UserDefaults.standard.integer(forKey: "totalAIGames") + 1
         UserDefaults.standard.set(aiGames, forKey: "totalAIGames")
     } else {
         let pvpGames = UserDefaults.standard.integer(forKey: "totalPvPGames") + 1
         UserDefaults.standard.set(pvpGames, forKey: "totalPvPGames")
     }
 }
 
 // ========================================
 // EXAMPLE 5: Tactician Achievement
 // (Capture 10+ pieces in one game)
 // ========================================
 
 func checkTacticianAchievement() {
     let totalCaptured = capturedByWhite.count + capturedByBlack.count
     if totalCaptured >= 10 {
         AchievementsManager.shared.reportAchievement(.tactician)
     }
 }
 
 // Call this after each capture
 func capturePiece(piece: ChessPiece, by color: PieceColor) {
     // ... your existing capture logic ...
     
     // Check for tactician achievement
     checkTacticianAchievement()
 }
 
 // ========================================
 // EXAMPLE 6: Complete Integration Example
 // ========================================
 
 // This is a complete example of a game end handler
 func completeGameEndHandler() {
     guard case .checkmate(let winner) = gameStatus else { return }
     
     // 1. Determine if player won
     let playerWon = if ai.isEnabled {
         winner != aiColor
     } else {
         true // Both players are "winners" in PvP
     }
     
     // 2. Track statistics locally
     trackGameStatistics()
     
     // 3. Update win streak
     updateWinStreak(didWin: playerWon)
     
     // 4. Report to GameKit
     reportGameCompletion(winner: winner)
     
     // 5. Check for special achievements
     checkTacticianAchievement()
     
     // 6. Track total wins
     if playerWon {
         let totalWins = UserDefaults.standard.integer(forKey: "totalWins") + 1
         UserDefaults.standard.set(totalWins, forKey: "totalWins")
         
         // Update win milestone achievements
         switch totalWins {
         case 10:
             AchievementsManager.shared.reportAchievement(.win10Games)
         case 50:
             AchievementsManager.shared.reportAchievement(.win50Games)
         case 100:
             AchievementsManager.shared.reportAchievement(.win100Games)
         default:
             break
         }
     }
     
     // 7. Save to persistent storage (if using SwiftData)
     // saveGameToHistory()
 }
 
 // ========================================
 // EXAMPLE 7: Authentication State Handling
 // ========================================
 
 // In your ContentView or wherever you manage game state
 func handleAuthenticationChange() {
     if GameKitManager.shared.isAuthenticated {
         // Player just signed in - sync local stats
         syncLocalStatsToGameCenter()
     }
 }
 
 func syncLocalStatsToGameCenter() {
     // Get local stats
     let totalWins = UserDefaults.standard.integer(forKey: "totalWins")
     let totalGames = UserDefaults.standard.integer(forKey: "totalGames")
     let winStreak = UserDefaults.standard.integer(forKey: "currentWinStreak")
     
     // Submit to leaderboards
     LeaderboardManager.shared.submitScore(totalWins, to: .totalWins)
     LeaderboardManager.shared.submitScore(totalGames, to: .totalGames)
     LeaderboardManager.shared.submitScore(winStreak, to: .winStreak)
 }
 
 // ========================================
 // EXAMPLE 8: Custom Achievement Notifications
 // ========================================
 
 // In your ContentView
 struct ContentView: View {
     @State private var showAchievement = false
     @State private var achievementTitle = ""
     @State private var achievementMessage = ""
     
     var body: some View {
         // ... your existing view ...
         
         // Add this modifier
         .achievementToast(
             isShowing: $showAchievement,
             title: achievementTitle,
             message: achievementMessage
         )
     }
     
     func showAchievementNotification(title: String, message: String) {
         achievementTitle = title
         achievementMessage = message
         showAchievement = true
     }
 }
 
 // ========================================
 // EXAMPLE 9: Reset Game Statistics
 // ========================================
 
 func resetAllStatistics() {
     // Clear UserDefaults
     let defaults = UserDefaults.standard
     defaults.removeObject(forKey: "totalGames")
     defaults.removeObject(forKey: "totalWins")
     defaults.removeObject(forKey: "currentWinStreak")
     defaults.removeObject(forKey: "totalCheckmates")
     defaults.removeObject(forKey: "castlingCount")
     
     // Reset GameKit achievements (for testing)
     AchievementsManager.shared.resetAllAchievements { error in
         if let error = error {
             print("Error resetting achievements: \(error)")
         } else {
             print("All achievements reset")
         }
     }
 }
 
 // ========================================
 // EXAMPLE 10: View Leaderboards from Game
 // ========================================
 
 // Add a button in your UI
 Button("View Leaderboards") {
     if GameKitManager.shared.isAuthenticated {
         GameKitManager.shared.showLeaderboards()
     } else {
         // Prompt user to sign in
         GameKitManager.shared.authenticatePlayer()
     }
 }
 
*/

// MARK: - UserDefaults Keys Helper

enum GameStatsKey: String {
    case totalGames = "totalGames"
    case totalWins = "totalWins"
    case totalLosses = "totalLosses"
    case totalDraws = "totalDraws"
    case currentWinStreak = "currentWinStreak"
    case bestWinStreak = "bestWinStreak"
    case totalCheckmates = "totalCheckmates"
    case totalAIGames = "totalAIGames"
    case totalPvPGames = "totalPvPGames"
    case castlingCount = "castlingCount"
    case enPassantCount = "enPassantCount"
    case promotionCount = "promotionCount"
    case shortestWin = "shortestWin" // Fewest moves to win
}

extension UserDefaults {
    func incrementStat(_ key: GameStatsKey) {
        let current = integer(forKey: key.rawValue)
        set(current + 1, forKey: key.rawValue)
    }
    
    func getStat(_ key: GameStatsKey) -> Int {
        return integer(forKey: key.rawValue)
    }
    
    func setStat(_ key: GameStatsKey, value: Int) {
        set(value, forKey: key.rawValue)
    }
}
