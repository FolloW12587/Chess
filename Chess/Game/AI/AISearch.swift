//
//  AISearch.swift
//  Chess
//
//  Created by Сергей Дубовой on 23.08.2023.
//

import Foundation


class AISearch {
    let startingDepth = 4
    var board: Board! = nil
    var bestMove: Move? = nil
    var movesChecked: Int = 0
    
    func startSearch(at board: Board, for color: Figure.Color) -> Move? {
        let startedAt = Date()
        bestMove = nil
        movesChecked = 0
        self.board = Board(board.toFen())
        self.search(startingDepth, 0, Int.min+1, Int.max, color)
        print(movesChecked)
        let dateDiff = Date().timeIntervalSince1970 - startedAt.timeIntervalSince1970
        print("\(dateDiff)")
        return bestMove
    }
    
    @discardableResult func search(_ depth: Int, _ fromRoot: Int, _ alpha: Int, _ beta: Int, _ currentColor: Figure.Color) -> Int {
        if depth == 0 {
            movesChecked += 1
            return evaluateBoard(for: currentColor)
        }
        var alpha = alpha
        
        var movesCount = 0
        for figure in board.getFigures(currentColor) {
            var figure = figure
            let coordinates = figure.getAvailableForMoveCoordinates(board)
            movesCount += coordinates.count
            for coordinate in coordinates {
                if let pawn = board.makeMove(from: figure.coordinate, to: coordinate) as? Pawn, pawn.isOnLastLine() {
                    board.figures[pawn.coordinate] = Queen(coordinate: pawn.coordinate, color: pawn.color, board.moves.count)
                }
                let score = -search(depth-1, fromRoot+1, -beta, -alpha, currentColor.opposite())
                figure = board.undoMove()
                if fromRoot == 0 && bestMove == nil {
                    bestMove = Move(from: figure.coordinate, to: coordinate)
                }
                if score >= beta {
                    return beta
                }
                if score > alpha {
                    if fromRoot == 0 {
                        bestMove = Move(from: figure.coordinate, to: coordinate)
                    }
                    alpha = score
                }
            }
        }
        
        if movesCount == 0 {
            if board.isKingChecked(of: currentColor) {
                return Int.min+1
            }
            return 0
        }
        return alpha
    }
    
    func evaluateBoard(for color: Figure.Color) -> Int {
        return countMaterial(color: color) - countMaterial(color: color.opposite())
    }
    
    func countMaterial(color: Figure.Color) -> Int {
        board.getFigures(color).reduce(0) { partialResult, figure in
            partialResult + figure.value
        }
    }
}
