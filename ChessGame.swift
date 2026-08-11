//
//  ChessGame.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation
import SwiftUI

@Observable
class ChessGame {
    var board: [[ChessPiece?]]
    var currentTurn: PieceColor = .white
    var selectedPosition: ChessPosition?
    var validMoves: Set<ChessPosition> = []
    var gameStatus: GameStatus = .ongoing
    var moveHistory: [ChessMove] = []
    var capturedByWhite: [ChessPiece] = []
    var capturedByBlack: [ChessPiece] = []
    
    // Pawn Promotion
    var showingPawnPromotion = false
    var promotionPosition: ChessPosition?
    var promotionColor: PieceColor?
    
    // AI Integration
    var ai: ChessAI = ChessAI()
    var aiColor: PieceColor = .black // Which color the AI plays
    var isAIThinking: Bool = false
    
    enum GameStatus: Equatable {
        case ongoing
        case check(PieceColor)
        case checkmate(winner: PieceColor)
        case stalemate
    }
    
    struct ChessMove {
        let from: ChessPosition
        let to: ChessPosition
        let piece: ChessPiece
        let capturedPiece: ChessPiece?
    }
    
    init() {
        self.board = ChessGame.createInitialBoard()
    }
    
    static func createInitialBoard() -> [[ChessPiece?]] {
        var board = Array(repeating: Array(repeating: Optional<ChessPiece>.none, count: 8), count: 8)
        
        // Black pieces
        board[0] = [
            ChessPiece(type: .rook, color: .black),
            ChessPiece(type: .knight, color: .black),
            ChessPiece(type: .bishop, color: .black),
            ChessPiece(type: .queen, color: .black),
            ChessPiece(type: .king, color: .black),
            ChessPiece(type: .bishop, color: .black),
            ChessPiece(type: .knight, color: .black),
            ChessPiece(type: .rook, color: .black)
        ]
        
        // Black pawns
        for col in 0..<8 {
            board[1][col] = ChessPiece(type: .pawn, color: .black)
        }
        
        // White pawns
        for col in 0..<8 {
            board[6][col] = ChessPiece(type: .pawn, color: .white)
        }
        
        // White pieces
        board[7] = [
            ChessPiece(type: .rook, color: .white),
            ChessPiece(type: .knight, color: .white),
            ChessPiece(type: .bishop, color: .white),
            ChessPiece(type: .queen, color: .white),
            ChessPiece(type: .king, color: .white),
            ChessPiece(type: .bishop, color: .white),
            ChessPiece(type: .knight, color: .white),
            ChessPiece(type: .rook, color: .white)
        ]
        
        return board
    }
    
    func pieceAt(_ position: ChessPosition) -> ChessPiece? {
        board[position.row][position.col]
    }
    
    func selectSquare(at position: ChessPosition) {
        // Don't allow moves while AI is thinking
        guard !isAIThinking else { return }
        
        // Don't allow moves if it's the AI's turn
        guard !ai.isEnabled || currentTurn != aiColor else { return }
        
        // If a piece is already selected, try to move
        if let selected = selectedPosition {
            if validMoves.contains(position) {
                makeMove(from: selected, to: position)
                selectedPosition = nil
                validMoves = []
            } else {
                // Select a new piece if it belongs to the current player
                selectNewPiece(at: position)
            }
        } else {
            // Select a piece
            selectNewPiece(at: position)
        }
    }
    
    private func selectNewPiece(at position: ChessPosition) {
        if let piece = pieceAt(position), piece.color == currentTurn {
            selectedPosition = position
            validMoves = calculateValidMoves(from: position)
        } else {
            selectedPosition = nil
            validMoves = []
        }
    }
    
