//
//  AchievementsManager.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation
import GameKit

/// Manages chess-related achievements in Game Center
class AchievementsManager {
    static let shared = AchievementsManager()
    
    // MARK: - Achievement Identifiers
    // Note: These need to be created in App Store Connect
    enum AchievementID: String {
        case firstWin = "com.learnchess.achievement.firstwin"
        case win10Games = "com.learnchess.achievement.win10"
        case win50Games = "com.learnchess.achievement.win50"
        case win100Games = "com.learnchess.achievement.win100"
        
        case defeatEasyAI = "com.learnchess.achievement.defeateasy"
        case defeatMediumAI = "com.learnchess.achievement.defeatmedium"
        case defeatHardAI = "com.learnchess.achievement.defeathard"
        case defeatExpertAI = "com.learnchess.achievement.defeatexpert"
        
        case checkmate10 = "com.learnchess.achievement.checkmate10"
        case checkmate50 = "com.learnchess.achievement.checkmate50"
        case checkmate100 = "com.learnchess.achievement.checkmate100"
        
        case castling = "com.learnchess.achievement.castling"
        case enPassant = "com.learnchess.achievement.enpassant"
        case promotion = "com.learnchess.achievement.promotion"
        
        case speedster = "com.learnchess.achievement.speedster" // Win in under 20 moves
        case tactician = "com.learnchess.achievement.tactician" // Capture 10 pieces in one game
        case defender = "com.learnchess.achievement.defender" // Win without losing any pieces
    }
    
    private init() {}
    
    // MARK: - Report Achievement
    func reportAchievement(_ achievementID: AchievementID, percentComplete: Double = 100.0) {
        guard GameKitManager.shared.isAuthenticated else {
            print("Player not authenticated, cannot report achievement")
            return
        }
        
        let achievement = GKAchievement(identifier: achievementID.rawValue)
        achievement.percentComplete = percentComplete
        achievement.showsCompletionBanner = true
        
        GKAchievement.report([achievement]) { error in
            if let error = error {
                print("Error reporting achievement: \(error.localizedDescription)")
            } else {
                print("Successfully reported achievement: \(achievementID.rawValue)")
            }
        }
    }
    
    // MARK: - Report Progress Achievement
    func reportProgressAchievement(_ achievementID: AchievementID, current: Int, total: Int) {
        let percentComplete = min(Double(current) / Double(total) * 100.0, 100.0)
        reportAchievement(achievementID, percentComplete: percentComplete)
    }
    
    // MARK: - Load Achievements
    func loadAchievements(completion: @escaping ([GKAchievement]?, Error?) -> Void) {
        guard GameKitManager.shared.isAuthenticated else {
            completion(nil, NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
            return
        }
        
        GKAchievement.loadAchievements { achievements, error in
            completion(achievements, error)
        }
    }
    
    // MARK: - Reset All Achievements (for testing)
    func resetAllAchievements(completion: @escaping (Error?) -> Void) {
        GKAchievement.resetAchievements { error in
            if let error = error {
                print("Error resetting achievements: \(error.localizedDescription)")
            } else {
                print("Successfully reset all achievements")
            }
            completion(error)
        }
    }
    
    // MARK: - Game Event Tracking
    func trackGameWin(difficulty: String? = nil) {
        reportAchievement(.firstWin)
        
        // Track AI difficulty wins
        if let difficulty = difficulty {
            switch difficulty.lowercased() {
            case "easy":
                reportAchievement(.defeatEasyAI)
            case "medium":
                reportAchievement(.defeatMediumAI)
            case "hard":
                reportAchievement(.defeatHardAI)
            case "expert":
                reportAchievement(.defeatExpertAI)
            default:
                break
            }
        }
    }
    
    func trackCheckmate(totalCheckmates: Int) {
        reportProgressAchievement(.checkmate10, current: totalCheckmates, total: 10)
        reportProgressAchievement(.checkmate50, current: totalCheckmates, total: 50)
        reportProgressAchievement(.checkmate100, current: totalCheckmates, total: 100)
    }
    
    func trackSpecialMove(type: SpecialMoveType) {
        switch type {
        case .castling:
            reportAchievement(.castling)
        case .enPassant:
            reportAchievement(.enPassant)
        case .promotion:
            reportAchievement(.promotion)
        }
    }
    
    func trackSpeedWin(moveCount: Int) {
        if moveCount <= 20 {
            reportAchievement(.speedster)
        }
    }
    
    func trackDefensiveWin(piecesLost: Int) {
        if piecesLost == 0 {
            reportAchievement(.defender)
        }
    }
}

// MARK: - Special Move Types
enum SpecialMoveType {
    case castling
    case enPassant
    case promotion
}
