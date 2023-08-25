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
    var totalMoves: Int = 0
    var totalTime: TimeInterval = 0
    var avgMovesPerSecond: Int {
        Int(totalTime == 0 ? 0 : Double(totalMoves) / totalTime)
    }
    
    func startSearch(at board: Board, for color: Figure.Color) -> Move? {
        let startedAt = Date()
        bestMove = nil
        movesChecked = 0
        self.board = board
        self.search(startingDepth, 0, Int.min+1, Int.max, color)
        print(movesChecked)
        let dateDiff = Date().timeIntervalSince1970 - startedAt.timeIntervalSince1970
        totalTime += dateDiff
        print("\(dateDiff)")
        print("AVG moves per seconds: \(avgMovesPerSecond)")
        return bestMove
    }
    
    @discardableResult func search(_ depth: Int, _ fromRoot: Int, _ alpha: Int, _ beta: Int, _ currentColor: Figure.Color) -> Int {
        if depth == 0 {
            movesChecked += 1
            totalMoves += 1
            return evaluateBoard(for: currentColor)
        }
        var alpha = alpha
        
        var movesCount = 0
        for figure in board.getFigures() {
            if figure.color != currentColor {
                continue
            }
            var figure = figure
            let moves = figure.getAvailableMoves(board)
            for move in moves {
                movesCount += 1
                if let pawn = board.makeMove(move: move) as? Pawn, pawn.isOnLastLine {
                    board.upgradePawn(by: Queen(coordinate: pawn.coordinate, color: pawn.color, board.moves.count))
                }
                let score = -search(depth-1, fromRoot+1, -beta, -alpha, currentColor.opposite())
                board.undoMove()
                if fromRoot == 0 && bestMove == nil {
                    bestMove = move
                }
                if score >= beta {
                    return beta
                }
                if score > alpha {
                    if fromRoot == 0 {
                        bestMove = move
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
        let score = board.materialDiff
        return color == .white ? score : -score
//        return countMaterial(color: color) - countMaterial(color: color.opposite())
    }
    
    func countMaterial(color: Figure.Color) -> Int {
        board.getFigures(color).reduce(0) { partialResult, figure in
            partialResult + figure.value
        }
    }
    
    func countMaterial() -> Int {
        board.materialDiff
    }
}