    func makeMove(from: ChessPosition, to: ChessPosition) {
        guard var piece = pieceAt(from) else { return }
        
        // Safety: Validate positions are in bounds
        guard from.row >= 0 && from.row < 8 && from.col >= 0 && from.col < 8 else {
            print("⚠️ Invalid 'from' position in makeMove")
            return
        }
        guard to.row >= 0 && to.row < 8 && to.col >= 0 && to.col < 8 else {
            print("⚠️ Invalid 'to' position in makeMove")
            return
        }
        
        let capturedPiece = pieceAt(to)
        let move = ChessMove(from: from, to: to, piece: piece, capturedPiece: capturedPiece)
        moveHistory.append(move)
        
        // Track captured pieces
        if let captured = capturedPiece {
            if piece.color == .white {
                capturedByWhite.append(captured)
            } else {
                capturedByBlack.append(captured)
            }
        }
        
        piece.hasMoved = true
        
        // Important: Update destination first (for animation), then clear source
        // This ensures smooth animation even when capturing
        board[to.row][to.col] = piece
        board[from.row][from.col] = nil
        
        // Check for pawn promotion
        if piece.type == .pawn {
            if (piece.color == .white && to.row == 0) || (piece.color == .black && to.row == 7) {
                promotionPosition = to
                promotionColor = piece.color
                showingPawnPromotion = true
                // Don't change turn yet - wait for promotion choice
                return
            }
        }
        
        currentTurn = currentTurn.opposite
        updateGameStatus()
        
        // Trigger AI move if it's the AI's turn and AI is enabled
        // Add safety check: don't trigger if game is over
        if ai.isEnabled && currentTurn == aiColor && gameStatus == .ongoing && !isAIThinking {
            Task {
                await makeAIMove()
            }
        }
    }
    
    func promotePawn(to newType: PieceType) {
        guard let position = promotionPosition,
              let color = promotionColor else { return }
        
        // Replace the pawn with the chosen piece
        board[position.row][position.col] = ChessPiece(type: newType, color: color)
        
        // Reset promotion state
        showingPawnPromotion = false
        promotionPosition = nil
        promotionColor = nil
        
        // Now change turn
        currentTurn = currentTurn.opposite
        updateGameStatus()
        
        // Trigger AI move if it's the AI's turn and AI is enabled
        if ai.isEnabled && currentTurn == aiColor && gameStatus == .ongoing {
            Task {
                await makeAIMove()
            }
        }
    }
    
    /// Make the AI calculate and execute its move
    @MainActor
    func makeAIMove() async {
        // Prevent concurrent AI moves
        guard !isAIThinking else {
            print("⚠️ AI already thinking, skipping move")
            return
        }
        
        // Safety: Ensure it's actually the AI's turn
        guard currentTurn == aiColor else {
            print("⚠️ Not AI's turn, skipping move")
            return
        }
        
        // Safety: Ensure game is still ongoing
        guard gameStatus == .ongoing else {
            print("⚠️ Game is over, skipping AI move")
            return
        }
        
        isAIThinking = true
        
        do {
            if let move = try await ai.calculateBestMove(for: self) {
                // Add smooth delay for better UX (200ms)
                try? await Task.sleep(for: .milliseconds(200))
                
                // Double-check it's still the AI's turn (user might have reset)
                guard currentTurn == aiColor && gameStatus == .ongoing else {
                    isAIThinking = false
                    return
                }
                
                makeMove(from: move.from, to: move.to)
            }
        } catch {
            print("❌ AI error: \(error.localizedDescription)")
        }
        
        isAIThinking = false
    }
    
    func calculateValidMoves(from position: ChessPosition) -> Set<ChessPosition> {
        guard let piece = pieceAt(position) else { return [] }
        
        var moves: Set<ChessPosition> = []
        
        switch piece.type {
        case .pawn:
            moves = calculatePawnMoves(from: position, color: piece.color)
        case .rook:
            moves = calculateRookMoves(from: position, color: piece.color)
        case .knight:
            moves = calculateKnightMoves(from: position, color: piece.color)
        case .bishop:
            moves = calculateBishopMoves(from: position, color: piece.color)
        case .queen:
            moves = calculateQueenMoves(from: position, color: piece.color)
        case .king:
            moves = calculateKingMoves(from: position, color: piece.color)
        }
        
        // Filter out moves that would put own king in check
        return moves.filter { to in
            !wouldMoveExposeKing(from: position, to: to, color: piece.color)
        }
    }
    
    private func calculatePawnMoves(from: ChessPosition, color: PieceColor) -> Set<ChessPosition> {
        var moves: Set<ChessPosition> = []
        let direction = color == .white ? -1 : 1
        let startRow = color == .white ? 6 : 1
        
        // Forward move
        if let forward = from.offset(by: direction, 0), pieceAt(forward) == nil {
            moves.insert(forward)
            
            // Double move from start
            if from.row == startRow, let doubleForward = from.offset(by: direction * 2, 0), pieceAt(doubleForward) == nil {
                moves.insert(doubleForward)
            }
        }
        
        // Captures
        for colOffset in [-1, 1] {
            if let diagonal = from.offset(by: direction, colOffset),
               let targetPiece = pieceAt(diagonal),
               targetPiece.color != color {
                moves.insert(diagonal)
            }
        }
        
        return moves
    }
    
