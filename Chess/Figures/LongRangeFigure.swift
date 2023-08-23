//
//  LongRangeFigure.swift
//  Chess
//
//  Created by Сергей Дубовой on 15.08.2023.
//

import Foundation


class LongRangeFigure: Figure {
    override func isSquareAvailableForMove(_ board: Board, _ coordinate: Coordinate) -> Bool {
        if !super.isSquareAvailableForMove(board, coordinate) {
            return false
        }
        
        return !board.hasFiguresBetween(self.coordinate, coordinate)
    }
    
    override func isSquareAvailableForAttack(_ board: Board, _ coordinate: Coordinate) -> Bool {
        !board.hasFiguresBetween(self.coordinate, coordinate)
    }
}
