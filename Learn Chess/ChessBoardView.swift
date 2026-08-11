//
//  ChessBoardView.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import SwiftUI
import UniformTypeIdentifiers

struct ChessBoardView: View {
    @Bindable var game: ChessGame
    @State private var animatingPiece: AnimatingPiece?
    @State private var animationProgress: CGFloat = 0
    
    var body: some View {
        GeometryReader { geometry in
            let squareSize = geometry.size.width / 8
            
            boardContent(squareSize: squareSize)
        }
        .aspectRatio(1, contentMode: .fit)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(Color.gray.opacity(0.3), lineWidth: 2)
        )
        .onChange(of: game.moveHistory.count) { oldValue, newValue in
            if let lastMove = game.moveHistory.last {
                animateMove(from: lastMove.from, to: lastMove.to, piece: lastMove.piece, capturedPiece: lastMove.capturedPiece)
            }
        }
    }
    
    @ViewBuilder
    private func boardContent(squareSize: CGFloat) -> some View {
        ZStack {
            // Board squares
            boardSquares(squareSize: squareSize)
            
            // Animating piece overlay
            if let animating = animatingPiece {
                animatingPieceView(animating: animating, squareSize: squareSize)
            }
        }
    }
    
    @ViewBuilder
    private func boardSquares(squareSize: CGFloat) -> some View {
        VStack(spacing: 0) {
            ForEach(0..<8, id: \.self) { row in
                HStack(spacing: 0) {
                    ForEach(0..<8, id: \.self) { col in
                        squareView(row: row, col: col, squareSize: squareSize)
                    }
                }
            }
        }
    }
    
    @ViewBuilder
    private func squareView(row: Int, col: Int, squareSize: CGFloat) -> some View {
        if let position = ChessPosition(row: row, col: col) {
            let pieceToShow = getPieceToShow(at: position)
            let isSelected = game.selectedPosition == position
            let isValidMove = game.validMoves.contains(position)
            let isLightSquare = (row + col) % 2 == 0
            
            ChessSquareView(
                position: position,
                piece: pieceToShow,
                isSelected: isSelected,
                isValidMove: isValidMove,
                isLightSquare: isLightSquare,
                squareSize: squareSize,
                game: game
            )
            .frame(width: squareSize, height: squareSize)
            .onTapGesture {
                handleSquareTap(at: position, squareSize: squareSize)
            }
        } else {
            // Fallback for invalid positions (should never happen in normal chess)
            Color.clear
                .frame(width: squareSize, height: squareSize)
        }
    }
    
    private func getPieceToShow(at position: ChessPosition) -> ChessPiece? {
        // Determine which piece to show
        var pieceToShow = game.pieceAt(position)
        
        // If animating, show the captured piece at the destination until animation completes
        if let animating = animatingPiece {
            if position == animating.from {
                pieceToShow = nil // Hide source piece during animation
            } else if position == animating.to && animating.capturedPiece != nil {
                pieceToShow = animating.capturedPiece // Show captured piece until moving piece arrives
            }
        }
        
        return pieceToShow
    }
    
    @ViewBuilder
    private func animatingPieceView(animating: AnimatingPiece, squareSize: CGFloat) -> some View {
        // Size pieces based on type - pawns smaller, other pieces bigger
        let pieceSize = animating.piece.type == .pawn ? squareSize * 0.5 : squareSize * 0.7
        
        // Calculate offset distances
        let deltaX = CGFloat(animating.to.col - animating.from.col) * squareSize
        let deltaY = CGFloat(animating.to.row - animating.from.row) * squareSize
        
        // Use the same rendering as the square pieces for consistency
        Group {
            if animating.piece.color == .white {
                Text(animating.piece.symbol)
                    .font(.system(size: pieceSize))
                    .foregroundStyle(Color.black)
                    .colorInvert()
            } else {
                Text(animating.piece.symbol)
                    .font(.system(size: pieceSize))
                    .foregroundStyle(Color.black)
            }
        }
        .frame(width: squareSize, height: squareSize)
        .background(Color.clear)
        .position(
            x: CGFloat(animating.from.col) * squareSize + squareSize / 2,
            y: CGFloat(animating.from.row) * squareSize + squareSize / 2
        )
        .offset(x: deltaX * animationProgress, y: deltaY * animationProgress)
        .animation(.smooth(duration: 0.35, extraBounce: 0), value: animationProgress)
        .drawingGroup(opaque: false, colorMode: .nonLinear)
        .zIndex(100)
    }
    
    private func handleSquareTap(at position: ChessPosition, squareSize: CGFloat) {
        game.selectSquare(at: position)
    }
    
    private func animateMove(from: ChessPosition, to: ChessPosition, piece: ChessPiece, capturedPiece: ChessPiece?) {
        // If animation is already in progress, cancel it immediately
        if animatingPiece != nil {
            animatingPiece = nil
            animationProgress = 0
        }
        
        // Start new animation at 0 progress
        animationProgress = 0
        
        animatingPiece = AnimatingPiece(
            piece: piece,
            from: from,
            to: to,
            capturedPiece: capturedPiece
        )
        
        // Trigger animation by changing progress value with smooth timing
        withAnimation(.smooth(duration: 0.35, extraBounce: 0)) {
            animationProgress = 1.0
        }
        
        // Clear the animating piece after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            // Only clear if this is still the same animation
            if self.animatingPiece?.from == from && self.animatingPiece?.to == to {
                animatingPiece = nil
                animationProgress = 0
            }
        }
    }
}

