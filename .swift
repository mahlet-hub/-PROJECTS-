//
//  AISettingsView.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import SwiftUI

// NOTE: This file should not be included in the build target at the same time as ChessAI.swift
// Remove one of the ChessAI files from your target to resolve the ambiguity error

struct AISettingsView_Alternative: View {
    @Bindable var game: ChessGame
    @Environment(\.dismiss) private var dismiss
    
    @State private var aiEnabled = false
    @State private var aiPlaysAs: PieceColor = .black
    @State private var difficulty: ChessAI.Difficulty = .medium
    
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
                
                ScrollView {
                    VStack(spacing: 24) {
                        // AI Toggle Card
                        aiToggleCard
                        
                        if aiEnabled {
                            // Color Selection Card
                            colorSelectionCard
                            
                            // Difficulty Selection Card
                            difficultySelectionCard
                            
                            // Difficulty Info Card
                            difficultyInfoCard
                            
                            // AI Availability Status
                            if !game.ai.isAvailable {
                                aiUnavailableCard
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("AI Opponent")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        applySettings()
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!game.ai.isAvailable && aiEnabled)
                }
                
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                aiEnabled = game.ai.isEnabled
                aiPlaysAs = game.aiColor
                difficulty = game.ai.difficulty
            }
        }
    }
    
    private var aiToggleCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("AI Opponent")
                        .font(.title3)
                        .fontWeight(.bold)
                    
                    Text(aiEnabled ? "AI is enabled" : "Play against yourself")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                Toggle("", isOn: $aiEnabled)
                    .labelsHidden()
                    .tint(.green)
            }
            
            if aiEnabled {
                HStack(spacing: 8) {
                    Image(systemName: "sparkles")
                        .foregroundStyle(.yellow)
                    Text("Powered by Apple Intelligence")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.1), in: Capsule())
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var colorSelectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("AI Plays As")
                    .font(.headline)
                Text("Choose which color the AI controls")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            HStack(spacing: 12) {
                ColorButton_Alternative(
                    color: .black,
                    isSelected: aiPlaysAs == .black,
                    action: { aiPlaysAs = .black }
                )
                
                ColorButton_Alternative(
                    color: .white,
                    isSelected: aiPlaysAs == .white,
                    action: { aiPlaysAs = .white }
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var difficultySelectionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Difficulty Level")
                    .font(.headline)
                Text("Choose your challenge")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            VStack(spacing: 10) {
                DifficultyButton_Alternative(
                    difficulty: .easy,
                    icon: "1.circle.fill",
                    color: .green,
                    isSelected: difficulty == .easy,
                    action: { difficulty = .easy }
                )
                
                DifficultyButton_Alternative(
                    difficulty: .medium,
                    icon: "2.circle.fill",
                    color: .orange,
                    isSelected: difficulty == .medium,
                    action: { difficulty = .medium }
                )
                
                DifficultyButton_Alternative(
                    difficulty: .hard,
                    icon: "3.circle.fill",
                    color: .red,
                    isSelected: difficulty == .hard,
                    action: { difficulty = .hard }
                )
                
                DifficultyButton_Alternative(
                    difficulty: .expert,
                    icon: "crown.fill",
                    color: .purple,
                    isSelected: difficulty == .expert,
                    action: { difficulty = .expert }
                )
            }
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var difficultyInfoCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            Label("About \(difficulty.displayName)", systemImage: "info.circle.fill")
                .font(.headline)
            
            Text(difficulty.description)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)
            
            HStack(spacing: 8) {
                Image(systemName: "brain.head.profile")
                Text("Analyzes \(difficulty.searchDepth) move\(difficulty.searchDepth > 1 ? "s" : "") ahead")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.blue.opacity(0.1), in: Capsule())
        }
        .padding(20)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
    }
    
    private var aiUnavailableCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                Text("AI Unavailable")
                    .font(.headline)
            }
            
            Text(game.ai.availabilityMessage)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(20)
        .background(Color.orange.opacity(0.1), in: RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .strokeBorder(Color.orange.opacity(0.3), lineWidth: 2)
        )
    }
    
    private func applySettings() {
        game.toggleAI(enabled: aiEnabled, color: aiPlaysAs, difficulty: difficulty)
    }
}

// MARK: - Supporting Views

fileprivate struct ColorButton_Alternative: View {
    let color: PieceColor
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Circle()
                    .fill(color == .white ? Color.white : Color.black)
                    .stroke(Color.gray, lineWidth: 2)
                    .frame(width: 40, height: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(color == .white ? "White" : "Black")
                        .font(.headline)
                    Text(color == .white ? "Moves first" : "Moves second")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                isSelected
                    ? Color.green.opacity(0.15)
                    : Color.gray.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? Color.green : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

fileprivate struct DifficultyButton_Alternative: View {
    let difficulty: ChessAI.Difficulty
    let icon: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(color)
                    .frame(width: 40)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(difficulty.displayName)
                        .font(.headline)
                    Text(difficulty.shortDescription)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.blue)
                        .font(.title2)
                }
            }
            .padding()
            .background(
                isSelected
                    ? color.opacity(0.15)
                    : Color.gray.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 12)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .strokeBorder(
                        isSelected ? color : Color.clear,
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Difficulty Extensions

fileprivate extension ChessAI.Difficulty {
    var displayName: String {
        switch self {
        case .easy: return "Easy"
        case .medium: return "Medium"
        case .hard: return "Hard"
        case .expert: return "Expert"
        }
    }
    
    var shortDescription: String {
        switch self {
        case .easy: return "Perfect for beginners"
        case .medium: return "Good tactical play"
        case .hard: return "Advanced strategy"
        case .expert: return "Master level"
        }
    }
    
    var description: String {
        switch self {
        case .easy:
            return "The AI plays at a beginner level (~800 ELO), making occasional mistakes and choosing simpler moves. Great for learning the fundamentals of chess."
        case .medium:
            return "The AI plays with intermediate skill (~1400 ELO), recognizing tactical patterns like forks and pins. A balanced challenge for most players."
        case .hard:
            return "The AI plays at an advanced level (~2000 ELO) with deep strategic understanding, precise calculation, and sophisticated tactical vision."
        case .expert:
            return "The AI plays at master level (~2400+ ELO) with exceptional precision, calculating deeply and finding the objectively best moves like a chess engine."
        }
    }
}

#Preview {
    AISettingsView_Alternative(game: ChessGame())
}
