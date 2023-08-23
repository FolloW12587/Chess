//
//  RookProtocol.swift
//  Chess
//
//  Created by Сергей Дубовой on 14.08.2023.
//

import Foundation


protocol RookProtocol {
    func getRookShifts() -> Set<CoordinateShift>
}

extension RookProtocol {
    func getRookShifts() -> Set<CoordinateShift> {
        var coordinateShifts: Set<CoordinateShift> = []
        
        for i in 1...7 {
            coordinateShifts.insert(CoordinateShift(dx: i, dy: 0))
            coordinateShifts.insert(CoordinateShift(dx: -i, dy: 0))
            coordinateShifts.insert(CoordinateShift(dx: 0, dy: i))
            coordinateShifts.insert(CoordinateShift(dx: 0, dy: -i))
        }
        
        return coordinateShifts
    }
}
