//
//  Rook.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

class Rook: LongRangeFigure, RookProtocol {
    static let figureName: String = "rook"
    override var value: Int { 5 }
    
    override init(coordinate: Coordinate, color: Figure.Color, _ upgradedAtMove: Int? = nil) {
        super.init(coordinate: coordinate, color: color, upgradedAtMove)
        movesShifts = self.getRookShifts()
    }
    
    override func getAssetName() -> String {
        Rook.figureName + "_" + color.rawValue
    }
    
    override func isSquareOnAttackLine(_ board: Board, _ coordinate: Coordinate) -> Bool {
        board.isOnSameHorizontal(self.coordinate, coordinate) || board.isOnSameVertical(self.coordinate, coordinate)
    }
}
