//
//  SignInView.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import SwiftUI

struct SignInView: View {
    @State private var username = ""
    @State private var isSignedIn = false
    @State private var showError = false
    @State private var scale: CGFloat = 0.8
    @State private var opacity: Double = 0
    
    var body: some View {
        Group {
            if isSignedIn {
                ContentView()
            } else {
                signInScreen
            }
        }
    }
    
    private var signInScreen: some View {
        ZStack {
            // Animated background gradient
            LinearGradient(
                colors: [
                    Color(red: 0.1, green: 0.2, blue: 0.45),
                    Color(red: 0.2, green: 0.3, blue: 0.6),
                    Color(red: 0.15, green: 0.25, blue: 0.5)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Chess pattern overlay
            chessPatternOverlay
            
            VStack(spacing: 40) {
                Spacer()
                
                // Logo and title section
                logoSection
                
                // Sign in form
                signInForm
                
                // Guest option
                guestButton
                
                Spacer()
                
                // Footer
                footerText
            }
            .padding(.horizontal, 32)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Listen for sign out
            NotificationCenter.default.addObserver(
                forName: Notification.Name("SignOut"),
                object: nil,
                queue: .main
            ) { _ in
                withAnimation {
                    isSignedIn = false
                    username = ""
                }
            }
            
            // Check if user was previously signed in
            if let savedUsername = UserDefaults.standard.string(forKey: "username"),
               !savedUsername.isEmpty,
               UserDefaults.standard.bool(forKey: "isSignedIn") {
                username = savedUsername
                // Auto sign in after a moment
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    signIn()
                }
            }
        }
    }
    
    private var logoSection: some View {
        VStack(spacing: 16) {
            // Chess pieces as logo
            HStack(spacing: 8) {
                Text("♔")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                    .shadow(color: .white.opacity(0.5), radius: 10)
                
                Text("♕")
                    .font(.system(size: 60))
                    .foregroundStyle(.white)
                    .shadow(color: .white.opacity(0.5), radius: 10)
            }
            .offset(y: -10)
            
            VStack(spacing: 8) {
                Text("Learn Chess")
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                
                Text("Master the Game of Kings")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.8))
            }
        }
    }
    
    private var signInForm: some View {
        VStack(spacing: 20) {
            // Username field
            VStack(alignment: .leading, spacing: 8) {
                Text("Welcome!")
                    .font(.headline)
                    .foregroundStyle(.white.opacity(0.9))
                
                HStack {
                    Image(systemName: "person.fill")
                        .foregroundStyle(.white.opacity(0.7))
                        .frame(width: 24)
                    
                    TextField("Enter your name", text: $username)
                        .textFieldStyle(.plain)
                        .foregroundStyle(.white)
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)
                        .onSubmit {
                            signIn()
                        }
                    
                    if !username.isEmpty {
                        Button {
                            username = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundStyle(.white.opacity(0.5))
                        }
                    }
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.white.opacity(0.15))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                )
            }
            
            // Sign in button
            Button {
                signIn()
            } label: {
                HStack(spacing: 12) {
                    Text("Start Playing")
                        .font(.headline)
                        .fontWeight(.semibold)
                    
                    Image(systemName: "arrow.right.circle.fill")
                        .font(.title3)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        colors: username.isEmpty ? 
                            [Color.gray.opacity(0.3), Color.gray.opacity(0.2)] :
                            [Color.green, Color.green.opacity(0.8)],
                        startPoint: .leading,
                        endPoint: .trailing
                    ),
                    in: RoundedRectangle(cornerRadius: 16)
                )
                .foregroundStyle(.white)
                .shadow(color: username.isEmpty ? .clear : .green.opacity(0.5), radius: 10, x: 0, y: 5)
            }
            .disabled(username.isEmpty)
            .animation(.easeInOut(duration: 0.2), value: username.isEmpty)
        }
        .padding(24)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
        )
        .alert("Please enter your name", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        }
    }
    
    private var guestButton: some View {
        Button {
            username = "Guest"
            signIn()
        } label: {
            HStack(spacing: 8) {
                Image(systemName: "person.crop.circle.badge.questionmark")
                Text("Continue as Guest")
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(.white.opacity(0.8))
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(
                Capsule()
                    .stroke(.white.opacity(0.3), lineWidth: 1.5)
            )
        }
    }
    
    private var footerText: some View {
        VStack(spacing: 4) {
            Text("Learn • Practice • Master")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.6))
            
            Text("Your journey to chess mastery starts here")
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.5))
        }
        .padding(.bottom, 20)
    }
    
    private var chessPatternOverlay: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(0..<6) { row in
                    ForEach(0..<6) { col in
                        if (row + col) % 2 == 0 {
                            Rectangle()
                                .fill(.white.opacity(0.03))
                                .frame(
                                    width: geometry.size.width / 6,
                                    height: geometry.size.width / 6
                                )
                                .offset(
                                    x: CGFloat(col) * geometry.size.width / 6 - geometry.size.width / 2,
                                    y: CGFloat(row) * geometry.size.width / 6 - geometry.size.height / 2
                                )
                        }
                    }
                }
            }
        }
        .ignoresSafeArea()
    }
    
    private func signIn() {
        guard !username.trimmingCharacters(in: .whitespaces).isEmpty else {
            showError = true
            return
        }
        
        // Save username
        UserDefaults.standard.set(username, forKey: "username")
        UserDefaults.standard.set(true, forKey: "isSignedIn")
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isSignedIn = true
        }
    }
}

#Preview {
    SignInView()
}
