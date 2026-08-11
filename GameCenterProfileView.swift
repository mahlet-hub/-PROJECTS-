//
//  GameCenterProfileView.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import SwiftUI
import GameKit

struct GameCenterProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var gameKitManager = GameKitManager.shared
    @State private var achievements: [GKAchievement] = []
    @State private var isLoadingAchievements = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.95, blue: 0.97),
                        Color(red: 0.88, green: 0.90, blue: 0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                if gameKitManager.isAuthenticated {
                    authenticatedView
                } else {
                    notAuthenticatedView
                }
            }
            .navigationTitle("Game Center")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: Binding(
                get: { gameKitManager.gameCenterSheetState != nil },
                set: { if !$0 { gameKitManager.dismissGameCenterSheet() } }
            )) {
                if let state = gameKitManager.gameCenterSheetState {
                    GameCenterViewController(state: state)
                }
            }
            .onAppear {
                if gameKitManager.isAuthenticated {
                    loadAchievements()
                }
            }
        }
    }
    
    private var authenticatedView: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Player Profile Card
                playerProfileCard
                
                // Quick Actions
                quickActionsCard
                
                // Achievements Preview
                achievementsPreviewCard
                
                // Sign Out
                signOutButton
            }
            .padding()
        }
    }
    
    private var notAuthenticatedView: some View {
        VStack(spacing: 24) {
            Image(systemName: "gamecontroller.fill")
                .font(.system(size: 80))
                .foregroundStyle(.blue)
            
            VStack(spacing: 12) {
                Text("Not Signed In")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("Sign in to Game Center to track achievements, compete on leaderboards, and save your progress.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            Button {
                gameKitManager.authenticatePlayer()
            } label: {
                HStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.badge.checkmark")
                    Text("Sign In with Game Center")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    LinearGradient(
                        colors: [Color.blue, Color.blue.opacity(0.8)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .foregroundStyle(.white)
                .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .padding(.horizontal)
        }
        .padding()
    }
    
    private var playerProfileCard: some View {
        VStack(spacing: 16) {
            // Player Avatar and Name
            HStack(spacing: 16) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(gameKitManager.playerDisplayName)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("@\(gameKitManager.playerAlias)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    HStack(spacing: 6) {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.caption)
                        Text("Game Center")
                            .font(.caption)
                    }
                    .foregroundStyle(.green)
                }
                
                Spacer()
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var quickActionsCard: some View {
        VStack(spacing: 12) {
            Text("Quick Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            VStack(spacing: 10) {
                GameCenterActionButton(
                    title: "Leaderboards",
                    icon: "list.number",
                    color: .blue
                ) {
                    gameKitManager.showLeaderboards()
                }
                
                GameCenterActionButton(
                    title: "Achievements",
                    icon: "trophy.fill",
                    color: .yellow
                ) {
                    gameKitManager.showAchievements()
                }
                
                GameCenterActionButton(
                    title: "Dashboard",
                    icon: "square.grid.2x2.fill",
                    color: .purple
                ) {
                    gameKitManager.showGameCenterDashboard()
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var achievementsPreviewCard: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Recent Achievements")
                    .font(.headline)
                
                Spacer()
                
                if isLoadingAchievements {
                    ProgressView()
                        .scaleEffect(0.8)
                }
            }
            
            if achievements.isEmpty {
                VStack(spacing: 8) {
                    Image(systemName: "trophy")
                        .font(.largeTitle)
                        .foregroundStyle(.secondary)
                    
                    Text("No achievements yet")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    
                    Text("Start playing to unlock achievements!")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.vertical, 20)
            } else {
                VStack(spacing: 8) {
                    ForEach(achievements.prefix(3), id: \.identifier) { achievement in
                        AchievementRow(achievement: achievement)
                    }
                }
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var signOutButton: some View {
        Button(role: .destructive) {
            // Note: You can't programmatically sign out from Game Center
            // Users must sign out from Settings
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "info.circle")
                Text("Sign out from Settings app")
                    .font(.caption)
            }
            .foregroundStyle(.secondary)
        }
    }
    
    private func loadAchievements() {
        isLoadingAchievements = true
        AchievementsManager.shared.loadAchievements { loadedAchievements, error in
            isLoadingAchievements = false
            if let error = error {
                print("Error loading achievements: \(error.localizedDescription)")
            } else if let loadedAchievements = loadedAchievements {
                achievements = loadedAchievements.filter { $0.percentComplete > 0 }
            }
        }
    }
}

// MARK: - Supporting Views

struct GameCenterActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(color)
                    .frame(width: 30)
                
                Text(title)
                    .font(.body)
                    .fontWeight(.medium)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color.white.opacity(0.5), in: RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }
}

struct AchievementRow: View {
    let achievement: GKAchievement
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: achievement.percentComplete == 100 ? "trophy.fill" : "trophy")
                .foregroundStyle(achievement.percentComplete == 100 ? .yellow : .secondary)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(achievement.identifier.components(separatedBy: ".").last ?? "Achievement")
                    .font(.subheadline)
                    .fontWeight(.medium)
                
                ProgressView(value: achievement.percentComplete, total: 100)
                    .tint(achievement.percentComplete == 100 ? .green : .blue)
            }
            
            Text("\(Int(achievement.percentComplete))%")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Game Center UIKit Wrapper

struct GameCenterViewController: UIViewControllerRepresentable {
    let state: GKGameCenterViewControllerState
    @Environment(\.dismiss) private var dismiss
    
    func makeUIViewController(context: Context) -> GKGameCenterViewController {
        let viewController = GKGameCenterViewController(state: state)
        viewController.gameCenterDelegate = context.coordinator
        return viewController
    }
    
    func updateUIViewController(_ uiViewController: GKGameCenterViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(dismiss: dismiss)
    }
    
    class Coordinator: NSObject, GKGameCenterControllerDelegate {
        let dismiss: DismissAction
        
        init(dismiss: DismissAction) {
            self.dismiss = dismiss
        }
        
        func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
            dismiss()
        }
    }
}

#Preview {
    GameCenterProfileView()
}
