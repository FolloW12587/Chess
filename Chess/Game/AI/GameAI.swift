//
//  GameAI.swift
//  Chess
//
//  Created by Сергей Дубовой on 23.08.2023.
//

import Foundation


class GameAI: Game {
    let aiColor: Figure.Color
    let searcher = AISearch()
    
    init(_ color: Figure.Color) {
        aiColor = color.opposite()
        super.init()
    }
    
    override func undoMove() {
        super.undoMove()
        super.undoMove()
    }
    
    override func makeMove(to coordinate: Coordinate) {
        super.makeMove(to: coordinate)
        aiTern()
    }
    
    override func figureForUpdateTapped(_ figure: Figure) {
        super.figureForUpdateTapped(figure)
        aiTern()
    }
    
    func aiTern() {
        guard let move = searcher.startSearch(at: board, for: currentColor) else {
            isGameEnded = true
            winner = currentColor.opposite()
            return
        }
        if figuresForUpdate.isEmpty {
            makeMoveByAI(move)
        }
    }
    
    func makeMoveByAI(_ move: Move) {
        if !board.isSquareEmpty(at: move.to) {
            figuresTakenByColor[currentColor]?.append(board.getFigure(at: move.to)!)
        }
        if let pawn = board.makeMove(from: move.from, to: move.to) as? Pawn, pawn.isOnLastLine() {
            board.figures[pawn.coordinate] = Queen(coordinate: pawn.coordinate, color: pawn.color, board.moves.count)
        }
        lastMove = board.moves.last
        rotatePlayer()
        checkForDrawOrStaleMate()
    }
}
