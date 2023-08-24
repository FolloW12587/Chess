//
//  Board - hasFiguresBetween.swift
//  Chess
//
//  Created by Сергей Дубовой on 15.08.2023.
//

import Foundation

extension Board {
    func hasFiguresBetween(_ lhs: Coordinate, _ rhs: Coordinate) -> Bool {
        if isOnSameVertical(lhs, rhs) {
            return hasFiguresBetweenVertical(lhs, rhs)
        }
        if isOnSameHorizontal(lhs, rhs) {
            return hasFiguresBetweenHorizontal(lhs, rhs)
        }
        if isOnSameDiagonal(lhs, rhs) {
            return hasFiguresBetweenDiagonal(lhs, rhs)
        }
        
        return false
    }
    
    func isOnSameVertical(_ lhs: Coordinate, _ rhs: Coordinate) -> Bool {
        lhs.x == rhs.x
    }
    
    func isOnSameHorizontal(_ lhs: Coordinate, _ rhs: Coordinate) -> Bool {
        lhs.y == rhs.y
    }
    
    func isOnSameDiagonal(_ lhs: Coordinate, _ rhs: Coordinate) -> Bool {
        abs(lhs.x - rhs.x) == abs(lhs.y - rhs.y)
    }
    
    func hasFiguresBetweenDiagonal(_ lhs: Coordinate, _ rhs: Coordinate) -> Bool {
        // MARK: coordinates should be on the same diagonal
        let xShift = lhs.x > rhs.x ? -1 : 1
        let yShift = lhs.y > rhs.y ? -1 : 1
        
        for i in 1..<abs(lhs.x - rhs.x) {
            if !isSquareEmpty(at: Coordinate(x: lhs.x + i*xShift, y: lhs.y + i*yShift)) {
                return true
            }
        }
        return false
    }
    
    func hasFiguresBetweenVertical(_ lhs: Coordinate, _ rhs: Coordinate) -> Bool {
        // MARK: coordinates should be in the same column
        let (l, h) = (min(lhs.y, rhs.y), max(lhs.y, rhs.y))
        
        for i in l+1..<h {
            if !isSquareEmpty(at: Coordinate(x: lhs.x, y: i)) {
                return true
            }
        }
        return false
    }
    
    func hasFiguresBetweenHorizontal(_ lhs: Coordinate, _ rhs: Coordinate) -> Bool {
        // MARK: coordinates should be in the same row
        let (l, h) = (min(lhs.x, rhs.x), max(lhs.x, rhs.x))
        
        for i in l+1..<h {
            if !isSquareEmpty(at: Coordinate(x: i, y: lhs.y)) {
                return true
            }
        }
        return false
    }
}
