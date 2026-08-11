//
//  ContentView.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var game = ChessGame()
    @State private var showingGameCenter = false
    @State private var gameKitManager = GameKitManager.shared
    @State private var pointsManager = PointsManager.shared
    
    // Game state
    @State private var showMainMenu = true
    @State private var gameStarted = false
    
    // Game mode
    enum GameMode {
        case twoPlayer
        case vsBot
    }
    @State private var currentGameMode: GameMode = .twoPlayer
    
    // User info
    private var username: String {
        UserDefaults.standard.string(forKey: "username") ?? "Player"
    }
    
    // Points notification
    @State private var showPointsAward = false
    @State private var awardedPoints = 0
    
    // Level up notification
    @State private var showLevelUp = false
    @State private var newLevel = 0
    
    // Chess tutor
    @State private var showTutorMessage = false
    @State private var tutorMessage = ""
    @State private var tutorMessageTimer: Timer?
    
    // Game start animation
    @State private var showGameStartAnimation = false
    @State private var gameStartAnimationProgress: CGFloat = 0
    
    var body: some View {
        Group {
            if showMainMenu {
                MainMenuView(
                    username: username,
                    onPlayVsBot: {
                        currentGameMode = .vsBot
                        game.toggleAI(enabled: true, color: .black, difficulty: .medium)
                        showGameStartAnimation = true
                        withAnimation(.easeInOut) {
                            showMainMenu = false
                            gameStarted = true
                        }
                        // Show animation, then tutor message
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                            showTutorMessage(
                                "Welcome! I'm here to help you learn chess. Let's start with the basics: try moving a pawn forward!"
                            )
                        }
                    },
                    onPlay2Player: {
                        currentGameMode = .twoPlayer
                        game.toggleAI(enabled: false, color: .black, difficulty: .easy)
                        showGameStartAnimation = true
                        withAnimation(.easeInOut) {
                            showMainMenu = false
                            gameStarted = true
                        }
                    },
                    onShowGameCenter: {
                        showingGameCenter = true
                    }
                )
            } else {
                gameView
            }
        }
        .sheet(isPresented: $showingGameCenter) {
            GameCenterProfileView()
        }
        .sheet(isPresented: $game.showingPawnPromotion) {
            PawnPromotionView(game: game)
                .presentationDetents([.height(300)])
                .presentationDragIndicator(.visible)
        }
        .onAppear {
            // Authenticate with Game Center when the app launches
            if !gameKitManager.isAuthenticated {
                gameKitManager.authenticatePlayer()
            }
            
            // Listen for point awards
            NotificationCenter.default.addObserver(
                forName: Notification.Name("PointsAwarded"),
                object: nil,
                queue: .main
            ) { notification in
                if let points = notification.userInfo?["points"] as? Int {
                    awardedPoints = points
                    showPointsAward = true
                }
            }
            
            // Listen for level ups
            NotificationCenter.default.addObserver(
                forName: Notification.Name("LevelUp"),
                object: nil,
                queue: .main
            ) { notification in
                if let level = notification.userInfo?["level"] as? Int {
                    newLevel = level
                    showLevelUp = true
                }
            }
        }
        .onChange(of: game.moveHistory.count) {
            if currentGameMode == .vsBot {
                showRandomTutorTip()
            }
        }
        .overlay {
            // Points award notification
            PointsAwardView(points: awardedPoints, isShowing: $showPointsAward)
        }
        .overlay {
            // Level up notification
            if showLevelUp {
                LevelUpView(level: newLevel, isShowing: $showLevelUp)
            }
        }
    }
    
    private var gameView: some View {
        ZStack {
            // Retro grey background
            Color(red: 0.75, green: 0.75, blue: 0.75)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Top bar with retro style
                topBar
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Game status card
                        gameStatusCard
                        
                        // Chess tutor message at top (only in bot mode)
                        if currentGameMode == .vsBot && showTutorMessage {
                            tutorMessageBanner
                                .padding(.horizontal, 16)
                        }
                        
                        // Chess board (larger, centered)
                        ChessBoardView(game: game)
                            .aspectRatio(1, contentMode: .fit)
                            .padding(.horizontal, 20)
                        
                        // Captured pieces display
                        capturedPiecesView
                        
                        // Move history
                        moveHistoryCard
                        
                        // Control buttons
                        controlButtons
                            .padding(.bottom, 20)
                    }
                    .padding(.vertical, 16)
                }
            }
            
            // Game start animation overlay
            if showGameStartAnimation {
                gameStartAnimationView
            }
        }
        .onAppear {
            if showGameStartAnimation {
                playGameStartAnimation()
            }
        }
    }
    
    private var topBar: some View {
        VStack(spacing: 0) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Text(username)
                            .font(.system(size: 20, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                    
                    HStack(spacing: 6) {
                        Image(systemName: currentGameMode == .vsBot ? "cpu.fill" : "person.2.fill")
                            .font(.caption)
                            .foregroundStyle(.white)
                        Text(currentGameMode == .vsBot ? "VS BOT" : "2 PLAYER")
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                }
                
                Spacer()
                
                // Points and Level Display
                VStack(alignment: .trailing, spacing: 2) {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .font(.system(size: 10))
                            .foregroundStyle(.yellow)
                        Text("\(pointsManager.totalPoints)")
                            .font(.system(size: 14, weight: .bold, design: .monospaced))
                            .foregroundStyle(.white)
                    }
                    
                    HStack(spacing: 4) {
                        Text("LVL")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundStyle(.purple.opacity(0.8))
                        Text("\(pointsManager.level)")
                            .font(.system(size: 12, weight: .bold, design: .monospaced))
                            .foregroundStyle(.purple)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(Color.white)
                    .overlay(
                        Rectangle()
                            .strokeBorder(Color.purple, lineWidth: 2)
                    )
                }
                
                // Retro back to menu button
                Button {
                    withAnimation(.easeInOut) {
                        showMainMenu = true
                        gameStarted = false
                    }
                } label: {
                    Text("MENU")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(
                            Color(red: 0.2, green: 0.4, blue: 0.8)
                        )
                        .overlay(
                            Rectangle()
                                .strokeBorder(.black, lineWidth: 3)
                        )
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color(red: 0.3, green: 0.3, blue: 0.3))
            
            // AI Difficulty Selector Bar (only show in bot mode)
            if currentGameMode == .vsBot {
                aiDifficultyBar
            }
        }
        .overlay(
            Rectangle()
                .frame(height: 3)
                .foregroundStyle(.black),
            alignment: .bottom
        )
    }
    
    private var aiDifficultyBar: some View {
        HStack(spacing: 0) {
            // Label
            Text("BOT:")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
                .padding(.leading, 20)
            
            Spacer()
            
            // Difficulty buttons
            HStack(spacing: 8) {
                DifficultyButton(
                    title: "EASY",
                    difficulty: .easy,
                    color: .green,
                    icon: "1",
                    isSelected: game.ai.difficulty == .easy
                ) {
                    game.ai.difficulty = .easy
                }
                
                DifficultyButton(
                    title: "MED",
                    difficulty: .medium,
                    color: .orange,
                    icon: "2",
                    isSelected: game.ai.difficulty == .medium
                ) {
                    game.ai.difficulty = .medium
                }
                
                DifficultyButton(
                    title: "HARD",
                    difficulty: .hard,
                    color: .red,
                    icon: "3",
                    isSelected: game.ai.difficulty == .hard
                ) {
                    game.ai.difficulty = .hard
                }
                
                DifficultyButton(
                    title: "EXP",
                    difficulty: .expert,
                    color: .purple,
                    icon: "★",
                    isSelected: game.ai.difficulty == .expert
                ) {
                    game.ai.difficulty = .expert
                }
            }
            .padding(.trailing, 20)
        }
        .padding(.vertical, 10)
        .background(Color(red: 0.25, green: 0.25, blue: 0.25))
    }
    
    private func signOut() {
        UserDefaults.standard.removeObject(forKey: "username")
        UserDefaults.standard.set(false, forKey: "isSignedIn")
        
        // Reset the entire app by posting a notification
        // We'll need to handle this in SignInView
        NotificationCenter.default.post(name: Notification.Name("SignOut"), object: nil)
    }
    
    private func handleGameModeSelection(_ mode: GameMode) {
        currentGameMode = mode
        
        // Reset game
        withAnimation(.spring(response: 0.3)) {
            game.resetGame()
        }
        
        // Configure AI based on mode
        if mode == .vsBot {
            game.toggleAI(enabled: true, color: .black, difficulty: .medium)
            showTutorMessage(
                "Welcome! I'm here to help you learn chess. Let's start with the basics: try moving a pawn forward!"
            )
        } else {
            game.toggleAI(enabled: false, color: .black, difficulty: .easy)
        }
    }
    
    private func showTutorMessage(_ message: String) {
        tutorMessage = message
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            showTutorMessage = true
        }
        
        // Auto-hide after 8 seconds
        tutorMessageTimer?.invalidate()
        tutorMessageTimer = Timer.scheduledTimer(withTimeInterval: 8.0, repeats: false) { _ in
            withAnimation {
                showTutorMessage = false
            }
        }
    }
    
    private func showRandomTutorTip() {
        let tips = [
            "Great move! Remember to control the center of the board.",
            "Try to develop your pieces early in the game!",
            "Knights move in an L-shape: 2 squares in one direction, 1 square perpendicular.",
            "Bishops move diagonally across the board.",
            "Rooks are powerful! They move horizontally or vertically.",
            "The queen is your most powerful piece - use her wisely!",
            "Protect your king! That's the most important piece.",
            "Pawns can only move forward, but they capture diagonally.",
            "Castle to keep your king safe! Move the king 2 squares toward a rook.",
            "Look for opportunities to capture opponent pieces!",
            "Think ahead! What will your opponent do next?",
            "Control the center squares (e4, d4, e5, d5) for better position."
        ]
        
        // Show tip randomly (30% chance per move)
        if Int.random(in: 1...10) <= 3 {
            showTutorMessage(tips.randomElement() ?? tips[0])
        }
    }
    
    private var chessTutorView: some View {
        VStack(spacing: 0) {
            // Tutor character
            ZStack(alignment: .bottom) {
                // Character avatar
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [Color.purple, Color.blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 80, height: 80)
                        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
                    
                    Text("🧙‍♂️")
                        .font(.system(size: 40))
                }
                
                // Speech bubble with text
                if showTutorMessage {
                    VStack(alignment: .leading, spacing: 0) {
                        Text(tutorMessage)
                            .font(.caption)
                            .foregroundStyle(.primary)
                            .padding(12)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .strokeBorder(Color.purple.opacity(0.3), lineWidth: 1.5)
                            )
                            .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
                        
                        // Speech bubble tail
                        Triangle()
                            .fill(.ultraThinMaterial)
                            .frame(width: 20, height: 10)
                            .offset(x: 10, y: -1)
                    }
                    .frame(width: 180)
                    .offset(x: 100, y: -30)
                    .transition(.scale(scale: 0.8).combined(with: .opacity))
                }
            }
            .frame(height: 100)
            
            VStack(spacing: 4) {
                Text("Chess Tutor")
                    .font(.caption)
                    .fontWeight(.bold)
                
                Text("Magnus")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(.top, 8)
            
            Spacer()
        }
    }
    
    private var tutorMessageBanner: some View {
        HStack(spacing: 12) {
            // Tutor avatar
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [Color.purple, Color.blue],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 50, height: 50)
                    .shadow(color: .purple.opacity(0.3), radius: 5, x: 0, y: 2)
                
                Text("🧙‍♂️")
                    .font(.system(size: 25))
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Chess Tutor")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.white.opacity(0.9))
                
                Text(tutorMessage)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.leading)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(
                    LinearGradient(
                        colors: [Color.purple.opacity(0.95), Color.purple.opacity(0.85)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
        )
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.purple.opacity(0.5), lineWidth: 1.5)
        )
        .shadow(color: .purple.opacity(0.3), radius: 10, x: 0, y: 5)
        .transition(.move(edge: .top).combined(with: .opacity))
    }
    
    private var gameStartAnimationView: some View {
        ZStack {
            // Dark background
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Animated chess pieces
                HStack(spacing: 40) {
                    Text("♔")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                        .scaleEffect(gameStartAnimationProgress > 0.2 ? 1.0 : 0.3)
                        .opacity(gameStartAnimationProgress > 0.2 ? 1.0 : 0.0)
                        .rotationEffect(.degrees(gameStartAnimationProgress > 0.2 ? 0 : -180))
                    
                    Text("♞")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)
                        .scaleEffect(gameStartAnimationProgress > 0.4 ? 1.0 : 0.3)
                        .opacity(gameStartAnimationProgress > 0.4 ? 1.0 : 0.0)
                        .rotationEffect(.degrees(gameStartAnimationProgress > 0.4 ? 0 : 180))
                }
                
                // "Ready" text
                VStack(spacing: 12) {
                    Text(gameStartAnimationProgress > 0.6 ? "READY" : "")
                        .font(.system(size: 48, weight: .black, design: .monospaced))
                        .foregroundStyle(.white)
                        .opacity(gameStartAnimationProgress > 0.6 ? 1.0 : 0.0)
                        .scaleEffect(gameStartAnimationProgress > 0.6 ? 1.0 : 0.5)
                    
                    Text(gameStartAnimationProgress > 0.8 ? "LET'S PLAY!" : "")
                        .font(.system(size: 32, weight: .bold, design: .monospaced))
                        .foregroundStyle(Color(red: 0.2, green: 0.4, blue: 0.8))
                        .opacity(gameStartAnimationProgress > 0.8 ? 1.0 : 0.0)
                        .scaleEffect(gameStartAnimationProgress > 0.8 ? 1.0 : 0.5)
                }
                
                // Progress bar
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color.white.opacity(0.2))
                        .frame(width: 200, height: 8)
                    
                    RoundedRectangle(cornerRadius: 4)
                        .fill(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .frame(width: 200 * gameStartAnimationProgress, height: 8)
                }
                .padding(.top, 20)
            }
        }
    }
    
    private func playGameStartAnimation() {
        gameStartAnimationProgress = 0
        
        // Animate progress bar
        withAnimation(.easeInOut(duration: 2.0)) {
            gameStartAnimationProgress = 1.0
        }
        
        // Dismiss animation after completion
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation {
                showGameStartAnimation = false
                gameStartAnimationProgress = 0
            }
        }
    }
    
    private var aiThinkingOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: 16) {
                ProgressView()
                    .progressViewStyle(.circular)
                    .tint(.white)
                    .scaleEffect(1.8)
                    .padding()
                
                VStack(spacing: 6) {
                    Text("AI Analyzing")
                        .font(.title3)
                        .fontWeight(.semibold)
                    Text("Calculating best move...")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .foregroundStyle(.white)
            }
            .padding(32)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .shadow(color: .black.opacity(0.3), radius: 20)
        }
    }
    
    private var gameStatusCard: some View {
        VStack(spacing: 12) {
            HStack {
                Rectangle()
                    .fill(game.currentTurn == .white ? Color.white : Color.black)
                    .frame(width: 20, height: 20)
                    .overlay(
                        Rectangle()
                            .strokeBorder(.black, lineWidth: 2)
                    )
                
                Text(currentTurnText)
                    .font(.system(size: 18, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }
            
            if case .checkmate(let winner) = game.gameStatus {
                HStack(spacing: 8) {
                    Text("★")
                        .font(.title)
                    Text("\(winner == .white ? "WHITE" : "BLACK") WINS!")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(.yellow)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.black)
                .overlay(
                    Rectangle()
                        .strokeBorder(.yellow, lineWidth: 3)
                )
            } else if case .stalemate = game.gameStatus {
                HStack(spacing: 8) {
                    Text("=")
                        .font(.title)
                        .fontWeight(.bold)
                    Text("STALEMATE - DRAW")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color(red: 0.5, green: 0.5, blue: 0.5))
                .overlay(
                    Rectangle()
                        .strokeBorder(.black, lineWidth: 3)
                )
            }
        }
        .frame(maxWidth: .infinity)
        .padding(20)
        .background(Color(red: 0.2, green: 0.4, blue: 0.8))
        .overlay(
            Rectangle()
                .strokeBorder(.black, lineWidth: 4)
        )
        .padding(.horizontal, 16)
    }
    
    private var currentTurnText: String {
        game.currentTurn == .white ? "WHITE'S TURN" : "BLACK'S TURN"
    }
    
    private var capturedPiecesView: some View {
        HStack(spacing: 20) {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(.white)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Rectangle()
                                .strokeBorder(.black, lineWidth: 1)
                        )
                    Text("CAPTURED")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }
                
                if game.capturedByWhite.isEmpty {
                    Text("NONE")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.7))
                } else {
                    // Captured pieces are BLACK pieces (captured by white)
                    // Display them as black pieces
                    HStack(spacing: 4) {
                        ForEach(Array(game.capturedByWhite.enumerated()), id: \.offset) { _, piece in
                            Text(piece.symbol)
                                .font(.system(size: piece.type == .pawn ? 20 : 24))
                                .foregroundStyle(Color.black)
                                .shadow(color: .black.opacity(0.2), radius: 1, x: 0, y: 1)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(red: 0.4, green: 0.4, blue: 0.4))
            .overlay(
                Rectangle()
                    .strokeBorder(.black, lineWidth: 3)
            )
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 6) {
                    Rectangle()
                        .fill(.black)
                        .frame(width: 12, height: 12)
                        .overlay(
                            Rectangle()
                                .strokeBorder(.white, lineWidth: 1)
                        )
                    Text("CAPTURED")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                }
                
                if game.capturedByBlack.isEmpty {
                    Text("NONE")
                        .font(.system(size: 9, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.7))
                } else {
                    // Captured pieces are WHITE pieces (captured by black)
                    // Display them as white pieces using colorInvert
                    HStack(spacing: 4) {
                        ForEach(Array(game.capturedByBlack.enumerated()), id: \.offset) { _, piece in
                            Text(piece.symbol)
                                .font(.system(size: piece.type == .pawn ? 20 : 24))
                                .foregroundStyle(Color.black)
                                .colorInvert() // Makes pieces appear white
                                .shadow(color: .white.opacity(0.3), radius: 1, x: 0, y: 1)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()
            .background(Color(red: 0.4, green: 0.4, blue: 0.4))
            .overlay(
                Rectangle()
                    .strokeBorder(.black, lineWidth: 3)
            )
        }
        .padding(.horizontal, 16)
    }
    
    @ViewBuilder
    private var moveHistoryCard: some View {
        if !game.moveHistory.isEmpty {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("▶")
                        .font(.system(size: 14, design: .monospaced))
                        .foregroundStyle(.white)
                    Text("MOVE HISTORY")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                    Spacer()
                    Text("\(game.moveHistory.count) MOVES")
                        .font(.system(size: 10, design: .monospaced))
                        .foregroundStyle(.white.opacity(0.8))
                }
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(Array(game.moveHistory.enumerated()), id: \.offset) { index, move in
                            MoveHistoryBubble(move: move, index: index)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            .padding(20)
            .background(Color(red: 0.3, green: 0.3, blue: 0.3))
            .overlay(
                Rectangle()
                    .strokeBorder(.black, lineWidth: 4)
            )
            .padding(.horizontal, 16)
        }
    }
    
    private var controlButtons: some View {
        VStack(spacing: 14) {
            // Reset Game button
            Button {
                withAnimation(.easeInOut) {
                    game.resetGame()
                }
            } label: {
                Text("RESET GAME")
                    .font(.system(size: 16, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(red: 0.8, green: 0.2, blue: 0.2))
                    .overlay(
                        Rectangle()
                            .strokeBorder(.black, lineWidth: 4)
                    )
            }
        }
        .padding(.horizontal, 16)
    }
}

struct MoveHistoryBubble: View {
    let move: ChessGame.ChessMove
    let index: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text("\(index + 1).")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                
                // Match piece colors to board appearance
                if move.piece.color == .white {
                    Text(move.piece.symbol)
                        .font(.body)
                        .foregroundStyle(Color.black)
                        .colorInvert() // Makes it appear white
                } else {
                    Text(move.piece.symbol)
                        .font(.body)
                        .foregroundStyle(Color.black) // Black pieces stay black
                }
            }
            
            HStack(spacing: 2) {
                Text(move.from.notation)
                    .font(.system(size: 10, design: .monospaced))
                Text("→")
                    .font(.system(size: 10))
                Text(move.to.notation)
                    .font(.system(size: 10, design: .monospaced))
            }
            .foregroundStyle(.white.opacity(0.8))
            
            if let captured = move.capturedPiece {
                HStack(spacing: 2) {
                    Text("X")
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                    
                    // Match captured piece colors to board appearance
                    if captured.color == .white {
                        Text(captured.symbol)
                            .font(.caption)
                            .foregroundStyle(Color.black)
                            .colorInvert() // Makes it appear white
                    } else {
                        Text(captured.symbol)
                            .font(.caption)
                            .foregroundStyle(Color.black) // Black pieces stay black
                    }
                }
                .foregroundStyle(.red)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color(red: 0.5, green: 0.5, blue: 0.5))
        .overlay(
            Rectangle()
                .strokeBorder(.black, lineWidth: 2)
        )
    }
}

