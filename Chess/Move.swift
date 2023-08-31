//
//  Move.swift
//  Chess
//
//  Created by Сергей Дубовой on 23.08.2023.
//

import Foundation


struct Move: CustomDebugStringConvertible {
    var debugDescription: String {
        let x1 = startedSquare % 8
        let y1 = startedSquare / 8
        let x2 = targetSquare % 8
        let y2 = targetSquare / 8
        
        return "\(String(UnicodeScalar(96+x1+1)!))\(y1+1)\(String(UnicodeScalar(96+x2+1)!))\(y2+1), flag: \(flag)"
    }
    
    let value: Int
    
    static let StartedMask: Int = 0b111111
    static let TargetMask: Int = 0b111111_000000
    static let FlagMask: Int = 0b1111_000000_000000
    
    var startedSquare: Int {
        value & Move.StartedMask
    }
    
    var targetSquare: Int {
        (value & Move.TargetMask) >> 6
    }
    
    var flag: Int {
        value >> 12
    }
    
    var isPromotion: Bool {
        let flag = flag
        return flag == Flag.PromoteToRook || flag == Flag.PromoteToQueen || flag == Flag.PromoteToBishop || flag == Flag.PromoteToKnight
    }
    
    
    init(value: Int) {
        self.value = value
    }
    
    init(_ startSquare: Int, _ targetSquare: Int) {
        value = startSquare | targetSquare << 6
    }
    
    init(_ startSquare: Int, _ targetSquare: Int, _ flag: Int) {
        value = startSquare | targetSquare << 6 | flag << 12
    }
}

extension Move {
    struct Flag {
        static let None = 0;
        static let EnPassantCapture = 1;
        static let Castling = 2;
        static let PromoteToQueen = 3;
        static let PromoteToKnight = 4;
        static let PromoteToRook = 5;
        static let PromoteToBishop = 6;
        static let PawnTwoForward = 7;
    }
}