    private func calculateRookMoves(from: ChessPosition, color: PieceColor) -> Set<ChessPosition> {
        var moves: Set<ChessPosition> = []
        let directions = [(1, 0), (-1, 0), (0, 1), (0, -1)]
        
        for (rowDir, colDir) in directions {
            var current = from
            while let next = current.offset(by: rowDir, colDir) {
                if let piece = pieceAt(next) {
                    if piece.color != color {
                        moves.insert(next)
                    }
                    break
                }
                moves.insert(next)
                current = next
            }
        }
        
        return moves
    }
    
    private func calculateKnightMoves(from: ChessPosition, color: PieceColor) -> Set<ChessPosition> {
        var moves: Set<ChessPosition> = []
        let offsets = [(2, 1), (2, -1), (-2, 1), (-2, -1), (1, 2), (1, -2), (-1, 2), (-1, -2)]
        
        for (rowOffset, colOffset) in offsets {
            if let pos = from.offset(by: rowOffset, colOffset) {
                if let piece = pieceAt(pos) {
                    if piece.color != color {
                        moves.insert(pos)
                    }
                } else {
                    moves.insert(pos)
                }
            }
        }
        
        return moves
    }
    
    private func calculateBishopMoves(from: ChessPosition, color: PieceColor) -> Set<ChessPosition> {
        var moves: Set<ChessPosition> = []
        let directions = [(1, 1), (1, -1), (-1, 1), (-1, -1)]
        
        for (rowDir, colDir) in directions {
            var current = from
            while let next = current.offset(by: rowDir, colDir) {
                if let piece = pieceAt(next) {
                    if piece.color != color {
                        moves.insert(next)
                    }
                    break
                }
                moves.insert(next)
                current = next
            }
        }
        
        return moves
    }
    
    private func calculateQueenMoves(from: ChessPosition, color: PieceColor) -> Set<ChessPosition> {
        return calculateRookMoves(from: from, color: color)
            .union(calculateBishopMoves(from: from, color: color))
    }
    
