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
        [
            CoordinateShift(dx: 0, dy: 1),
            CoordinateShift(dx: 0, dy: -1),
            CoordinateShift(dx: 1, dy: 0),
            CoordinateShift(dx: -1, dy: 0)
        ]
    }
}