// MARK: - Main Menu View
struct MainMenuView: View {
    let username: String
    var onPlayVsBot: () -> Void
    var onPlay2Player: () -> Void
    var onShowGameCenter: () -> Void
    
    @State private var animateTitle = false
    @State private var showButtons = false
    
    var body: some View {
        ZStack {
            // Retro grey background
            Color(red: 0.75, green: 0.75, blue: 0.75)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Retro title
                VStack(spacing: 20) {
                    // Pixel-style chess pieces
                    HStack(spacing: 16) {
                        Text("♔")
                            .font(.system(size: 70))
                            .foregroundStyle(.white)
                            .offset(y: animateTitle ? -10 : 0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: animateTitle)
                        
                        Text("♞")
                            .font(.system(size: 70))
                            .foregroundStyle(.black)
                            .offset(y: animateTitle ? 10 : 0)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true).delay(0.3), value: animateTitle)
                    }
                    
                    // Title
                    VStack(spacing: 8) {
                        Text("LEARN")
                            .font(.system(size: 52, weight: .black, design: .monospaced))
                            .foregroundStyle(.white)
                            .shadow(color: .black, radius: 0, x: 4, y: 4)
                        
                        Text("CHESS")
                            .font(.system(size: 52, weight: .black, design: .monospaced))
                            .foregroundStyle(Color(red: 0.2, green: 0.4, blue: 0.8))
                            .shadow(color: .black, radius: 0, x: 4, y: 4)
                    }
                    
                    // Player name
                    Text("PLAYER: \(username.uppercased())")
                        .font(.system(size: 14, weight: .bold, design: .monospaced))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .overlay(
                            Rectangle()
                                .strokeBorder(.white, lineWidth: 2)
                        )
                }
                
