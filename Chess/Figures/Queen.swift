//
//  Queen.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

class Queen: LongRangeFigure, BishopProtocol, RookProtocol {
    static let figureName: String = "queen"
    override var value: Int { 7 }
    
    override func getAssetName() -> String {
        Queen.figureName + "_" + color.rawValue
    }
    
    override func getMoveShifts() -> Set<CoordinateShift> {
        return self.getRookShifts().union(self.getBishopShifts())
    }
}
