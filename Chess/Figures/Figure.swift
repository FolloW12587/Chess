//
//  Figure.swift
//  Chess
//
//  Created by Сергей Дубовой on 02.08.2023.
//

import Foundation

class Figure: Identifiable {
    let id = UUID()
    var coordinate: Coordinate
    let color: Figure.Color
    var value: Int { 0 }
    
    init(coordinate: Coordinate, color: Figure.Color) {
        self.coordinate = coordinate
        self.color = color
    }
    
    func getAssetName() -> String {
        "Unknown"
    }
    
    func getAvailableForMoveCoordinates(_ board: Board) -> Set<Coordinate> {
        var output: Set<Coordinate> = []
        let shifts = self.getMoveShifts()
        for shift in shifts {
            let coordinate = self.coordinate.from(shift: shift)
            if !coordinate.isValid {
                continue
            }
            if isSquareAvailableForMove(board, coordinate) {
                output.insert(coordinate)
            }
        }
        
        return output
    }
    
    func isSquareAvailableForMove(_ board: Board, _ coordinate: Coordinate) -> Bool {
        (board.isSquareEmpty(at: coordinate) || board.getFigure(at: coordinate)!.color != self.color) && board.isKingNotCheckedAfterMove(from: self.coordinate, to: coordinate)
    }
    
    func getMoveShifts() -> Set<CoordinateShift> {
        []
    }
    
    func getAvailableForAttackCoordinates(_ board: Board) -> Set<Coordinate> {
        var output: Set<Coordinate> = []
        let shifts = self.getMoveShifts()
        for shift in shifts {
            let coordinate = self.coordinate.from(shift: shift)
            if !coordinate.isValid {
                continue
            }
            if isSquareAvailableForAttack(board, coordinate) {
                output.insert(coordinate)
            }
        }
        
        return output
    }
    
    func isSquareAvailableForAttack(_ board: Board, _ coordinate: Coordinate) -> Bool {
        true
    }
}

extension Figure {
    enum Color: String {
        case white
        case black
        
        func opposite() -> Figure.Color {
            self == .white ? .black : .white
        }
    }
}

extension Figure: Comparable {
    static func == (lhs: Figure, rhs: Figure) -> Bool {
        lhs.id == rhs.id
    }
    
    static func < (lhs: Figure, rhs: Figure) -> Bool {
        lhs.value < rhs.value
    }
}