                Spacer()
                
                // Menu buttons
                if showButtons {
                    VStack(spacing: 20) {
                        // Play vs Bot button
                        Button {
                            onPlayVsBot()
                        } label: {
                            HStack {
                                Text("▶")
                                    .font(.system(size: 20, design: .monospaced))
                                Text("PLAY VS BOT")
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: 300)
                            .padding(.vertical, 20)
                            .background(Color(red: 0.2, green: 0.4, blue: 0.8))
                            .overlay(
                                Rectangle()
                                    .strokeBorder(.black, lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.5), radius: 0, x: 6, y: 6)
                        }
                        .transition(.scale.combined(with: .opacity))
                        
                        // 2 Player button
                        Button {
                            onPlay2Player()
                        } label: {
                            HStack {
                                Text("▶")
                                    .font(.system(size: 20, design: .monospaced))
                                Text("2 PLAYER")
                                    .font(.system(size: 20, weight: .bold, design: .monospaced))
                            }
                            .foregroundStyle(.white)
                            .frame(maxWidth: 300)
                            .padding(.vertical, 20)
                            .background(Color(red: 0.2, green: 0.6, blue: 0.3))
                            .overlay(
                                Rectangle()
                                    .strokeBorder(.black, lineWidth: 4)
                            )
                            .shadow(color: .black.opacity(0.5), radius: 0, x: 6, y: 6)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                    .padding(.horizontal, 32)
                }
                
                Spacer()
                
                // Footer
                if showButtons {
                    VStack(spacing: 8) {
                        Text("© 2026 LEARN CHESS")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundStyle(.black.opacity(0.6))
                        
                        Text("PRESS START TO BEGIN")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundStyle(.black.opacity(0.4))
                    }
                    .padding(.bottom, 20)
                    .transition(.opacity)
                }
            }
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5)) {
                animateTitle = true
            }
            
            // Delay button appearance for retro effect
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                    showButtons = true
                }
            }
        }
    }
}

