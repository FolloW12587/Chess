//
//  Coordinate.swift
//  Chess
//
//  Created by Сергей Дубовой on 01.08.2023.
//

import Foundation

struct Coordinate: Hashable {
    let x: Int
    let y: Int
    
    var isValid: Bool {
        x > 0 && x < 9 && y > 0 && y < 9
    }
    
    func from(shift: CoordinateShift) -> Coordinate {
        Coordinate(x: x + shift.dx, y: y + shift.dy)
    }
}
