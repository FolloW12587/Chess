//
//  Piece.swift
//  Chess
//
//  Created by Сергей Дубовой on 28.08.2023.
//

import Foundation


class Piece {
    // 0-3 bits - type, 4 and 5 bits are color
    static let None = 0
    static let Pawn = 1
    static let King = 2
    static let Knight = 3
    static let Bishop = 4
    static let Rook = 5
    static let Queen = 6
    static let PieceTypeMask = 0b00111
    
    static let White = 8
    static let Black = 16
    static let PieceWhiteMask = 0b01000
    static let PieceBlackMask = 0b10000
    static let PieceColorMask = 0b11000
    
    static func type(of piece: Int) -> Int {
        piece & PieceTypeMask
    }
    
    static func isType(_ piece: Int, _ type: Int) -> Bool {
        Piece.type(of: piece) == type
    }
    
    static func color(of piece: Int) -> Int {
        piece & PieceColorMask
    }
    
    static func oppositeColor(of color: Int) -> Int {
        color == White ? Black : White
    }
    
    static func isColor(_ piece: Int, _ color: Int) -> Bool {
        Piece.color(of: piece) == color
    }
    
    static func colorIndex(_ color: Int) -> Int {
        (color >> 3) / 2
    }
    
    static func assetName(of piece: Int) -> String {
        if piece == Piece.None {
            return ""
        }
        let color = Piece.isColor(piece, Piece.White) ? "white" : "black"
        
        switch Piece.type(of: piece) {
        case Piece.King:
            return "king_\(color)"
        case Piece.Pawn:
            return "pawn_\(color)"
        case Piece.Bishop:
            return "bishop_\(color)"
        case Piece.Knight:
            return "knight_\(color)"
        case Piece.Rook:
            return "rook_\(color)"
        case Piece.Queen:
            return "queen_\(color)"
        default:
            return ""
        }
    }
    
    static func value(of piece: Int) -> Int {
        let multiplier = Piece.color(of: piece) == Piece.White ? 1 : -1
        switch Piece.type(of: piece){
        case Piece.King:
            return 100000*multiplier
        case Piece.Pawn:
            return 1*multiplier
        case Piece.Bishop:
            return 3*multiplier
        case Piece.Knight:
            return 3*multiplier
        case Piece.Rook:
            return 5*multiplier
        case Piece.Queen:
            return 9*multiplier
        default:
            return 0
        }
    }
}