    private func calculateKingMoves(from: ChessPosition, color: PieceColor) -> Set<ChessPosition> {
        var moves: Set<ChessPosition> = []
        let offsets = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)]
        
        for (rowOffset, colOffset) in offsets {
            if let pos = from.offset(by: rowOffset, colOffset) {
                if let piece = pieceAt(pos) {
                    if piece.color != color {
                        moves.insert(pos)
                    }
                } else {
                    moves.insert(pos)
                }
            }
        }
        
        return moves
    }
    
    private func wouldMoveExposeKing(from: ChessPosition, to: ChessPosition, color: PieceColor) -> Bool {
        // Safety: Validate positions are in bounds
        guard from.row >= 0 && from.row < 8 && from.col >= 0 && from.col < 8 else {
            print("⚠️ Warning: Invalid 'from' position in wouldMoveExposeKing")
            return true // Treat as unsafe move
        }
        guard to.row >= 0 && to.row < 8 && to.col >= 0 && to.col < 8 else {
            print("⚠️ Warning: Invalid 'to' position in wouldMoveExposeKing")
            return true // Treat as unsafe move
        }
        
        // Create a temporary board state
        var tempBoard = board
        tempBoard[to.row][to.col] = tempBoard[from.row][from.col]
        tempBoard[from.row][from.col] = nil
        
        // Find the king with additional safety checks
        var kingPosition: ChessPosition?
        for row in 0..<8 {
            for col in 0..<8 {
                guard row >= 0 && row < 8 && col >= 0 && col < 8 else { continue }
                guard let piece = tempBoard[row][col] else { continue }
                if piece.type == .king && piece.color == color {
                    kingPosition = ChessPosition(row: row, col: col)
                    break
                }
            }
            if kingPosition != nil { break }
        }
        
        // Safety: If no king found, assume move is unsafe
        guard let kingPos = kingPosition else { 
            print("⚠️ Critical: King not found when checking move exposure for \(color)")
            return true // Treat as unsafe to prevent illegal moves
        }
        
        // Check if any opponent piece can attack the king
        for row in 0..<8 {
            for col in 0..<8 {
                guard row >= 0 && row < 8 && col >= 0 && col < 8 else { continue }
                guard let pos = ChessPosition(row: row, col: col) else { continue }
                guard let piece = tempBoard[row][col] else { continue }
                if piece.color != color {
                    // Wrap attack check in safety to prevent crashes
                    if canPieceAttack(piece: piece, from: pos, to: kingPos, board: tempBoard) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    private func canPieceAttack(piece: ChessPiece, from: ChessPosition, to: ChessPosition, board: [[ChessPiece?]]) -> Bool {
        // Safety check: positions must be valid
        guard from.row >= 0 && from.row < 8 && from.col >= 0 && from.col < 8 else { return false }
        guard to.row >= 0 && to.row < 8 && to.col >= 0 && to.col < 8 else { return false }
        
        // Can't attack same square
        if from == to { return false }
        
        // Simplified attack check without recursion
        let rowDiff = abs(to.row - from.row)
        let colDiff = abs(to.col - from.col)
        
        switch piece.type {
        case .pawn:
            let direction = piece.color == .white ? -1 : 1
            return to.row == from.row + direction && colDiff == 1
        case .rook:
            return (rowDiff == 0 || colDiff == 0) && isPathClear(from: from, to: to, board: board)
        case .knight:
            return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2)
        case .bishop:
            return rowDiff == colDiff && rowDiff > 0 && isPathClear(from: from, to: to, board: board)
        case .queen:
            return (rowDiff == colDiff || rowDiff == 0 || colDiff == 0) && isPathClear(from: from, to: to, board: board)
        case .king:
            return rowDiff <= 1 && colDiff <= 1
        }
    }
    
    private func isPathClear(from: ChessPosition, to: ChessPosition, board: [[ChessPiece?]]) -> Bool {
        // Safety: Validate board dimensions first
        guard board.count == 8 else {
            print("⚠️ Invalid board dimensions: \(board.count)")
            return false
        }
        
        // Safety: Validate positions are in bounds
        guard from.row >= 0 && from.row < 8 && from.col >= 0 && from.col < 8 else {
            print("⚠️ Invalid 'from' position in isPathClear")
            return false
        }
        guard to.row >= 0 && to.row < 8 && to.col >= 0 && to.col < 8 else {
            print("⚠️ Invalid 'to' position in isPathClear")
            return false
        }
        
        let rowStep = (to.row - from.row).signum()
        let colStep = (to.col - from.col).signum()
        
        // If no movement, path is clear (same square)
        if rowStep == 0 && colStep == 0 {
            return true
        }
        
        let nextRow = from.row + rowStep
        let nextCol = from.col + colStep
        
        // Safety: Validate next position before creating ChessPosition
        guard nextRow >= 0 && nextRow < 8 && nextCol >= 0 && nextCol < 8 else {
            return true // No path to check
        }
        
        guard var current = ChessPosition(row: nextRow, col: nextCol) else {
            return true
        }
        
        // Add safety counter to prevent infinite loops
        var steps = 0
        let maxSteps = 8 // Maximum possible steps on a chess board
        
        while current != to && steps < maxSteps {
            // Check bounds before accessing array
            guard current.row >= 0 && current.row < 8 && current.col >= 0 && current.col < 8 else {
                return false
            }
            
            // Additional safety: check row exists in board
            guard current.row < board.count && board[current.row].count == 8 else {
                print("⚠️ Board structure corrupted at row \(current.row)")
                return false
            }
            
            if board[current.row][current.col] != nil {
                return false
            }
            
            let nextRow = current.row + rowStep
            let nextCol = current.col + colStep
            
            // Safety: Validate next position before creating
            guard nextRow >= 0 && nextRow < 8 && nextCol >= 0 && nextCol < 8 else {
                break
            }
            
            guard let next = ChessPosition(row: nextRow, col: nextCol) else {
                break
            }
            current = next
            steps += 1
        }
        
        return true
    }
    
    func updateGameStatus() {
        // Safety check: ensure current turn is valid
        guard currentTurn == .white || currentTurn == .black else {
            print("⚠️ Warning: Invalid current turn, resetting to .white")
            currentTurn = .white
            gameStatus = .ongoing
            return
        }
        
        // Safety check: ensure both kings exist on the board
        var hasWhiteKing = false
        var hasBlackKing = false
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col], piece.type == .king {
                    if piece.color == .white {
                        hasWhiteKing = true
                    } else if piece.color == .black {
                        hasBlackKing = true
                    }
                }
            }
        }
        
        if !hasWhiteKing || !hasBlackKing {
            print("⚠️ Warning: Missing king(s) - White: \(hasWhiteKing), Black: \(hasBlackKing)")
            gameStatus = .ongoing
            return
        }
        
        // Now proceed with normal check/checkmate detection with safeguards
        let inCheck = safeIsKingInCheck(color: currentTurn)
        let noMoves = safeHasNoValidMoves(color: currentTurn)
        
        if inCheck {
            if noMoves {
                gameStatus = .checkmate(winner: currentTurn.opposite)
                print("🏁 Checkmate! \(currentTurn.opposite) wins!")
            } else {
                gameStatus = .check(currentTurn)
                print("⚠️ \(currentTurn) is in check!")
            }
        } else if noMoves {
            gameStatus = .stalemate
            print("🤝 Stalemate!")
        } else {
            gameStatus = .ongoing
        }
    }
    
    /// Safe wrapper for isKingInCheck that catches any issues
    private func safeIsKingInCheck(color: PieceColor) -> Bool {
        // Wrap in autoreleasepool to prevent memory issues
        return autoreleasepool {
            guard color == .white || color == .black else {
                print("⚠️ Invalid color in safeIsKingInCheck")
                return false
            }
            return isKingInCheck(color: color)
        }
    }
    
    /// Safe wrapper for hasNoValidMoves that catches any issues
    private func safeHasNoValidMoves(color: PieceColor) -> Bool {
        return autoreleasepool {
            guard color == .white || color == .black else {
                print("⚠️ Invalid color in safeHasNoValidMoves")
                return true
            }
            return hasNoValidMoves(color: color)
        }
    }
    
    private func isKingInCheck(color: PieceColor) -> Bool {
        // Find king position with bounds checking
        var kingPosition: ChessPosition?
        for row in 0..<8 {
            for col in 0..<8 {
                // Validate row and col are in valid range
                guard row >= 0 && row < 8 && col >= 0 && col < 8 else { continue }
                guard let pos = ChessPosition(row: row, col: col) else { continue }
                guard let piece = pieceAt(pos) else { continue }
                if piece.type == .king && piece.color == color {
                    kingPosition = pos
                    break
                }
            }
            if kingPosition != nil { break } // Exit outer loop once king is found
        }
        
        // Safety: If no king found, return false (shouldn't happen in valid game)
        guard let kingPos = kingPosition else { 
            print("⚠️ Critical: King not found for \(color) - cannot determine check status")
            return false 
        }
        
        // Check if any opponent piece can attack the king with additional safety
        for row in 0..<8 {
            for col in 0..<8 {
                guard row >= 0 && row < 8 && col >= 0 && col < 8 else { continue }
                guard let pos = ChessPosition(row: row, col: col) else { continue }
                guard let piece = pieceAt(pos) else { continue }
                if piece.color != color {
                    // Wrap in safety check to prevent crashes
                    do {
                        if canPieceAttack(piece: piece, from: pos, to: kingPos, board: board) {
                            return true
                        }
                    } catch {
                        print("⚠️ Error checking piece attack: \(error)")
                        continue
                    }
                }
            }
        }
        
        return false
    }
    
    private func hasNoValidMoves(color: PieceColor) -> Bool {
        // Safety: Add bounds checking and early exit
        guard color == .white || color == .black else { return true }
        
        for row in 0..<8 {
            for col in 0..<8 {
                // Bounds check
                guard row >= 0 && row < 8 && col >= 0 && col < 8 else { continue }
                guard let pos = ChessPosition(row: row, col: col) else { continue }
                
                // Check if piece exists and matches color
                guard let piece = pieceAt(pos), piece.color == color else { continue }
                
                // Calculate valid moves with safety wrapper
                let validMoves = calculateValidMoves(from: pos)
                if !validMoves.isEmpty {
                    return false
                }
            }
        }
        return true
    }
    
    func resetGame() {
        board = ChessGame.createInitialBoard()
        currentTurn = .white
        selectedPosition = nil
        validMoves = []
        gameStatus = .ongoing
        moveHistory = []
        capturedByWhite = []
        capturedByBlack = []
        isAIThinking = false
        
        // Reset pawn promotion state
        showingPawnPromotion = false
        promotionPosition = nil
        promotionColor = nil
        
        // If AI is enabled and plays white, trigger first move
        if ai.isEnabled && aiColor == .white {
            Task {
                await makeAIMove()
            }
        }
    }
    
    /// Create a deep copy of the current game state for AI simulation
    func copy() -> ChessGame {
        let newGame = ChessGame()
        
        // Safety: Copy board state with bounds checking
        for row in 0..<8 {
            for col in 0..<8 {
                guard row >= 0 && row < 8 && col >= 0 && col < 8 else { continue }
                newGame.board[row][col] = self.board[row][col]
            }
        }
        
        // Copy game state
        newGame.currentTurn = self.currentTurn
        newGame.gameStatus = self.gameStatus
        newGame.capturedByWhite = self.capturedByWhite
        newGame.capturedByBlack = self.capturedByBlack
        
        // Don't copy UI-related state (selectedPosition, validMoves, etc.)
        // Don't copy AI reference to avoid recursion
        // Don't copy isAIThinking to prevent blocking
        
        return newGame
    }
    
    /// Toggle AI opponent on/off
    func toggleAI(enabled: Bool, color: PieceColor = .black, difficulty: ChessAI.Difficulty = .medium) {
        ai.isEnabled = enabled
        aiColor = color
        ai.difficulty = difficulty
        
        // If enabling AI and it's currently AI's turn, make a move
        if enabled && currentTurn == aiColor && gameStatus == .ongoing {
            Task {
                await makeAIMove()
            }
        }
    }
}

