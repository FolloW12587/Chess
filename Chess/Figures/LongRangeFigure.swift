//
//  LongRangeFigure.swift
//  Chess
//
//  Created by Сергей Дубовой on 15.08.2023.
//

import Foundation


class LongRangeFigure: Figure {
    override func getAvailableMoves(_ board: Board) -> Set<Move> {
        var output: Set<Move> = []
        for shift in movesShifts {
            for i in 1...7 {
                let coordinate = self.coordinate.from(shift: shift*i)
                if !coordinate.isValid {
                    break
                }
                
                
                let (isAvailable, figure) = isSquareAvailableForMove(board, coordinate)
                if isAvailable {
                    output.insert(Move(from: self.coordinate, to: coordinate, figureTaken: figure))
                }
                if !board.isSquareEmpty(at: coordinate) {
                    break
                }
            }
        }
        
        return output
    }
    
    override func isSquareAvailableForAttack(_ board: Board, _ coordinate: Coordinate) -> Bool {
        isSquareOnAttackLine(board, coordinate) && !board.hasFiguresBetween(self.coordinate, coordinate)
    }
    
    func isSquareOnAttackLine(_ board: Board, _ coordinate: Coordinate) -> Bool {
        true
    }
}
