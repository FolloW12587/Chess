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
    var material: Int {
        color == .white ? value : -value
    }
    var upgradedAtMove: Int?
    
    init(coordinate: Coordinate, color: Figure.Color, _ upgradedAtMove: Int? = nil) {
        self.coordinate = coordinate
        self.color = color
        self.upgradedAtMove = upgradedAtMove
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
        let figure = board.getFigure(at: coordinate)
        return (figure == nil || figure!.color != self.color) && board.isKingSafeAfterMove(from: self.coordinate, to: coordinate)
    }
    
    func getMoveShifts() -> Set<CoordinateShift> {
        []
    }
    
    func isSquareAvailableForAttack(_ board: Board, _ coordinate: Coordinate) -> Bool {
        true
    }
}

extension Figure {
    enum Color: String, Equatable {
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