// MARK: - Level Up View
struct LevelUpView: View {
    let level: Int
    @Binding var isShowing: Bool
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .opacity(opacity)
            
            VStack(spacing: 20) {
                // Star burst effect
                Image(systemName: "star.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.yellow, .orange],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .scaleEffect(scale)
                
                VStack(spacing: 8) {
                    Text("LEVEL UP!")
                        .font(.system(size: 36, weight: .bold))
                        .foregroundStyle(.white)
                    
                    Text("You reached Level \(level)")
                        .font(.title3)
                        .foregroundStyle(.white.opacity(0.9))
                    
                    Text("+\(level * 50) Bonus Points")
                        .font(.headline)
                        .foregroundStyle(.yellow)
                        .padding(.top, 4)
                }
                
                Button {
                    withAnimation {
                        isShowing = false
                    }
                } label: {
                    Text("Awesome!")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                colors: [.purple, .blue],
                                startPoint: .leading,
                                endPoint: .trailing
                            ),
                            in: Capsule()
                        )
                }
                .padding(.top, 8)
            }
            .padding(40)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 24))
            .shadow(color: .yellow.opacity(0.5), radius: 20, x: 0, y: 10)
            .scaleEffect(scale)
            .opacity(opacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7)) {
                scale = 1.0
                opacity = 1.0
            }
            
            // Auto-dismiss after 4 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                withAnimation {
                    isShowing = false
                }
            }
        }
    }
}

