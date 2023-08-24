//
//  King.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

class King: Figure {
    static let figureName: String = "king"
    override var value: Int { 200 }
    
    override func getAssetName() -> String {
        King.figureName + "_" + color.rawValue
    }
    
    override func getMoveShifts() -> Set<CoordinateShift> {
        var output = Set<CoordinateShift>()
        for i in -1...1 {
            for j in -1...1 {
                if i == 0 && j == 0 {
                    continue
                }
                output.insert(CoordinateShift(dx: i, dy: j))
            }
        }
        return output
    }
    
    override func isSquareAvailableForAttack(_ board: Board, _ coordinate: Coordinate) -> Bool {
        let shift = self.coordinate - coordinate
        return (abs(shift.dx) == 1 || shift.dx == 0) && (abs(shift.dy) == 1 || shift.dy == 0)
    }
}
