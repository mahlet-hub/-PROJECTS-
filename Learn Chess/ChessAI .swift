//
//  ChessAI 2.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation

/// High-performance AI opponent with iterative deepening, killer moves, and advanced pruning
@Observable
class AdvancedChessAI {
    enum Difficulty {
        case easy
        case medium
        case hard
        case expert
        
        var searchDepth: Int {
            switch self {
            case .easy: return 1        // Looks ahead 1 move (beginner)
            case .medium: return 2      // Looks ahead 2 moves (intermediate)
            case .hard: return 3        // Looks ahead 3 moves (advanced)
            case .expert: return 5      // Looks ahead 5 moves (expert)
            }
        }
        
        var randomnessFactor: Double {
            switch self {
            case .easy: return 0.3      // 30% chance of suboptimal move
            case .medium: return 0.1    // 10% chance of suboptimal move
            case .hard: return 0.0      // Always optimal
            case .expert: return 0.0    // Always optimal
            }
        }
        
        var useIterativeDeepening: Bool {
            switch self {
            case .easy: return false
            case .medium: return true
            case .hard: return true
            case .expert: return true
            }
        }
    }
    
    var difficulty: Difficulty = .medium
    var isEnabled: Bool = false
    
    // Performance tracking
    private var nodesSearched = 0
    private var cacheHits = 0
    private var searchStartTime = Date()
    private var maxSearchTime: TimeInterval = 3.0 // Max 3 seconds per move
    
    // Transposition table for memoization
    private var transpositionTable: [Int: TranspositionEntry] = [:]
    private let maxCacheSize = 100000
    
    // Killer moves heuristic (moves that caused beta cutoffs)
    private var killerMoves: [[KillerMove]] = Array(repeating: [], count: 20)
    
    // History heuristic (track successful moves)
    private var historyTable: [Int: Int] = [:]
    
    struct TranspositionEntry {
        let score: Int
        let depth: Int
        let flag: NodeType
        let bestMove: (from: ChessPosition, to: ChessPosition)?
        
        enum NodeType {
            case exact
            case lowerBound
            case upperBound
        }
    }
    
    struct KillerMove: Equatable {
        let from: ChessPosition
        let to: ChessPosition
    }
    
    // Piece values (centipawns)
    private let pieceValues: [PieceType: Int] = [
        .pawn: 100,
        .knight: 320,
        .bishop: 330,
        .rook: 500,
        .queen: 900,
        .king: 20000
    ]
    
    // Piece-square tables
    private let pawnTable: [[Int]] = [
        [0,   0,   0,   0,   0,   0,   0,   0],
        [50,  50,  50,  50,  50,  50,  50,  50],
        [10,  10,  20,  30,  30,  20,  10,  10],
        [5,   5,   10,  27,  27,  10,  5,   5],
        [0,   0,   0,   25,  25,  0,   0,   0],
        [5,  -5,  -10,  0,   0,  -10, -5,   5],
        [5,   10,  10, -25, -25,  10,  10,  5],
        [0,   0,   0,   0,   0,   0,   0,   0]
    ]
    
    private let knightTable: [[Int]] = [
        [-50, -40, -30, -30, -30, -30, -40, -50],
        [-40, -20,  0,   0,   0,   0,  -20, -40],
        [-30,  0,   10,  15,  15,  10,  0,  -30],
        [-30,  5,   15,  20,  20,  15,  5,  -30],
        [-30,  0,   15,  20,  20,  15,  0,  -30],
        [-30,  5,   10,  15,  15,  10,  5,  -30],
        [-40, -20,  0,   5,   5,   0,  -20, -40],
        [-50, -40, -30, -30, -30, -30, -40, -50]
    ]
    