// MARK: - Pawn Promotion View

struct PawnPromotionView: View {
    @Bindable var game: ChessGame
    
    var body: some View {
        VStack(spacing: 24) {
            VStack(spacing: 8) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 50))
                    .foregroundStyle(.yellow)
                
                Text("Pawn Promotion")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Choose a piece to promote your pawn to:")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.top, 20)
            
            HStack(spacing: 16) {
                PromotionPieceButton(
                    piece: .queen,
                    color: game.promotionColor ?? .white,
                    game: game
                )
                
                PromotionPieceButton(
                    piece: .rook,
                    color: game.promotionColor ?? .white,
                    game: game
                )
                
                PromotionPieceButton(
                    piece: .bishop,
                    color: game.promotionColor ?? .white,
                    game: game
                )
                
                PromotionPieceButton(
                    piece: .knight,
                    color: game.promotionColor ?? .white,
                    game: game
                )
            }
            .padding(.horizontal)
            
            Spacer()
        }
    }
}

struct PromotionPieceButton: View {
    let piece: PieceType
    let color: PieceColor
    @Bindable var game: ChessGame
    
    var body: some View {
        Button {
            game.promotePawn(to: piece)
        } label: {
            VStack(spacing: 8) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    Color.blue.opacity(0.2),
                                    Color.blue.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 70, height: 70)
                    
                    if color == .white {
                        Text(ChessPiece(type: piece, color: color).symbol)
                            .font(.system(size: 40))
                            .foregroundStyle(Color.black)
                            .colorInvert()
                    } else {
                        Text(ChessPiece(type: piece, color: color).symbol)
                            .font(.system(size: 40))
                            .foregroundStyle(Color.black)
                    }
                }
                
