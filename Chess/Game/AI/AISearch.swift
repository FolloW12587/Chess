//
//  AISearch.swift
//  Chess
//
//  Created by Сергей Дубовой on 23.08.2023.
//

import Foundation


class AISearch {
    var startingDepth = 6
    var board: Board! = nil
    var bestMove: Move? = nil
    var movesChecked: Int = 0
    let moveGenerator = MoveGenerator()
    
    func startSearch(at board: Board, for color: Int) -> Move? {
        let startedAt = Date()
        bestMove = nil
        movesChecked = 0
        self.board = board
        self.search(startingDepth, Int.min+1, Int.max, color)
        print("Total moves: \(movesChecked)")
        let dateDiff = Date().timeIntervalSince1970 - startedAt.timeIntervalSince1970
        print("time \((dateDiff*1000).rounded() / 1000)")
        return bestMove
    }
    
    @discardableResult func search(_ depth: Int, _ alpha: Int, _ beta: Int, _ currentColor: Int) -> Int {
        if depth == 0 {
            movesChecked += 1
            return evaluateBoard(for: currentColor)
        }
        var alpha = alpha

        let moves = moveGenerator.generateMoves(board: board, color: currentColor)
        if moves.count == 0 {
            if moveGenerator.inCheck {
                return Int.min+1
            }
            return 0
        }
        for move in moves {
            board.makeMove(move)
            let score = -search(depth - 1, -beta, -alpha, Piece.oppositeColor(of: currentColor))
            board.undoMove(move)
            if depth == startingDepth && bestMove == nil {
                bestMove = move
            }
            if score >= beta {
                return beta
            }
            if score > alpha {
                if depth == startingDepth {
                    bestMove = move
                }
                alpha = score
            }
        }
        return alpha
    }

    func evaluateBoard(for color: Int) -> Int {
        let score = board.materialDiff
        return color == Piece.White ? score : -score
    }
}