    private let bishopTable: [[Int]] = [
        [-20, -10, -10, -10, -10, -10, -10, -20],
        [-10,  0,   0,   0,   0,   0,   0,  -10],
        [-10,  0,   5,   10,  10,  5,   0,  -10],
        [-10,  5,   5,   10,  10,  5,   5,  -10],
        [-10,  0,   10,  10,  10,  10,  0,  -10],
        [-10,  10,  10,  10,  10,  10,  10, -10],
        [-10,  5,   0,   0,   0,   0,   5,  -10],
        [-20, -10, -10, -10, -10, -10, -10, -20]
    ]
    
    private let rookTable: [[Int]] = [
        [0,   0,   0,   0,   0,   0,   0,   0],
        [5,   10,  10,  10,  10,  10,  10,  5],
        [-5,  0,   0,   0,   0,   0,   0,  -5],
        [-5,  0,   0,   0,   0,   0,   0,  -5],
        [-5,  0,   0,   0,   0,   0,   0,  -5],
        [-5,  0,   0,   0,   0,   0,   0,  -5],
        [-5,  0,   0,   0,   0,   0,   0,  -5],
        [0,   0,   0,   5,   5,   0,   0,   0]
    ]
    
    private let queenTable: [[Int]] = [
        [-20, -10, -10, -5,  -5,  -10, -10, -20],
        [-10,  0,   0,   0,   0,   0,   0,  -10],
        [-10,  0,   5,   5,   5,   5,   0,  -10],
        [-5,   0,   5,   5,   5,   5,   0,  -5],
        [0,    0,   5,   5,   5,   5,   0,  -5],
        [-10,  5,   5,   5,   5,   5,   0,  -10],
        [-10,  0,   5,   0,   0,   0,   0,  -10],
        [-20, -10, -10, -5,  -5,  -10, -10, -20]
    ]
    
