//
//  CoordinateShift.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

struct CoordinateShift: Hashable {
    let dx: Int
    let dy: Int
    
    static func *(_ lhs: CoordinateShift, _ n: Int) -> CoordinateShift {
        CoordinateShift(dx: lhs.dx*n, dy: lhs.dy*n)
    }
}
