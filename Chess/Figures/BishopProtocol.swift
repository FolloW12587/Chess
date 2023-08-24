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
        [
            CoordinateShift(dx: 1, dy: 1),
            CoordinateShift(dx: 1, dy: -1),
            CoordinateShift(dx: -1, dy: 1),
            CoordinateShift(dx: -1, dy: -1)
        ]
    }
}