    private let kingMiddlegameTable: [[Int]] = [
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-30, -40, -40, -50, -50, -40, -40, -30],
        [-20, -30, -30, -40, -40, -30, -30, -20],
        [-10, -20, -20, -20, -20, -20, -20, -10],
        [20,   20,  0,   0,   0,   0,   20,  20],
        [20,   30,  10,  0,   0,   10,  30,  20]
    ]
    
    private let kingEndgameTable: [[Int]] = [
        [-50, -40, -30, -20, -20, -30, -40, -50],
        [-30, -20, -10,  0,   0,  -10, -20, -30],
        [-30, -10,  20,  30,  30,  20, -10, -30],
        [-30, -10,  30,  40,  40,  30, -10, -30],
        [-30, -10,  30,  40,  40,  30, -10, -30],
        [-30, -10,  20,  30,  30,  20, -10, -30],
        [-30, -30,  0,   0,   0,   0,  -30, -30],
        [-50, -30, -30, -30, -30, -30, -30, -50]
    ]
    
    var isAvailable: Bool { true }
    var availabilityMessage: String { "AI Ready" }
    
    /// Quick opening book for faster early game moves
    private func selectOpeningMove(for game: ChessGame, validMoves: [(from: ChessPosition, to: ChessPosition)]) -> (from: ChessPosition, to: ChessPosition)? {
        let moveCount = game.moveHistory.count
        
        // First move as white: prioritize center control
        if moveCount == 0 {
            // e4 or d4 for white
            if let e2 = ChessPosition(row: 6, col: 4), let e4 = ChessPosition(row: 4, col: 4),
               validMoves.contains(where: { $0.from == e2 && $0.to == e4 }) {
                return (e2, e4)
            }
            if let d2 = ChessPosition(row: 6, col: 3), let d4 = ChessPosition(row: 4, col: 3),
               validMoves.contains(where: { $0.from == d2 && $0.to == d4 }) {
                return (d2, d4)
            }
        }
        
        // Black's response
        if moveCount == 1 {
            // e5 or d5 for black
            if let e7 = ChessPosition(row: 1, col: 4), let e5 = ChessPosition(row: 3, col: 4),
               validMoves.contains(where: { $0.from == e7 && $0.to == e5 }) {
                return (e7, e5)
            }
            if let d7 = ChessPosition(row: 1, col: 3), let d5 = ChessPosition(row: 3, col: 3),
               validMoves.contains(where: { $0.from == d7 && $0.to == d5 }) {
                return (d7, d5)
            }
        }
        
        // Develop knights early (moves 2-5)
        if moveCount >= 2 && moveCount <= 5 {
            for move in validMoves {
                if game.pieceAt(move.from)?.type == .knight {
                    // Move knights toward center (f3, c3 for white, f6, c6 for black)
                    if (3...4).contains(move.to.row) && (2...5).contains(move.to.col) {
                        return move
                    }
                }
            }
        }
        
        // Develop bishops (moves 3-7)
        if moveCount >= 3 && moveCount <= 7 {
            for move in validMoves {
                if game.pieceAt(move.from)?.type == .bishop {
                    // Move bishops to good diagonals
                    if (3...4).contains(move.to.row) {
                        return move
                    }
                }
            }
        }
        
        // Castle if available (moves 4-8)
        if moveCount >= 4 && moveCount <= 8 {
            for move in validMoves {
                // Detect castling (king moves 2 squares)
                if game.pieceAt(move.from)?.type == .king &&
                   abs(move.to.col - move.from.col) == 2 {
                    return move
                }
            }
        }
        
        // General good moves: center pawns, piece development
        if moveCount < 10 {
            // Prefer moves to center squares
            let centerMoves = validMoves.filter { move in
                (3...4).contains(move.to.row) && (3...4).contains(move.to.col)
            }
            if !centerMoves.isEmpty {
                return centerMoves.randomElement()
            }
        }
        
        return nil
    }
    
    /// Calculate best move with iterative deepening
    func calculateBestMove(for game: ChessGame) async throws -> (from: ChessPosition, to: ChessPosition)? {
        // Reset counters
        nodesSearched = 0
        cacheHits = 0
        searchStartTime = Date()
        
        // Set time limit based on difficulty (more aggressive)
        maxSearchTime = difficulty == .easy ? 0.5 : (difficulty == .medium ? 1.0 : 2.0)
        
        // Clear killer moves for new search
        killerMoves = Array(repeating: [], count: 20)
        
        // Clear history table periodically to prevent slowdown
        if historyTable.count > 5000 {
            historyTable.removeAll(keepingCapacity: true)
        }
        
        // Aggressively clean transposition table
        if transpositionTable.count > maxCacheSize / 2 {
            transpositionTable.removeAll(keepingCapacity: true)
        }
        
        let validMoves = getAllValidMoves(for: game)
        guard !validMoves.isEmpty else { return nil }
        
        // Easy mode randomness
        if difficulty == .easy && Double.random(in: 0...1) < difficulty.randomnessFactor {
            print("🧠 AI used random move")
            return validMoves.randomElement()
        }
        
        // Extended opening book (first 10 moves)
        if game.moveHistory.count < 10 {
            if let openingMove = selectOpeningMove(for: game, validMoves: validMoves) {
                print("🧠 AI used opening book (instant)")
                return openingMove
            }
        }
        
        return await Task.detached(priority: .userInitiated) { [self] in
            let startTime = Date()
            var bestMove: (from: ChessPosition, to: ChessPosition)?
            
            if self.difficulty.useIterativeDeepening {
                // Iterative deepening for better move ordering and faster search
                bestMove = self.iterativeDeepening(game: game, maxDepth: self.difficulty.searchDepth)
            } else {
                // Simple search for easy mode
                bestMove = self.searchBestMove(game: game, depth: self.difficulty.searchDepth)
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            print("🧠 AI searched \(self.nodesSearched) nodes, \(self.cacheHits) cache hits in \(String(format: "%.2f", elapsed))s")
            return bestMove ?? validMoves.randomElement()
        }.value
    }
    
    /// Iterative deepening search
    private func iterativeDeepening(game: ChessGame, maxDepth: Int) -> (from: ChessPosition, to: ChessPosition)? {
        var bestMove: (from: ChessPosition, to: ChessPosition)?
        
        // Search with increasing depth, but stop if time runs out
        for depth in 1...maxDepth {
            // Check if we're running out of time
            if Date().timeIntervalSince(searchStartTime) > maxSearchTime * 0.8 {
                print("🧠 Iterative deepening stopped at depth \(depth - 1)")
                break
            }
            
            let result = searchBestMove(game: game, depth: depth)
            if let move = result {
                bestMove = move
            }
        }
        
        return bestMove
    }
    
    /// Search for best move at given depth
    private func searchBestMove(game: ChessGame, depth: Int) -> (from: ChessPosition, to: ChessPosition)? {
        var bestMove: (from: ChessPosition, to: ChessPosition)?
        var bestScore = -100000
        var alpha = -100000
        let beta = 100000
        
        let moves = getAllValidMoves(for: game)
        let orderedMoves = orderMoves(moves, for: game, depth: depth)
        
        for move in orderedMoves {
            let testGame = game.copy()
            testGame.makeMove(from: move.from, to: move.to)
            
            let score = -negamax(
                game: testGame,
                depth: depth - 1,
                alpha: -beta,
                beta: -alpha,
                color: -1
            )
            
            if score > bestScore {
                bestScore = score
                bestMove = move
                alpha = max(alpha, score)
            }
        }
        
        return bestMove
    }
    
    /// Negamax with alpha-beta pruning (cleaner than minimax)
    private func negamax(game: ChessGame, depth: Int, alpha: Int, beta: Int, color: Int) -> Int {
        nodesSearched += 1
        
        // Time check more frequently - abort search if taking too long
        if nodesSearched % 500 == 0 && Date().timeIntervalSince(searchStartTime) > maxSearchTime {
            return 0
        }
        
        // Check transposition table
        let boardHash = hashBoard(game: game)
        if let entry = transpositionTable[boardHash], entry.depth >= depth {
            cacheHits += 1
            switch entry.flag {
            case .exact:
                return entry.score
            case .lowerBound where entry.score >= beta:
                return entry.score
            case .upperBound where entry.score <= alpha:
                return entry.score
            default:
                break
            }
        }
        
        // Terminal node
        if depth == 0 {
            return quiescence(game: game, alpha: alpha, beta: beta, color: color, depth: 0)
        }
        
        // Check for game over
        if game.gameStatus != .ongoing {
            return evaluateTerminal(game: game, color: color)
        }
        
        var alpha = alpha
        var beta = beta
        let moves = getAllValidMoves(for: game)
        
        if moves.isEmpty {
            return evaluateTerminal(game: game, color: color)
        }
        
        // Order moves for better pruning
        let orderedMoves = orderMoves(moves, for: game, depth: depth)
        
        var bestScore = -100000
        var bestMove: (from: ChessPosition, to: ChessPosition)?
        
        for move in orderedMoves {
            let testGame = game.copy()
            testGame.makeMove(from: move.from, to: move.to)
            
            let score = -negamax(
                game: testGame,
                depth: depth - 1,
                alpha: -beta,
                beta: -alpha,
                color: -color
            )
            
            if score > bestScore {
                bestScore = score
                bestMove = move
            }
            
            alpha = max(alpha, score)
            
            if alpha >= beta {
                // Beta cutoff - store killer move
                storeKillerMove(move, depth: depth)
                updateHistory(move, depth: depth)
                break
            }
        }
        
        // Store in transposition table
        let flag: TranspositionEntry.NodeType = bestScore <= alpha ? .upperBound : (bestScore >= beta ? .lowerBound : .exact)
        transpositionTable[boardHash] = TranspositionEntry(
            score: bestScore,
            depth: depth,
            flag: flag,
            bestMove: bestMove
        )
        
        return bestScore
    }
    
    /// Quiescence search (search captures until quiet)
    private func quiescence(game: ChessGame, alpha: Int, beta: Int, color: Int, depth: Int) -> Int {
        nodesSearched += 1
        
        let standPat = color * evaluatePosition(game: game)
        
        if standPat >= beta {
            return beta
        }
        
        var alpha = max(alpha, standPat)
        
        // Limit quiescence depth to 2 for speed
        if depth > 2 {
            return alpha
        }
        
        // Only search captures
        let captures = getAllValidMoves(for: game).filter { move in
            game.pieceAt(move.to) != nil
        }
        
        if captures.isEmpty {
            return alpha
        }
        
        // Order captures by MVV-LVA (only evaluate top 5 captures)
        let orderedCaptures = captures.sorted { move1, move2 in
            let victim1Value = pieceValues[game.pieceAt(move1.to)?.type ?? .pawn] ?? 0
            let victim2Value = pieceValues[game.pieceAt(move2.to)?.type ?? .pawn] ?? 0
            return victim1Value > victim2Value
        }.prefix(5)
        
        for move in orderedCaptures {
            let testGame = game.copy()
            testGame.makeMove(from: move.from, to: move.to)
            
            let score = -quiescence(
                game: testGame,
                alpha: -beta,
                beta: -alpha,
                color: -color,
                depth: depth + 1
            )
            
            alpha = max(alpha, score)
            
            if alpha >= beta {
                break
            }
        }
        
        return alpha
    }
    
    /// Advanced move ordering
    private func orderMoves(_ moves: [(from: ChessPosition, to: ChessPosition)], for game: ChessGame, depth: Int) -> [(from: ChessPosition, to: ChessPosition)] {
        return moves.sorted { move1, move2 in
            scoreMoveForOrdering(move1, game: game, depth: depth) > scoreMoveForOrdering(move2, game: game, depth: depth)
        }
    }
    
    /// Score move for ordering
    private func scoreMoveForOrdering(_ move: (from: ChessPosition, to: ChessPosition), game: ChessGame, depth: Int) -> Int {
        var score = 0
        
        // 1. Hash move from transposition table
        let boardHash = hashBoard(game: game)
        if let entry = transpositionTable[boardHash],
           let bestMove = entry.bestMove,
           bestMove.from == move.from && bestMove.to == move.to {
            score += 10000
        }
        
        // 2. MVV-LVA (Most Valuable Victim - Least Valuable Attacker)
        if let capturedPiece = game.pieceAt(move.to) {
            let victimValue = pieceValues[capturedPiece.type] ?? 0
            let attackerValue = pieceValues[game.pieceAt(move.from)?.type ?? .pawn] ?? 0
            score += 100 * victimValue - attackerValue
        }
        
        // 3. Killer moves
        if depth < killerMoves.count {
            if killerMoves[depth].contains(where: { $0.from == move.from && $0.to == move.to }) {
                score += 5000
            }
        }
        
        // 4. History heuristic
        let moveHash = hashMove(move)
        score += historyTable[moveHash] ?? 0
        
        // 5. Center control
        if (3...4).contains(move.to.row) && (3...4).contains(move.to.col) {
            score += 50
        }
        
        return score
    }
    
    /// Store killer move
    private func storeKillerMove(_ move: (from: ChessPosition, to: ChessPosition), depth: Int) {
        guard depth < killerMoves.count else { return }
        
        let killer = KillerMove(from: move.from, to: move.to)
        if !killerMoves[depth].contains(killer) {
            killerMoves[depth].insert(killer, at: 0)
            if killerMoves[depth].count > 2 {
                killerMoves[depth].removeLast()
            }
        }
    }
    
    /// Update history table
    private func updateHistory(_ move: (from: ChessPosition, to: ChessPosition), depth: Int) {
        let moveHash = hashMove(move)
        historyTable[moveHash, default: 0] += depth * depth
    }
    
    /// Hash move for history table
    private func hashMove(_ move: (from: ChessPosition, to: ChessPosition)) -> Int {
        return (move.from.row * 1000 + move.from.col * 100 + move.to.row * 10 + move.to.col)
    }
    
    /// Fast board hashing
    private func hashBoard(game: ChessGame) -> Int {
        var hash = 0
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = game.board[row][col] {
                    let pieceValue = piece.type.hashValue & 0xFF // Limit to 8 bits
                    let colorValue = piece.color == .white ? 1 : 2
                    // Use bitwise operations to avoid overflow
                    let contribution = (row << 12) | (col << 9) | (pieceValue << 2) | colorValue
                    hash = hash ^ contribution // XOR instead of multiply to avoid overflow
                }
            }
        }
        hash = hash ^ (game.currentTurn == .white ? 1 : 0)
        return hash
    }
    
    /// Evaluate terminal position
    private func evaluateTerminal(game: ChessGame, color: Int) -> Int {
        if case .checkmate(let winner) = game.gameStatus {
            if (winner == .black && game.currentTurn == .black) || (winner == .white && game.currentTurn == .white) {
                return -50000
            } else {
                return 50000
            }
        }
        return 0 // Stalemate
    }
    
    /// Comprehensive position evaluation
    private func evaluatePosition(game: ChessGame) -> Int {
        var score = 0
        
        // Material and position
        for row in 0..<8 {
            for col in 0..<8 {
                guard let piece = game.board[row][col] else { continue }
                
                var pieceScore = pieceValues[piece.type] ?? 0
                
                // Only use piece-square tables for medium+ difficulty
                if difficulty != .easy {
                    pieceScore += getPieceSquareValue(piece: piece, row: row, col: col, game: game)
                }
                
                if piece.color == .black {
                    score += pieceScore
                } else {
                    score -= pieceScore
                }
            }
        }
        
        // Skip mobility for easy mode
        if difficulty == .hard || difficulty == .expert {
            let mobilityBonus = min(getAllValidMoves(for: game).count, 20)
            if game.currentTurn == .black {
                score += mobilityBonus * 3
            } else {
                score -= mobilityBonus * 3
            }
        }
        
        return score
    }
    
    /// Get piece-square table value
    private func getPieceSquareValue(piece: ChessPiece, row: Int, col: Int, game: ChessGame) -> Int {
        let adjustedRow = piece.color == .white ? 7 - row : row
        
        switch piece.type {
        case .pawn:
            return pawnTable[adjustedRow][col]
        case .knight:
            return knightTable[adjustedRow][col]
        case .bishop:
            return bishopTable[adjustedRow][col]
        case .rook:
            return rookTable[adjustedRow][col]
        case .queen:
            return queenTable[adjustedRow][col]
        case .king:
            // Count material to determine phase
            var totalMaterial = 0
            for r in 0..<8 {
                for c in 0..<8 {
                    if let p = game.board[r][c], p.type != .king {
                        totalMaterial += pieceValues[p.type] ?? 0
                    }
                }
            }
            let isEndgame = totalMaterial < 2500
            return isEndgame ? kingEndgameTable[adjustedRow][col] : kingMiddlegameTable[adjustedRow][col]
        }
    }
    
    /// Get all valid moves
    private func getAllValidMoves(for game: ChessGame) -> [(from: ChessPosition, to: ChessPosition)] {
        var moves: [(from: ChessPosition, to: ChessPosition)] = []
        
        for row in 0..<8 {
            for col in 0..<8 {
                guard let position = ChessPosition(row: row, col: col),
                      let piece = game.pieceAt(position),
                      piece.color == game.currentTurn else {
                    continue
                }
                
                let destinations = game.calculateValidMoves(from: position)
                for destination in destinations {
                    moves.append((from: position, to: destination))
                }
            }
        }
        
        return moves
    }
    
    enum AIError: LocalizedError {
        case modelUnavailable
        case noValidMoves
        
        var errorDescription: String? {
            switch self {
            case .modelUnavailable:
                return "AI model is not available"
            case .noValidMoves:
                return "No valid moves available"
            }
        }
    }
}

// Type alias for compatibility with existing code
typealias ChessAI = AdvancedChessAI
