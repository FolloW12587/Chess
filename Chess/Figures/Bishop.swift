//
//  Bishop.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

class Bishop: LongRangeFigure, BishopProtocol {
    static let figureName: String = "bishop"
    override var value: Int { 3 }
    
    override func getAssetName() -> String {
        Bishop.figureName + "_" + color.rawValue
    }
    
    override func getMoveShifts() -> Set<CoordinateShift> {
        self.getBishopShifts()
    }
    
    override func isSquareOnAttackLine(_ board: Board, _ coordinate: Coordinate) -> Bool {
        board.isOnSameDiagonal(self.coordinate, coordinate)
    }
}
