//
//  Board.swift
//  Chess
//
//  Created by Сергей Дубовой on 01.08.2023.
//

import Foundation


class Board {
    var figures: [Coordinate:Figure] = [:]
    var materialDiff: Int = 0
    var moves = [Move]()
    var kings = [King]()
    
    init(_ fen: String) {
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
                    let king = King(coordinate: Coordinate(x: x, y: y), color: color)
                    figures[Coordinate(x: x, y: y)] = king
                    kings.append(king)
                case "p":
                    figures[Coordinate(x: x, y: y)] = Pawn(coordinate: Coordinate(x: x, y: y), color: color)
                default:
                    fatalError("Incorrect fen notation!")
                }
                x += 1
            }
        }
        if kings[0].color == .black {
            (kings[0], kings[1]) = (kings[1], kings[0])
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
    
//    @discardableResult func makeMove(from oldCoordinate: Coordinate, to newCoordinate: Coordinate) -> Figure? {
//        let move = Move(from: oldCoordinate, to: newCoordinate, figureTaken: figures[newCoordinate])
//        moves.append(move)
//        if move.figureTaken != nil {
//            materialDiff -= move.figureTaken!.material
//        }
//        figures[newCoordinate] = figures[oldCoordinate]
//        figures[newCoordinate]?.coordinate = newCoordinate
//        figures[oldCoordinate] = nil
//        
//        return figures[newCoordinate]
//    }
    
    @discardableResult func makeMove(move: Move) -> Figure? {
        moves.append(move)
        if move.figureTaken != nil {
            figures[move.figureTaken!.coordinate] = nil
            materialDiff -= move.figureTaken!.material
        }
        figures[move.to] = figures[move.from]
        figures[move.to]?.coordinate = move.to
        figures[move.from] = nil
        
        return figures[move.to]
    }
    
    @discardableResult func undoMove() -> Figure {
        if moves.isEmpty {
            fatalError("Can't undo move without moves made!")
        }
        let move = moves.removeLast()
        if figures[move.to]!.upgradedAtMove == moves.count + 1 {
            materialDiff -= figures[move.to]!.material
            figures[move.to] = Pawn(coordinate: move.to, color: figures[move.to]!.color)
            materialDiff += figures[move.to]!.material
        }
        figures[move.from] = figures[move.to]
        figures[move.from]!.coordinate = move.from
        figures[move.to] = nil
        if move.figureTaken != nil {
            figures[move.figureTaken!.coordinate] = move.figureTaken
            materialDiff += move.figureTaken!.material
        }
        return figures[move.from]!
    }
    
    func isKingSafeAfterMove(move: Move) -> Bool {
//        return true
        guard let figure = figures[move.from] else {
            // MARK: No figure at coordinate - invalid
            return false
        }
        
        makeMove(move: move)
        let r = !isKingChecked(of: figure.color)
        undoMove()
        return r
    }
    
    func isSquareEmpty(at coordinate: Coordinate) -> Bool {
        figures[coordinate] == nil
    }
    
    func isSquareUnderAttack(_ coordinate: Coordinate, _ color: Figure.Color) -> Bool {
        for figure in getFigures() {
            if figure.color == color && figure.isSquareAvailableForAttack(self, coordinate) {
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
    func setFigure(_ figure: Figure, at coordinate: Coordinate) {
        figures[coordinate] = figure
    }
    
    func upgradePawn(by figure: Figure) {
        let pawn = getFigure(at: figure.coordinate)!
        materialDiff -= pawn.material
        figures[figure.coordinate] = figure
        materialDiff += figure.material
    }
    
    func getFigures(_ color: Figure.Color) -> [Figure] {
        figures.values.filter { figure in
            figure.color == color
        }
    }
    
    func getFigures() -> [Figure] {
        Array(figures.values)
    }
    
    func getKing(_ color: Figure.Color) -> King {
        color == .white ? kings[0] : kings[1]
    }
    
    static let example = Board("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
}
