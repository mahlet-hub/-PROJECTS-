//
//  PointsDisplayView.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import SwiftUI

/// Displays player points, level, and progress
struct PointsDisplayView: View {
    @State private var pointsManager = PointsManager.shared
    @State private var showDetails = false
    
    var body: some View {
        Button {
            showDetails = true
        } label: {
            HStack(spacing: 12) {
                // Level badge
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 44, height: 44)
                    
                    VStack(spacing: 0) {
                        Text("\(pointsManager.level)")
                            .font(.headline)
                            .fontWeight(.bold)
                        Text("LVL")
                            .font(.system(size: 8))
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(.white)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text("\(pointsManager.totalPoints)")
                            .font(.subheadline)
                            .fontWeight(.bold)
                    }
                    
                    // Progress bar
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(.secondary.opacity(0.2))
                                .frame(height: 4)
                            
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: [.purple, .blue],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(
                                    width: geometry.size.width * pointsManager.progressToNextLevel,
                                    height: 4
                                )
                        }
                    }
                    .frame(height: 4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
        .sheet(isPresented: $showDetails) {
            PointsDetailView()
        }
    }
}

/// Detailed view of points, stats, and achievements
struct PointsDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var pointsManager = PointsManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.95, green: 0.95, blue: 0.97),
                        Color(red: 0.88, green: 0.90, blue: 0.95)
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Player Card
                        playerCard
                        
                        // Stats Grid
                        statsGrid
                        
                        // Point Earning Guide
                        pointEarningGuide
                    }
                    .padding()
                }
            }
            .navigationTitle("Player Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private var playerCard: some View {
        VStack(spacing: 16) {
            // Level badge (large)
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [.purple, .blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 100, height: 100)
                    .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                
                VStack(spacing: 4) {
                    Text("\(pointsManager.level)")
                        .font(.system(size: 40, weight: .bold))
                    Text("LEVEL")
                        .font(.caption)
                        .fontWeight(.semibold)
                }
                .foregroundStyle(.white)
            }
            
            // Title and points
            VStack(spacing: 8) {
                Text(pointsManager.playerTitle)
                    .font(.title2)
                    .fontWeight(.bold)
                
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("\(pointsManager.totalPoints) Points")
                        .font(.title3)
                        .fontWeight(.semibold)
                }
            }
            
            // Progress to next level
            VStack(spacing: 8) {
                HStack {
                    Text("Level \(pointsManager.level)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("Level \(pointsManager.level + 1)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        Capsule()
                            .fill(.secondary.opacity(0.2))
                            .frame(height: 8)
                        
                        Capsule()
                            .fill(
                                LinearGradient(
                                    colors: [.purple, .blue],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(
                                width: geometry.size.width * pointsManager.progressToNextLevel,
                                height: 8
                            )
                    }
                }
                .frame(height: 8)
                
                Text("\(pointsManager.experience) / \(pointsManager.experienceForNextLevel()) XP")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(24)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var statsGrid: some View {
        VStack(spacing: 12) {
            Text("Statistics")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                StatCard(
                    title: "Games Played",
                    value: "\(pointsManager.gamesPlayed)",
                    icon: "gamecontroller.fill",
                    color: .blue
                )
                
                StatCard(
                    title: "Games Won",
                    value: "\(pointsManager.gamesWon)",
                    icon: "trophy.fill",
                    color: .yellow
                )
                
                StatCard(
                    title: "Win Rate",
                    value: String(format: "%.1f%%", pointsManager.winRate),
                    icon: "chart.line.uptrend.xyaxis",
                    color: .green
                )
                
                StatCard(
                    title: "Win Streak",
                    value: "\(pointsManager.currentWinStreak)",
                    icon: "flame.fill",
                    color: .orange
                )
            }
        }
    }
    
    private var pointEarningGuide: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("How to Earn Points")
                .font(.headline)
            
            VStack(spacing: 12) {
                PointGuideRow(
                    icon: "trophy.fill",
                    title: "Win a Game",
                    points: 100,
                    color: .yellow
                )
                
                PointGuideRow(
                    icon: "checkmark.circle.fill",
                    title: "Checkmate",
                    points: 100,
                    color: .green
                )
                
                PointGuideRow(
                    icon: "bolt.fill",
                    title: "Quick Victory (<10 moves)",
                    points: 150,
                    color: .orange
                )
                
                PointGuideRow(
                    icon: "cpu.fill",
                    title: "Defeat Expert AI",
                    points: 400,
                    color: .purple
                )
                
                PointGuideRow(
                    icon: "shield.fill",
                    title: "Perfect Game (No losses)",
                    points: 200,
                    color: .blue
                )
                
                PointGuideRow(
                    icon: "flame.fill",
                    title: "10 Win Streak",
                    points: 300,
                    color: .red
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
}

// MARK: - Supporting Views

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
            
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }
}

struct PointGuideRow: View {
    let icon: String
    let title: String
    let points: Int
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)
                .frame(width: 30)
            
            Text(title)
                .font(.subheadline)
            
            Spacer()
            
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                Text("+\(points)")
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Points Award Animation
struct PointsAwardView: View {
    let points: Int
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            if isShowing {
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                    Text("+\(points)")
                        .font(.title2)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(.ultraThinMaterial, in: Capsule())
                .shadow(color: .yellow.opacity(0.3), radius: 10, x: 0, y: 5)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: isShowing)
        .onAppear {
            if isShowing {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    isShowing = false
                }
            }
        }
    }
}

#Preview {
    PointsDisplayView()
}

#Preview("Detail") {
    PointsDetailView()
}