                Text(pieceName)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundStyle(.secondary)
            }
        }
        .buttonStyle(.plain)
    }
    
    var pieceName: String {
        switch piece {
        case .queen: return "Queen"
        case .rook: return "Castle"
        case .bishop: return "Bishop"
        case .knight: return "Horse"
        default: return ""
        }
    }
}

#Preview {
    ContentView()
}

// MARK: - Triangle Shape for Speech Bubble
struct Triangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.maxY))
        path.closeSubpath()
        return path
    }
}

// MARK: - Game Mode Selection View
struct GameModeSelectionView: View {
    @Bindable var game: ChessGame
    @Binding var currentGameMode: ContentView.GameMode
    var onModeSelected: (ContentView.GameMode) -> Void
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedMode: ContentView.GameMode = .twoPlayer
    @State private var selectedDifficulty: ChessAI.Difficulty = .medium
    
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
                        // Header
                        VStack(spacing: 8) {
                            Image(systemName: "gamecontroller.fill")
                                .font(.system(size: 60))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.blue, .purple],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            
                            Text("Choose Game Mode")
                                .font(.title)
                                .fontWeight(.bold)
                            
                            Text("Select how you want to play")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        .padding(.top, 20)
                        
                        // Game Mode Cards
                        VStack(spacing: 16) {
                            GameModeCard(
                                title: "Play vs Bot",
                                icon: "cpu.fill",
                                description: "Learn chess with AI guidance",
                                color: .purple,
                                isSelected: selectedMode == .vsBot,
                                action: { selectedMode = .vsBot }
                            )
                            
                            GameModeCard(
                                title: "2 Player",
                                icon: "person.2.fill",
                                description: "Play with a friend locally",
                                color: .green,
                                isSelected: selectedMode == .twoPlayer,
                                action: { selectedMode = .twoPlayer }
                            )
                        }
                        .padding(.horizontal)
                        
