//
//  BishopProtocol.swift
//  Chess
//
//  Created by Сергей Дубовой on 14.08.2023.
//

import Foundation

protocol BishopProtocol {
    func getBishopShifts() -> Set<CoordinateShift>
}

extension BishopProtocol {
    func getBishopShifts() -> Set<CoordinateShift> {
        var coordinateShifts: Set<CoordinateShift> = []
        
        for i in 1...7 {
            coordinateShifts.insert(CoordinateShift(dx: i, dy: i))
            coordinateShifts.insert(CoordinateShift(dx: i, dy: -i))
            coordinateShifts.insert(CoordinateShift(dx: -i, dy: i))
            coordinateShifts.insert(CoordinateShift(dx: -i, dy: -i))
        }
        
        return coordinateShifts
    }
}