// MARK: - Preview Support

#Preview("Chess Game - Initial Position") {
    ContentView()
}

#Preview("Chess Game - Mid Game", traits: .sizeThatFitsLayout) {
    let game = ChessGame()
    
    // Set up a mid-game scenario
    game.board = Array(repeating: Array(repeating: Optional<ChessPiece>.none, count: 8), count: 8)
    
    // Add some pieces for an interesting mid-game position
    game.board[0][4] = ChessPiece(type: .king, color: .black)
    game.board[0][0] = ChessPiece(type: .rook, color: .black)
    game.board[1][3] = ChessPiece(type: .pawn, color: .black)
    game.board[1][4] = ChessPiece(type: .pawn, color: .black)
    game.board[1][5] = ChessPiece(type: .pawn, color: .black)
    game.board[3][3] = ChessPiece(type: .queen, color: .black)
    
    game.board[7][4] = ChessPiece(type: .king, color: .white)
    game.board[7][7] = ChessPiece(type: .rook, color: .white)
    game.board[6][3] = ChessPiece(type: .pawn, color: .white)
    game.board[6][4] = ChessPiece(type: .pawn, color: .white)
    game.board[6][5] = ChessPiece(type: .pawn, color: .white)
    game.board[4][4] = ChessPiece(type: .queen, color: .white)
    game.board[5][2] = ChessPiece(type: .bishop, color: .white)
    
    return ChessBoardView(game: game)
        .padding()
        .frame(width: 400, height: 400)
}

#Preview("Chess Game - Check Scenario", traits: .sizeThatFitsLayout) {
    let game = ChessGame()
    
    // Set up a check scenario
    game.board = Array(repeating: Array(repeating: Optional<ChessPiece>.none, count: 8), count: 8)
    
    game.board[0][4] = ChessPiece(type: .king, color: .black)
    game.board[3][4] = ChessPiece(type: .rook, color: .white)
    game.board[7][4] = ChessPiece(type: .king, color: .white)
    
    game.currentTurn = .black
    game.updateGameStatus()
    
    return VStack {
        Text("Check!")
            .font(.title)
            .foregroundStyle(.red)
        ChessBoardView(game: game)
            .padding()
    }
    .frame(width: 450, height: 500)
}

#Preview("Full App - Light Mode") {
    ContentView()
        .preferredColorScheme(.light)
}

#Preview("Full App - Dark Mode") {
    ContentView()
        .preferredColorScheme(.dark)
}
