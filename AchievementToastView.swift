//
//  AchievementToastView.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import SwiftUI

/// A toast notification that appears when an achievement is unlocked
struct AchievementToastView: View {
    let title: String
    let message: String
    let icon: String
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            if isShowing {
                HStack(spacing: 12) {
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(.yellow)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.headline)
                            .fontWeight(.bold)
                        
                        Text(message)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                }
                .padding()
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .padding(.horizontal)
                .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isShowing)
        .onAppear {
            if isShowing {
                // Auto-dismiss after 3 seconds
                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    isShowing = false
                }
            }
        }
    }
}

// MARK: - View Modifier for Easy Use

struct AchievementToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let title: String
    let message: String
    let icon: String
    
    func body(content: Content) -> some View {
        ZStack {
            content
            
            AchievementToastView(
                title: title,
                message: message,
                icon: icon,
                isShowing: $isShowing
            )
        }
    }
}

extension View {
    func achievementToast(
        isShowing: Binding<Bool>,
        title: String,
        message: String,
        icon: String = "trophy.fill"
    ) -> some View {
        modifier(AchievementToastModifier(
            isShowing: isShowing,
            title: title,
            message: message,
            icon: icon
        ))
    }
}

// MARK: - Preview
#Preview {
    @Previewable @State var showing = true
    
    VStack {
        Text("Main Content")
    }
    .achievementToast(
        isShowing: $showing,
        title: "Achievement Unlocked!",
        message: "You won your first game"
    )
}
