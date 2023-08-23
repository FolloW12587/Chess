//
//  Rook.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

class Rook: LongRangeFigure, RookProtocol {
    static let figureName: String = "rook"
    override var value: Int { 5 }
    
    override func getAssetName() -> String {
        Rook.figureName + "_" + color.rawValue
    }
    
    override func getMoveShifts() -> Set<CoordinateShift> {
        self.getRookShifts()
    }
}