struct AnimatingPiece {
    let piece: ChessPiece
    let from: ChessPosition
    let to: ChessPosition
    let capturedPiece: ChessPiece? // Store the captured piece to show it during animation
}

struct ChessSquareView: View {
    let position: ChessPosition
    let piece: ChessPiece?
    let isSelected: Bool
    let isValidMove: Bool
    let isLightSquare: Bool
    let squareSize: CGFloat
    @State private var isDragging = false
    var game: ChessGame
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill(squareColor)
            
            if let piece = piece, !isDragging {
                Group {
                    if piece.color == .white {
                        Text(piece.symbol)
                            .font(.system(size: piece.type == .pawn ? squareSize * 0.5 : squareSize * 0.7))
                            .foregroundStyle(Color.black)
                            .colorInvert()
                    } else {
                        Text(piece.symbol)
                            .font(.system(size: piece.type == .pawn ? squareSize * 0.5 : squareSize * 0.7))
                            .foregroundStyle(Color.black)
                    }
                }
                .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                .onDrag {
                    isDragging = true
                    return NSItemProvider(object: "\(position.row),\(position.col)" as NSString)
                }
            }
            
            if isValidMove {
                Circle()
                    .fill(piece != nil ? Color.red.opacity(0.5) : Color.green.opacity(0.5))
                    .frame(width: piece != nil ? 50 : 16, height: piece != nil ? 50 : 16)
                    .shadow(color: piece != nil ? .red.opacity(0.3) : .green.opacity(0.3), radius: 4)
            }
            
            if isSelected {
                Rectangle()
                    .stroke(
                        LinearGradient(
                            colors: [.blue, .cyan],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        lineWidth: 5
                    )
                    .shadow(color: .blue.opacity(0.5), radius: 4)
            }
        }
        .onDrop(of: [.text], isTargeted: nil) { providers in
            handleDrop(providers: providers)
            return true
        }
    }
    
    func handleDrop(providers: [NSItemProvider]) {
        for provider in providers {
            provider.loadItem(forTypeIdentifier: "public.text", options: nil) { data, error in
                if let data = data as? Data,
                   let string = String(data: data, encoding: .utf8) {
                    let components = string.components(separatedBy: ",")
                    if components.count == 2,
                       let row = Int(components[0]),
                       let col = Int(components[1]),
                       let fromPosition = ChessPosition(row: row, col: col) {
                        DispatchQueue.main.async {
                            // Select the source square first
                            game.selectSquare(at: fromPosition)
                            // Then attempt to move to destination
                            game.selectSquare(at: position)
                            isDragging = false
                        }
                    }
                }
            }
        }
    }
    
    var squareColor: Color {
        if isLightSquare {
            return Color(red: 0.93, green: 0.89, blue: 0.78)
        } else {
            return Color(red: 0.72, green: 0.53, blue: 0.39)
        }
    }
    
    // Returns a gradient for more realistic piece colors
    func pieceGradient(for piece: ChessPiece) -> LinearGradient {
        if piece.color == .white {
            return LinearGradient(
                colors: [
                    Color(red: 0.95, green: 0.95, blue: 0.95),
                    Color(red: 0.85, green: 0.85, blue: 0.85)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        } else {
            return LinearGradient(
                colors: [
                    Color(red: 0.15, green: 0.15, blue: 0.15),
                    Color(red: 0.05, green: 0.05, blue: 0.05)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
        }
    }
}

#Preview {
    ChessBoardView(game: ChessGame())
        .padding()
}
