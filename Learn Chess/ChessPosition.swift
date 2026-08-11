//
//  ChessPosition.swift
//  Learn Chess
//
//  Created by Mahlet Getu on 7/30/26.
//

import Foundation
import CoreTransferable
import UniformTypeIdentifiers

struct ChessPosition: Equatable, Hashable, Sendable {
    let row: Int
    let col: Int
    
    init?(row: Int, col: Int) {
        guard (0..<8).contains(row) && (0..<8).contains(col) else {
            return nil
        }
        self.row = row
        self.col = col
    }
    
    func offset(by rowOffset: Int, _ colOffset: Int) -> ChessPosition? {
        ChessPosition(row: row + rowOffset, col: col + colOffset)
    }
    
    var notation: String {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
        return "\(files[col])\(8 - row)"
    }
}

extension UTType {
    static let chessPosition = UTType(exportedAs: "com.learnchess.position")
}

extension ChessPosition: Codable {
    enum CodingKeys: String, CodingKey {
        case row, col
    }
    
    nonisolated func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(row, forKey: .row)
        try container.encode(col, forKey: .col)
    }
    
    nonisolated init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let row = try container.decode(Int.self, forKey: .row)
        let col = try container.decode(Int.self, forKey: .col)
        
        guard (0..<8).contains(row) && (0..<8).contains(col) else {
            throw DecodingError.dataCorruptedError(
                forKey: .row,
                in: container,
                debugDescription: "Invalid chess position: row \(row), col \(col)"
            )
        }
        
        self.row = row
        self.col = col
    }
}

extension ChessPosition: Transferable {
    static var transferRepresentation: some TransferRepresentation {
        CodableRepresentation(contentType: .chessPosition)
    }
}
