//
//  ChessPiece.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation

enum PieceType: String, Codable {
    case pawn = "♟"
    case rook = "♜"
    case knight = "♞"
    case bishop = "♝"
    case queen = "♛"
    case king = "♚"
    
    var symbol: String {
        return self.rawValue
    }
}

enum PieceColor: Codable {
    case white
    case black
    
    var opposite: PieceColor {
        self == .white ? .black : .white
    }
}

struct ChessPiece: Codable, Equatable, Identifiable {
    let id: UUID
    let type: PieceType
    let color: PieceColor
    var hasMoved: Bool = false
    
    var symbol: String {
        // All pieces use filled symbols
        switch type {
        case .pawn: return "♟"
        case .rook: return "♜"
        case .knight: return "♞"
        case .bishop: return "♝"
        case .queen: return "♛"
        case .king: return "♚"
        }
    }
    
    init(type: PieceType, color: PieceColor) {
        self.id = UUID()
        self.type = type
        self.color = color
        self.hasMoved = false
    }
    
    // Equatable conformance (ignore ID for equality)
    static func == (lhs: ChessPiece, rhs: ChessPiece) -> Bool {
        lhs.type == rhs.type && lhs.color == rhs.color && lhs.hasMoved == rhs.hasMoved
    }
}
