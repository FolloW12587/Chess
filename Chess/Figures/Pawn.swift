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
    
    var isOnLastLine: Bool {
        (color == .white && coordinate.y == 8) || (color == .black && coordinate.y == 1)
    }
    
    var isOnTakeOnPassLine: Bool {
        (color == .white && coordinate.y == 5) || (color == .black && coordinate.y == 4)
    }
    
    var isOnStartingPosition: Bool {
        (coordinate.y == 7 && color == .black) || (coordinate.y == 2 && color == .white)
    }
    
    override func getMoveShifts() -> Set<CoordinateShift> {
        let shift = color == .white ? 1 : -1
        var output: Set<CoordinateShift> = [
            CoordinateShift(dx: 0, dy: shift),
            CoordinateShift(dx: 1, dy: shift),
            CoordinateShift(dx: -1, dy: shift),
        ]
        if isOnStartingPosition {
            output.insert(CoordinateShift(dx: 0, dy: shift*2))
        }
        return output
    }
    
    override func isSquareAvailableForMove(_ board: Board, _ coordinate: Coordinate) -> (Bool, Figure?) {
        if coordinate.x == self.coordinate.x {
            return (board.isSquareEmpty(at: coordinate) && !board.hasFiguresBetween(self.coordinate, coordinate) && board.isKingSafeAfterMove(move: Move(from: self.coordinate, to: coordinate)), nil)
        }
        
        let figure = board.getFigure(at: coordinate)
        if figure != nil {
            return (figure!.color != self.color && board.isKingSafeAfterMove(move: Move(from: self.coordinate, to: coordinate, figureTaken: figure)), figure)
        }
        if isOnTakeOnPassLine {
            // MARK: check take on pass
            if let pawn = board.getFigure(at: Coordinate(x: coordinate.x, y: self.coordinate.y)) as? Pawn, let move = board.moves.last, move.to == pawn.coordinate && board.isKingSafeAfterMove(move: Move(from: self.coordinate, to: coordinate, figureTaken: figure)) {
                return (true, pawn)
            }
        }
        return (false, nil)
    }
    
    override func isSquareAvailableForAttack(_ board: Board, _ coordinate: Coordinate) -> Bool {
        let multiplier = color == .white ? -1 : 1
        let shift = (self.coordinate - coordinate)*multiplier
        return shift == CoordinateShift(dx: 1, dy: 1) || shift == CoordinateShift(dx: -1, dy: 1)
    }
}
