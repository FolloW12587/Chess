//
//  Figure.swift
//  Chess
//
//  Created by Сергей Дубовой on 02.08.2023.
//

import Foundation

class Figure: Identifiable {
    let id = UUID()
    var coordinate: Coordinate
    let color: Figure.Color
    var value: Int { 0 }
    var material: Int {
        color == .white ? value : -value
    }
    var upgradedAtMove: Int?
    
    var movesShifts: Set<CoordinateShift> = []
    
    init(coordinate: Coordinate, color: Figure.Color, _ upgradedAtMove: Int? = nil) {
        self.coordinate = coordinate
        self.color = color
        self.upgradedAtMove = upgradedAtMove
    }
    
    func getAssetName() -> String {
        "Unknown"
    }
    
    func getAvailableMoves(_ board: Board) -> Set<Move> {
        var output: Set<Move> = []
        for shift in movesShifts {
            let coordinate = self.coordinate.from(shift: shift)
            if !coordinate.isValid {
                continue
            }
            let (isAvailable, figure) = isSquareAvailableForMove(board, coordinate)
            if isAvailable {
                output.insert(Move(from: self.coordinate, to: coordinate, figureTaken: figure))
            }
        }
        
        return output
    }
    
    func isSquareAvailableForMove(_ board: Board, _ coordinate: Coordinate) -> (Bool, Figure?) {
        let figure = board.getFigure(at: coordinate)
        return ((figure == nil || figure!.color != self.color) && board.isKingSafeAfterMove(move: Move(from: self.coordinate, to: coordinate, figureTaken: figure)), figure)
    }
    
    func isSquareAvailableForAttack(_ board: Board, _ coordinate: Coordinate) -> Bool {
        true
    }
}

extension Figure {
    enum Color: String, Equatable {
        case white
        case black
        
        func opposite() -> Figure.Color {
            self == .white ? .black : .white
        }
    }
}

extension Figure: Comparable {
    static func == (lhs: Figure, rhs: Figure) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Figure, rhs: Figure) -> Bool {
        lhs.value < rhs.value
    }
}
