//
//  PointsManager.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation
import SwiftUI

/// Manages the points and rewards system for the chess app
@Observable
class PointsManager {
    static let shared = PointsManager()
    
    // MARK: - Properties
    var totalPoints: Int {
        get { UserDefaults.standard.integer(forKey: "totalPoints") }
        set { 
            UserDefaults.standard.set(newValue, forKey: "totalPoints")
            checkForLevelUp()
        }
    }
    
    var level: Int {
        get { UserDefaults.standard.integer(forKey: "playerLevel") }
        set { UserDefaults.standard.set(newValue, forKey: "playerLevel") }
    }
    
    var experience: Int {
        get { UserDefaults.standard.integer(forKey: "playerExperience") }
        set { 
            UserDefaults.standard.set(newValue, forKey: "playerExperience")
            checkForLevelUp()
        }
    }
    
    // MARK: - Point Values
    enum PointReward: Int {
        // Basic game completion
        case gameWin = 100
        case gameDraw = 25
        case gameLoss = 5
        
        // Piece captures (based on standard chess values in centipawns/10)
        case capturePawn = 10        // Standard value: 1 point (100 centipawns)
        case captureKnight = 30      // Standard value: 3 points (300 centipawns)
        case captureBishop = 32      // Standard value: 3 points (300 centipawns)
        case captureRook = 50        // Standard value: 5 points (500 centipawns)
        case captureQueen = 90       // Standard value: 9 points (900 centipawns)
        
        // Special moves
        case castling = 20
        case enPassant = 35
        case pawnPromotion = 40
        case check = 17
        case checkmate = 101
        
        // AI difficulty bonuses
        case defeatEasyAI = 60
        case defeatMediumAI = 110
        case defeatHardAI = 210
        case defeatExpertAI = 400
        
        // Speed bonuses
        case speedWin_10Moves = 160  // Win in under 10 moves
        case speedWin_15Moves = 120  // Win in under 15 moves
        case speedWin_20Moves = 70   // Win in under 20 moves
        
        // Strategy bonuses
        case perfectGame = 220       // Win without losing pieces
        case comebackVictory = 170   // Win after being down material
        case dominatingVictory = 130 // Win with 5+ piece advantage
        
        // Streak bonuses
        case winStreak_3 = 75
        case winStreak_5 = 180
        case winStreak_10 = 300
        
        // Daily bonuses
        case dailyFirstGame = 28
        case playedToday = 12
    }
    
    private init() {
        // Initialize level if first time
        if level == 0 {
            level = 1
        }
    }
    
    // MARK: - Award Points
    func awardPoints(_ reward: PointReward, multiplier: Double = 1.0) {
        let points = Int(Double(reward.rawValue) * multiplier)
        totalPoints += points
        experience += points
        
        print("🎯 Awarded \(points) points for \(reward)")
        
        // Post notification for UI updates
        NotificationCenter.default.post(
            name: Notification.Name("PointsAwarded"),
            object: nil,
            userInfo: ["points": points, "reward": reward]
        )
    }
    
    // MARK: - Track Game Results
    func trackGameResult(
        won: Bool,
        isDraw: Bool = false,
        moveCount: Int,
        aiDifficulty: String?,
        piecesLost: Int,
        piecesLostByOpponent: Int,
        specialMoves: [String] = []
    ) {
        // Base game result
        if won {
            awardPoints(.gameWin)
            
            // AI difficulty bonus
            if let difficulty = aiDifficulty {
                switch difficulty.lowercased() {
                case "easy":
                    awardPoints(.defeatEasyAI)
                case "medium":
                    awardPoints(.defeatMediumAI)
                case "hard":
                    awardPoints(.defeatHardAI)
                case "expert":
                    awardPoints(.defeatExpertAI)
                default:
                    break
                }
            }
            
            // Speed bonuses
            if moveCount <= 10 {
                awardPoints(.speedWin_10Moves)
            } else if moveCount <= 15 {
                awardPoints(.speedWin_15Moves)
            } else if moveCount <= 20 {
                awardPoints(.speedWin_20Moves)
            }
            
            // Strategy bonuses
            if piecesLost == 0 {
                awardPoints(.perfectGame)
            }
            
            let materialAdvantage = piecesLostByOpponent - piecesLost
            if materialAdvantage >= 5 {
                awardPoints(.dominatingVictory)
            }
            
            // Win streak bonus
            updateWinStreak(won: true)
            
        } else if isDraw {
            awardPoints(.gameDraw)
            updateWinStreak(won: false)
        } else {
            awardPoints(.gameLoss)
            updateWinStreak(won: false)
        }
        
        // Daily bonus
        checkDailyBonus()
    }
    
