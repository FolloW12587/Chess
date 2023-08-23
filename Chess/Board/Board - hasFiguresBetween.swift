//
//  Board - hasFiguresBetween.swift
//  Chess
//
//  Created by Сергей Дубовой on 15.08.2023.
//

import Foundation

extension Board {
    func hasFiguresBetween(_ coordinate1: Coordinate, _ coordinate2: Coordinate) -> Bool {
        if coordinate1.x == coordinate2.x {
            return hasFiguresBetweenVertical(coordinate1, coordinate2)
        }
        if coordinate1.y == coordinate2.y {
            return hasFiguresBetweenHorizontal(coordinate1, coordinate2)
        }
        if abs(coordinate1.x - coordinate2.x) == abs(coordinate1.y - coordinate2.y) {
            return hasFiguresBetweenDiagonal(coordinate1, coordinate2)
        }
        
        return false
    }
    
    func hasFiguresBetweenDiagonal(_ coordinate1: Coordinate, _ coordinate2: Coordinate) -> Bool {
        // MARK: coordinates should be on the same diagonal
        let xShift = coordinate1.x > coordinate2.x ? -1 : 1
        let yShift = coordinate1.y > coordinate2.y ? -1 : 1
        
        for i in 1..<abs(coordinate1.x - coordinate2.x) {
            if !isSquareEmpty(at: Coordinate(x: coordinate1.x + i*xShift, y: coordinate1.y + i*yShift)) {
                return true
            }
        }
        return false
    }
    
    func hasFiguresBetweenVertical(_ coordinate1: Coordinate, _ coordinate2: Coordinate) -> Bool {
        // MARK: coordinates should be in the same column
        let (l, h) = (min(coordinate1.y, coordinate2.y), max(coordinate1.y, coordinate2.y))
        
        for i in l+1..<h {
            if !isSquareEmpty(at: Coordinate(x: coordinate1.x, y: i)) {
                return true
            }
        }
        return false
    }
    
    func hasFiguresBetweenHorizontal(_ coordinate1: Coordinate, _ coordinate2: Coordinate) -> Bool {
        // MARK: coordinates should be in the same row
        let (l, h) = (min(coordinate1.x, coordinate2.x), max(coordinate1.x, coordinate2.x))
        
        for i in l+1..<h {
            if !isSquareEmpty(at: Coordinate(x: i, y: coordinate1.y)) {
                return true
            }
        }
        return false
    }
}
