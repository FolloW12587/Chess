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
    
    override init(coordinate: Coordinate, color: Figure.Color, _ upgradedAtMove: Int? = nil) {
        super.init(coordinate: coordinate, color: color, upgradedAtMove)
        movesShifts = [
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
    
    override func getAssetName() -> String {
        Knight.figureName + "_" + color.rawValue
    }
    
    override func isSquareAvailableForAttack(_ board: Board, _ coordinate: Coordinate) -> Bool {
        movesShifts.contains(self.coordinate - coordinate)
    }
}
