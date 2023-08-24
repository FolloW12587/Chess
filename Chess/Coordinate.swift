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
    
    var description: String {
        "(x: \(x), y: \(y))"
    }
    
    func from(shift: CoordinateShift) -> Coordinate {
        Coordinate(x: x + shift.dx, y: y + shift.dy)
    }
    
    static func -(_ lhs: Coordinate, _ rhs: Coordinate) -> CoordinateShift {
        CoordinateShift(dx: lhs.x-rhs.x, dy: lhs.y-rhs.y)
    }
}
