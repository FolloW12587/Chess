//
//  GameAIvsAI.swift
//  Chess
//
//  Created by Сергей Дубовой on 24.08.2023.
//

import Foundation


class GameAIvsAI: Game {
    let searcher = AISearch()
    
    override init() {
        super.init()
    }
    
    func makeMove() {
        if isPaused {
            return
        }
        if isGameEnded {
            return
        }
        aiTern()
    }
    
    func aiTern() {
        guard let move = searcher.startSearch(at: board, for: currentColor) else {
            isGameEnded = true
            winner = currentColor.opposite()
            return
        }
        avgMovesPerSecond = searcher.avgMovesPerSecond
        if figuresForUpdate.isEmpty {
            makeMoveByAI(move)
        }
    }
    
    func makeMoveByAI(_ move: Move) {
        if !board.isSquareEmpty(at: move.to) {
            figuresTakenByColor[currentColor]?.append(board.getFigure(at: move.to)!)
        }
        if let pawn = board.makeMove(move: move) as? Pawn, pawn.isOnLastLine {
            board.upgradePawn(by: Queen(coordinate: pawn.coordinate, color: pawn.color, board.moves.count))
        }
        materialDiff = board.materialDiff
        lastMove = board.moves.last
        rotatePlayer()
        checkForDrawOrStaleMate()
    }
}
