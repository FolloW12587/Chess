//
//  Queen.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

class Queen: LongRangeFigure, BishopProtocol, RookProtocol {
    static let figureName: String = "queen"
    override var value: Int { 9 }
    
    override func getAssetName() -> String {
        Queen.figureName + "_" + color.rawValue
    }
    
    override func getMoveShifts() -> Set<CoordinateShift> {
        return self.getRookShifts().union(self.getBishopShifts())
    }
    
    override func isSquareOnAttackLine(_ board: Board, _ coordinate: Coordinate) -> Bool {
        board.isOnSameDiagonal(self.coordinate, coordinate) || board.isOnSameHorizontal(self.coordinate, coordinate) || board.isOnSameVertical(self.coordinate, coordinate)
    }
}
