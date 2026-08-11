//
//  ChessGame+GameKit.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation

extension ChessGame {
    /// Track game completion and report to GameKit
    func reportGameCompletion(winner: PieceColor) {
        let playerWon = (ai.isEnabled && winner != aiColor) || !ai.isEnabled
        let moveCount = moveHistory.count
        let aiDifficulty = ai.isEnabled ? difficultyString : nil
        
        // Report to leaderboards
        LeaderboardManager.shared.trackGameCompleted(
            won: playerWon,
            moveCount: moveCount,
            againstAI: ai.isEnabled,
            aiDifficulty: aiDifficulty
        )
        
        // Report achievements
        if playerWon {
            AchievementsManager.shared.trackGameWin(difficulty: aiDifficulty)
            AchievementsManager.shared.trackSpeedWin(moveCount: moveCount)
            
            // Track defensive win (if no pieces were captured by opponent)
            let piecesLost = winner == .white ? capturedByBlack.count : capturedByWhite.count
            AchievementsManager.shared.trackDefensiveWin(piecesLost: piecesLost)
        }
        
        // Track checkmate achievement
        if case .checkmate = gameStatus {
            // You would need to track total checkmates in UserDefaults or similar
            let totalCheckmates = UserDefaults.standard.integer(forKey: "totalCheckmates") + 1
            UserDefaults.standard.set(totalCheckmates, forKey: "totalCheckmates")
            AchievementsManager.shared.trackCheckmate(totalCheckmates: totalCheckmates)
        }
    }
    
    /// Track special moves for achievements
    func reportSpecialMove(_ moveType: SpecialMoveType) {
        AchievementsManager.shared.trackSpecialMove(type: moveType)
    }
    
    private var difficultyString: String {
        switch ai.difficulty {
        case .easy: return "easy"
        case .medium: return "medium"
        case .hard: return "hard"
        case .expert: return "expert"
        }
    }
}
