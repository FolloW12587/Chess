//
//  Board.swift
//  Chess
//
//  Created by Сергей Дубовой on 01.08.2023.
//

import Foundation


class Board: ObservableObject {
    @Published var figures: [Coordinate:Figure] = [:]
    private var currentFen: String
    
    init(_ fen: String) {
        currentFen = fen
        let rows = fen.split(separator: " ")[0]
        let rowsInfo = rows.split(separator: "/")
        
        for (i, row) in rowsInfo.enumerated() {
            let y = 8 - i
            var x = 1
            
            for char in row {
                if char.isNumber {
                    x += Int(String(char))!
                    continue
                }
                
                let color: Figure.Color = char.isUppercase ? .white : .black
                
                switch(char.lowercased()){
                case "r":
                    figures[Coordinate(x: x, y: y)] = Rook(coordinate: Coordinate(x: x, y: y), color: color)
                case "n":
                    figures[Coordinate(x: x, y: y)] = Knight(coordinate: Coordinate(x: x, y: y), color: color)
                case "b":
                    figures[Coordinate(x: x, y: y)] = Bishop(coordinate: Coordinate(x: x, y: y), color: color)
                case "q":
                    figures[Coordinate(x: x, y: y)] = Queen(coordinate: Coordinate(x: x, y: y), color: color)
                case "k":
                    figures[Coordinate(x: x, y: y)] = King(coordinate: Coordinate(x: x, y: y), color: color)
                case "p":
                    figures[Coordinate(x: x, y: y)] = Pawn(coordinate: Coordinate(x: x, y: y), color: color)
                default:
                    fatalError("Incorrect fen notation!")
                }
                x += 1
            }
        }
    }
    
    func toFen() -> String {
        var output = ""
        
        for y in (1...8).reversed() {
            var zerosCount = 0
            for x in 1...8 {
                if isSquareEmpty(at: Coordinate(x: x, y: y)) {
                    zerosCount += 1
                    continue
                }
                
                if zerosCount > 0 {
                    output += "\(zerosCount)"
                    zerosCount = 0
                }
                let figure = getFigure(at: Coordinate(x: x, y: y))!
                switch figure {
                case is King:
                    output += figure.color == .white ? "K" : "k"
                case is Rook:
                    output += figure.color == .white ? "R" : "r"
                case is Knight:
                    output += figure.color == .white ? "N" : "n"
                case is Bishop:
                    output += figure.color == .white ? "B" : "b"
                case is Queen:
                    output += figure.color == .white ? "Q" : "q"
                case is Pawn:
                    output += figure.color == .white ? "P" : "p"
                default:
                    continue
                }
            }
            if zerosCount > 0 {
                output = "\(output)\(zerosCount)"
            }
            if y > 1 {
                output += "/"
            }
        }
        
        return output
    }
    
    @discardableResult func makeMove(from oldCoordinate: Coordinate, to newCoordinate: Coordinate) -> Figure? {
        figures[newCoordinate] = figures[oldCoordinate]
        figures[newCoordinate]?.coordinate = newCoordinate
        figures[oldCoordinate] = nil
        currentFen = toFen()
        return figures[newCoordinate]
    }
    
    func isKingNotCheckedAfterMove(from oldCoordinate: Coordinate, to newCoordinate: Coordinate) -> Bool {
        guard let figure = figures[oldCoordinate] else {
            // MARK: No figure at coordinate - invalid
            return false
        }
        
        let boardCopy = Board(currentFen)
        boardCopy.makeMove(from: oldCoordinate, to: newCoordinate)
        return !boardCopy.isKingChecked(of: figure.color)
    }
    
    func isSquareEmpty(at coordinate: Coordinate) -> Bool {
        figures[coordinate] == nil
    }
    
    func isSquareUnderAttack(_ coordinate: Coordinate, _ color: Figure.Color) -> Bool {
        let enemyFigures = getFigures(color)
        for enemyFigure in enemyFigures {
            if enemyFigure.getAvailableForAttackCoordinates(self).contains(coordinate) {
                return true
            }
        }
        return false
    }
    
    func isKingChecked(of color: Figure.Color) -> Bool {
        let king = getKing(color)
        return isSquareUnderAttack(king.coordinate, king.color.opposite())
    }
    
    func getFigure(at coordinate: Coordinate) -> Figure? {
        figures[coordinate]
    }
    
    func getFigures(_ color: Figure.Color) -> [Figure] {
        figures.values.filter { figure in
            figure.color == color
        }
    }
    
    func getKing(_ color: Figure.Color) -> King {
        getFigures(color).filter { figure in
            figure is King
        }.first as! King
    }
    
    static let example = Board("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
}
