//
//  GameKitManager.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation
import GameKit
import SwiftUI

/// Manages GameKit authentication and core Game Center functionality
@Observable
class GameKitManager {
    static let shared = GameKitManager()
    
    // MARK: - Published Properties
    var isAuthenticated = false
    var localPlayer: GKLocalPlayer?
    var authenticationError: Error?
    var authenticationViewController: UIViewController?
    
    // MARK: - Game Center Sheet State
    var gameCenterSheetState: GKGameCenterViewControllerState?
    
    // MARK: - Initialization
    private init() {
        authenticatePlayer()
    }
    
    // MARK: - Authentication
    func authenticatePlayer() {
        localPlayer = GKLocalPlayer.local
        
        localPlayer?.authenticateHandler = { [weak self] viewController, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if let error = error {
                    self.authenticationError = error
                    self.isAuthenticated = false
                    print("❌ GameKit authentication error: \(error.localizedDescription)")
                    return
                }
                
                if let viewController = viewController {
                    // Store the view controller to present later
                    self.authenticationViewController = viewController
                    print("🔐 Authentication required - present the view controller")
                    
                    // Try to present immediately
                    self.presentAuthenticationViewController()
                } else if self.localPlayer?.isAuthenticated == true {
                    self.isAuthenticated = true
                    self.authenticationViewController = nil
                    print("✅ Authenticated as: \(self.localPlayer?.displayName ?? "Unknown")")
                    self.loadGameCenterData()
                } else {
                    self.isAuthenticated = false
                    print("⚠️ Not authenticated and no view controller provided")
                }
            }
        }
    }
    
    // MARK: - Present Authentication
    func presentAuthenticationViewController() {
        guard let viewController = authenticationViewController else {
            print("⚠️ No authentication view controller to present")
            return
        }
        
        // Find the top-most view controller
        DispatchQueue.main.async {
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = scene.windows.first,
               let rootViewController = window.rootViewController {
                
                var topController = rootViewController
                while let presented = topController.presentedViewController {
                    topController = presented
                }
                
                topController.present(viewController, animated: true) {
                    print("🎮 Presented Game Center authentication")
                }
            } else {
                print("❌ Could not find root view controller")
            }
        }
    }
    
    // MARK: - Load Game Center Data
    private func loadGameCenterData() {
        guard isAuthenticated else { return }
        
        // Load player info
        if let player = localPlayer {
            print("Authenticated as: \(player.displayName)")
            print("Player ID: \(player.gamePlayerID)")
            
            // Load player photo
            player.loadPhoto(for: .normal) { image, error in
                if let error = error {
                    print("Error loading player photo: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Show Game Center Dashboard
    func showGameCenterDashboard(state: GKGameCenterViewControllerState = .default) {
        guard isAuthenticated else {
            print("Player not authenticated")
            return
        }
        
        gameCenterSheetState = state
    }
    
    // MARK: - Show Leaderboards
    func showLeaderboards() {
        showGameCenterDashboard(state: .leaderboards)
    }
    
    // MARK: - Show Achievements
    func showAchievements() {
        showGameCenterDashboard(state: .achievements)
    }
    
    // MARK: - Dismiss Game Center Sheet
    func dismissGameCenterSheet() {
        gameCenterSheetState = nil
    }
    
    // MARK: - Player Info
    var playerDisplayName: String {
        localPlayer?.displayName ?? "Guest"
    }
    
    var playerAlias: String {
        localPlayer?.alias ?? "Guest"
    }
}