    // MARK: - Track Captures
    func trackCapture(pieceType: String) {
        switch pieceType.lowercased() {
        case "pawn":
            awardPoints(.capturePawn)
        case "knight":
            awardPoints(.captureKnight)
        case "bishop":
            awardPoints(.captureBishop)
        case "rook":
            awardPoints(.captureRook)
        case "queen":
            awardPoints(.captureQueen)
        default:
            break
        }
    }
    
    // MARK: - Track Special Moves
    func trackSpecialMove(_ moveType: String) {
        switch moveType.lowercased() {
        case "castling":
            awardPoints(.castling)
        case "enpassant", "en passant":
            awardPoints(.enPassant)
        case "promotion":
            awardPoints(.pawnPromotion)
        case "check":
            awardPoints(.check)
        case "checkmate":
            awardPoints(.checkmate)
        default:
            break
        }
    }
    
    // MARK: - Win Streak
    private func updateWinStreak(won: Bool) {
        var currentStreak = UserDefaults.standard.integer(forKey: "currentWinStreak")
        
        if won {
            currentStreak += 1
            UserDefaults.standard.set(currentStreak, forKey: "currentWinStreak")
            
            // Award streak bonuses
            switch currentStreak {
            case 3:
                awardPoints(.winStreak_3)
            case 5:
                awardPoints(.winStreak_5)
            case 10:
                awardPoints(.winStreak_10)
            default:
                break
            }
            
            // Update best streak
            let bestStreak = UserDefaults.standard.integer(forKey: "bestWinStreak")
            if currentStreak > bestStreak {
                UserDefaults.standard.set(currentStreak, forKey: "bestWinStreak")
            }
        } else {
            UserDefaults.standard.set(0, forKey: "currentWinStreak")
        }
    }
    
    // MARK: - Daily Bonus
    private func checkDailyBonus() {
        let today = Calendar.current.startOfDay(for: Date())
        
        if let lastPlayed = UserDefaults.standard.object(forKey: "lastPlayedDate") as? Date {
            let lastPlayedDay = Calendar.current.startOfDay(for: lastPlayed)
            
            if lastPlayedDay < today {
                // First game of the day
                awardPoints(.dailyFirstGame)
                UserDefaults.standard.set(Date(), forKey: "lastPlayedDate")
            }
        } else {
            // First time playing
            awardPoints(.dailyFirstGame)
            UserDefaults.standard.set(Date(), forKey: "lastPlayedDate")
        }
        
        awardPoints(.playedToday)
    }
    
    // MARK: - Leveling System
    private func checkForLevelUp() {
        let requiredXP = experienceForNextLevel()
        
        if experience >= requiredXP {
            level += 1
            experience -= requiredXP
            
            print("🎊 LEVEL UP! Now level \(level)")
            
            // Award bonus points for leveling up
            let levelBonus = level * 50
            totalPoints += levelBonus
            
            NotificationCenter.default.post(
                name: Notification.Name("LevelUp"),
                object: nil,
                userInfo: ["level": level, "bonus": levelBonus]
            )
        }
    }
    
    func experienceForNextLevel() -> Int {
        // Exponential scaling: Level 2 needs 100, Level 3 needs 150, etc.
        return 100 * level + (level - 1) * 50
    }
    
    var progressToNextLevel: Double {
        let required = Double(experienceForNextLevel())
        return required > 0 ? Double(experience) / required : 0
    }
    
    // MARK: - Player Title
    var playerTitle: String {
        switch level {
        case 1...5: return "Beginner"
        case 6...10: return "Novice"
        case 11...15: return "Intermediate"
        case 16...20: return "Advanced"
        case 21...30: return "Expert"
        case 31...40: return "Master"
        case 41...50: return "Grandmaster"
        default: return "Chess Legend"
        }
    }
    
    // MARK: - Statistics
    var gamesPlayed: Int {
        UserDefaults.standard.integer(forKey: "totalGames")
    }
    
    var gamesWon: Int {
        UserDefaults.standard.integer(forKey: "totalWins")
    }
    
    var currentWinStreak: Int {
        UserDefaults.standard.integer(forKey: "currentWinStreak")
    }
    
    var bestWinStreak: Int {
        UserDefaults.standard.integer(forKey: "bestWinStreak")
    }
    
    var winRate: Double {
        guard gamesPlayed > 0 else { return 0 }
        return Double(gamesWon) / Double(gamesPlayed) * 100
    }
    
    // MARK: - Reset (for testing)
    func resetAllPoints() {
        totalPoints = 0
        level = 1
        experience = 0
        UserDefaults.standard.set(0, forKey: "currentWinStreak")
        UserDefaults.standard.set(0, forKey: "bestWinStreak")
    }
}
