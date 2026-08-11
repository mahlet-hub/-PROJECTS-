//
//  LeaderboardManager.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation
import GameKit

/// Manages leaderboards for chess statistics
class LeaderboardManager {
    static let shared = LeaderboardManager()
    
    // MARK: - Leaderboard Identifiers
    // Note: These need to be created in App Store Connect
    enum LeaderboardID: String {
        case totalWins = "com.learnchess.leaderboard.totalwins"
        case totalGames = "com.learnchess.leaderboard.totalgames"
        case winStreak = "com.learnchess.leaderboard.winstreak"
        case fastestWin = "com.learnchess.leaderboard.fastestwin" // Fewest moves to checkmate
        case aiWins = "com.learnchess.leaderboard.aiwins"
        case expertWins = "com.learnchess.leaderboard.expertwins"
    }
    
    private init() {}
    
    // MARK: - Submit Score
    func submitScore(_ value: Int, to leaderboard: LeaderboardID) {
        guard GameKitManager.shared.isAuthenticated else {
            print("Player not authenticated, cannot submit score")
            return
        }
        
        GKLeaderboard.submitScore(
            value,
            context: 0,
            player: GKLocalPlayer.local,
            leaderboardIDs: [leaderboard.rawValue]
        ) { error in
            if let error = error {
                print("Error submitting score to \(leaderboard.rawValue): \(error.localizedDescription)")
            } else {
                print("Successfully submitted score \(value) to \(leaderboard.rawValue)")
            }
        }
    }
    
    // MARK: - Load Scores
    func loadScores(
        for leaderboard: LeaderboardID,
        playerScope: GKLeaderboard.PlayerScope = .global,
        timeScope: GKLeaderboard.TimeScope = .allTime,
        range: NSRange = NSRange(location: 1, length: 10),
        completion: @escaping ([GKLeaderboard.Entry]?, Error?) -> Void
    ) {
        guard GameKitManager.shared.isAuthenticated else {
            completion(nil, NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]))
            return
        }
        
        GKLeaderboard.loadLeaderboards(IDs: [leaderboard.rawValue]) { leaderboards, error in
            if let error = error {
                completion(nil, error)
                return
            }
            
            guard let leaderboard = leaderboards?.first else {
                completion(nil, NSError(domain: "GameKit", code: -1, userInfo: [NSLocalizedDescriptionKey: "Leaderboard not found"]))
                return
            }
            
            leaderboard.loadEntries(for: playerScope, timeScope: timeScope, range: range) { localEntry, entries, totalPlayerCount, error in
                if let error = error {
                    completion(nil, error)
                } else {
                    completion(entries, nil)
                }
            }
        }
    }
    
    // MARK: - Game Statistics Tracking
    func trackGameCompleted(won: Bool, moveCount: Int, againstAI: Bool, aiDifficulty: String?) {
        // Update total games
        loadCurrentScore(for: .totalGames) { currentGames in
            self.submitScore(currentGames + 1, to: .totalGames)
        }
        
        // Update wins
        if won {
            loadCurrentScore(for: .totalWins) { currentWins in
                self.submitScore(currentWins + 1, to: .totalWins)
            }
            
            // Update fastest win (fewest moves)
            loadCurrentScore(for: .fastestWin) { currentFastest in
                if currentFastest == 0 || moveCount < currentFastest {
                    self.submitScore(moveCount, to: .fastestWin)
                }
            }
            
            // Update AI wins
            if againstAI {
                loadCurrentScore(for: .aiWins) { currentAIWins in
                    self.submitScore(currentAIWins + 1, to: .aiWins)
                }
                
                // Update expert wins
                if aiDifficulty?.lowercased() == "expert" {
                    loadCurrentScore(for: .expertWins) { currentExpertWins in
                        self.submitScore(currentExpertWins + 1, to: .expertWins)
                    }
                }
            }
        }
    }
    
    func updateWinStreak(_ streak: Int) {
        submitScore(streak, to: .winStreak)
    }
    
    // MARK: - Helper Methods
    private func loadCurrentScore(for leaderboard: LeaderboardID, completion: @escaping (Int) -> Void) {
        GKLeaderboard.loadLeaderboards(IDs: [leaderboard.rawValue]) { leaderboards, error in
            guard let leaderboard = leaderboards?.first else {
                completion(0)
                return
            }
            
            leaderboard.loadEntries(for: .global, timeScope: .allTime, range: NSRange(location: 1, length: 1)) { localEntry, _, _, error in
                if let score = localEntry?.score {
                    completion(score)
                } else {
                    completion(0)
                }
            }
        }
    }
}
