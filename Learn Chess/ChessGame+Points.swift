//
//  ChessGame+Points.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation

extension ChessGame {
    /// Track game completion with points
    func trackGameCompletionWithPoints() {
        let pointsManager = PointsManager.shared
        
        // Determine game outcome
        var won = false
        var isDraw = false
        
        switch gameStatus {
        case .checkmate(let winner):
            // Award checkmate points
            pointsManager.trackSpecialMove("checkmate")
            
            // Determine if player won
            if ai.isEnabled {
                won = (winner != aiColor)
            } else {
                won = true // In PvP, consider both winners
            }
            
        case .stalemate:
            isDraw = true
            
        default:
            return
        }
        
        // Calculate additional stats
        let piecesLost = currentTurn == .white ? capturedByBlack.count : capturedByWhite.count
        let piecesLostByOpponent = currentTurn == .white ? capturedByWhite.count : capturedByBlack.count
        
        let difficulty = ai.isEnabled ? difficultyString : nil
        
        // Track the full game result
        pointsManager.trackGameResult(
            won: won,
            isDraw: isDraw,
            moveCount: moveHistory.count,
            aiDifficulty: difficulty,
            piecesLost: piecesLost,
            piecesLostByOpponent: piecesLostByOpponent
        )
        
        // Also report to GameKit if enabled
        if case .checkmate(let winner) = gameStatus {
            reportGameCompletion(winner: winner)
        }
    }
    
    /// Track a piece capture with points
    func trackCaptureWithPoints(piece: ChessPiece) {
        let pointsManager = PointsManager.shared
        pointsManager.trackCapture(pieceType: piece.type.rawValue)
    }
    
    /// Track special moves with points
    func trackSpecialMoveWithPoints(_ moveType: String) {
        let pointsManager = PointsManager.shared
        pointsManager.trackSpecialMove(moveType)
        
        // Also report to GameKit
        if let specialMoveType = convertToSpecialMoveType(moveType) {
            reportSpecialMove(specialMoveType)
        }
    }
    
    private var difficultyString: String {
        switch ai.difficulty {
        case .easy: return "easy"
        case .medium: return "medium"
        case .hard: return "hard"
        case .expert: return "expert"
        }
    }
    
    private func convertToSpecialMoveType(_ moveType: String) -> SpecialMoveType? {
        switch moveType.lowercased() {
        case "castling":
            return .castling
        case "enpassant", "en passant":
            return .enPassant
        case "promotion":
            return .promotion
        default:
            return nil
        }
    }
}
