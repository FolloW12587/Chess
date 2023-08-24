//
//  Knight.swift
//  Chess
//
//  Created by Сергей Дубовой on 02.08.2023.
//

import Foundation

class Knight: Figure {
    static let figureName: String = "knight"
    override var value: Int { 3 }
    
    override func getAssetName() -> String {
        Knight.figureName + "_" + color.rawValue
    }
    
    override func getMoveShifts() -> Set<CoordinateShift> {
        return [
            CoordinateShift(dx: 2, dy: 1),
            CoordinateShift(dx: 2, dy: -1),
            CoordinateShift(dx: 1, dy: 2),
            CoordinateShift(dx: 1, dy: -2),
            CoordinateShift(dx: -2, dy: 1),
            CoordinateShift(dx: -2, dy: -1),
            CoordinateShift(dx: -1, dy: 2),
            CoordinateShift(dx: -1, dy: -2),
        ]
    }
    
    override func isSquareAvailableForAttack(_ board: Board, _ coordinate: Coordinate) -> Bool {
        getMoveShifts().contains(self.coordinate - coordinate)
    }
}