                        // Difficulty selection (only for bot mode)
                        if selectedMode == .vsBot {
                            VStack(alignment: .leading, spacing: 16) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Bot Difficulty")
                                        .font(.headline)
                                    Text("Choose your challenge level")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                
                                VStack(spacing: 10) {
                                    DifficultyOptionButton(
                                        difficulty: .easy,
                                        icon: "1.circle.fill",
                                        color: .green,
                                        isSelected: selectedDifficulty == .easy,
                                        action: { selectedDifficulty = .easy }
                                    )
                                    
                                    DifficultyOptionButton(
                                        difficulty: .medium,
                                        icon: "2.circle.fill",
                                        color: .orange,
                                        isSelected: selectedDifficulty == .medium,
                                        action: { selectedDifficulty = .medium }
                                    )
                                    
                                    DifficultyOptionButton(
                                        difficulty: .hard,
                                        icon: "3.circle.fill",
                                        color: .red,
                                        isSelected: selectedDifficulty == .hard,
                                        action: { selectedDifficulty = .hard }
                                    )
                                    
                                    DifficultyOptionButton(
                                        difficulty: .expert,
                                        icon: "crown.fill",
                                        color: .purple,
                                        isSelected: selectedDifficulty == .expert,
                                        action: { selectedDifficulty = .expert }
                                    )
                                }
                            }
                            .padding(20)
                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                            .padding(.horizontal)
                        }
                        
                        // Start Game Button
                        Button {
                            if selectedMode == .vsBot {
                                game.toggleAI(enabled: true, color: .black, difficulty: selectedDifficulty)
                            }
                            onModeSelected(selectedMode)
                            dismiss()
                        } label: {
                            HStack(spacing: 12) {
                                Text("Start Game")
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                
                                Image(systemName: "arrow.right.circle.fill")
                                    .font(.title3)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    colors: [Color.blue, Color.blue.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                ),
                                in: RoundedRectangle(cornerRadius: 16)
                            )
                            .foregroundStyle(.white)
                            .shadow(color: .blue.opacity(0.5), radius: 10, x: 0, y: 5)
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("New Game")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Game Mode Card
struct GameModeCard: View {
    let title: String
    let icon: String
    let description: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 60, height: 60)
                    
                    Image(systemName: icon)
                        .font(.title2)
                        .foregroundStyle(color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(.primary)
                    
                    Text(description)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.blue)
                }
            }
            .padding(20)
            .background(
                isSelected
                    ? color.opacity(0.1)
                    : Color.gray.opacity(0.05),
                in: RoundedRectangle(cornerRadius: 20)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .strokeBorder(
                        isSelected ? color : Color.clear,
                        lineWidth: 2
                    )
            )
            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Difficulty Option Button
struct DifficultyOptionButton: View {
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

// MARK: - Difficulty Button
struct DifficultyButton: View {
    let title: String
    let difficulty: ChessAI.Difficulty
    let color: Color
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(icon)
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
                
                Text(title)
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .foregroundStyle(.white)
            }
            .frame(width: 50, height: 40)
            .background(isSelected ? color : Color.gray)
            .overlay(
                Rectangle()
                    .strokeBorder(.black, lineWidth: 2)
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
}
