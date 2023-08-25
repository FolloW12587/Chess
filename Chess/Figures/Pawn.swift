//
//  Pawn.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

class Pawn: Figure {
    static let figureName: String = "pawn"
    override var value: Int { 1 }
    
    override func getAssetName() -> String {
        Pawn.figureName + "_" + color.rawValue
    }
    
    override func getMoveShifts() -> Set<CoordinateShift> {
        let shift = color == .white ? 1 : -1
        var output: Set<CoordinateShift> = [
            CoordinateShift(dx: 0, dy: shift),
            CoordinateShift(dx: 1, dy: shift),
            CoordinateShift(dx: -1, dy: shift),
        ]
        if (coordinate.y == 7 && color == .black) || (coordinate.y == 2 && color == .white) {
            output.insert(CoordinateShift(dx: 0, dy: shift*2))
        }
        return output
    }
    
    override func isSquareAvailableForMove(_ board: Board, _ coordinate: Coordinate) -> Bool {
        if coordinate.x == self.coordinate.x {
            return board.isSquareEmpty(at: coordinate) && !board.hasFiguresBetween(self.coordinate, coordinate) && board.isKingSafeAfterMove(from: self.coordinate, to: coordinate)
        }
        
        let figure = board.getFigure(at: coordinate)
        return figure != nil && figure!.color != self.color && board.isKingSafeAfterMove(from: self.coordinate, to: coordinate)
    }
    
    override func isSquareAvailableForAttack(_ board: Board, _ coordinate: Coordinate) -> Bool {
        let multiplier = color == .white ? -1 : 1
        let shift = (self.coordinate - coordinate)*multiplier
        return shift == CoordinateShift(dx: 1, dy: 1) || shift == CoordinateShift(dx: -1, dy: 1)
    }
    
    func isOnLastLine() -> Bool {
        return (color == .white && coordinate.y == 8) || (color == .black && coordinate.y == 1)
    }
}
