//
//  King.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

class King: Figure {
    static let figureName: String = "king"
    override var value: Int { 10 }
    
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
}
