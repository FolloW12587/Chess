//
//  Game.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

@MainActor
class Game: ObservableObject {
    @Published var board: Board
    
    @Published var currentColor: Figure.Color = .white
    @Published var selectedFigure: Figure? = nil
    @Published var availableMoves: Set<Coordinate> = []
    
    @Published var figuresTakenByColor: [Figure.Color: [Figure]] = [.white: [], .black: []]
    @Published var figuresForUpdate: [Figure] = []
    @Published var kingCheckedCoordinate: Coordinate? = nil
    
    @Published var isGameEnded = false
    var winner: Figure.Color? = nil
    
    init() {
        self.board = Board(
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
//            "r1bqkb1r/pP1p2pp/5p2/3Q4/2B1Kn2/3p2B1/P1PPPPPP/RN4NR w HAkq - 0 1"
//            "rnbqkb1r/pp1p2pp/5p2/1p1Q4/2B1Kn2/1P1p2B1/P1PPPPPP/RN4NR w HAkq - 0 1"
        )
    }
    
    func figureForUpdateTapped(_ figure: Figure) {
        board.figures[figure.coordinate] = figure
        rotatePlayer()
        checkForDrawOrStaleMate()
    }
    
    func squareTapped(at coordinate: Coordinate) {
        if isGameEnded {
            return
        }
        
        if coordinate == selectedFigure?.coordinate {
            selectedFigure = nil
            availableMoves = []
            return
        }
        
        if selectedFigure == nil || checkForReselect(at: coordinate) {
            selectFigure(at: coordinate)
            return
        }

        if !availableMoves.contains(coordinate) {
            return
        }
        
        makeMove(to: coordinate)
    }
    
    @discardableResult private func checkForDrawOrStaleMate() -> Bool {
        for figure in board.getFigures(currentColor) {
            if figure.getAvailableForMoveCoordinates(board).count > 0 {
                return false
            }
        }
        
        if board.isKingChecked(of: currentColor) {
            winner = currentColor.opposite()
        }
        
        isGameEnded = true
        return true
    }
    
    private func makeMove(to coordinate: Coordinate) {
        if !board.isSquareEmpty(at: coordinate) {
            figuresTakenByColor[selectedFigure!.color]?.append(board.getFigure(at: coordinate)!)
        }
        if let pawn = board.makeMove(from: selectedFigure!.coordinate, to: coordinate) as? Pawn, pawn.isOnLastLine() {
            prepareFiguresForUpdate(at: coordinate, of: pawn.color)
            return
        }
        rotatePlayer()
        checkForDrawOrStaleMate()
    }
    
    private func prepareFiguresForUpdate(at coordinate: Coordinate, of color: Figure.Color) {
        figuresForUpdate = [
            Knight(coordinate: coordinate, color: color),
            Rook(coordinate: coordinate, color: color),
            Bishop(coordinate: coordinate, color: color),
            Queen(coordinate: coordinate, color: color),
        ]
    }
    
    private func rotatePlayer() {
        selectedFigure = nil
        availableMoves = []
        figuresForUpdate = []
        kingCheckedCoordinate = nil
        currentColor = currentColor.opposite()
        if board.isKingChecked(of: currentColor) {
            kingCheckedCoordinate = board.getKing(currentColor).coordinate
        }
    }
    
    private func selectFigure(at coordinate: Coordinate) {
        guard let figure = board.getFigure(at: coordinate), figure.color == currentColor else {
            return
        }
        
        selectedFigure = figure
        availableMoves = figure.getAvailableForMoveCoordinates(board)
    }
    
    private func checkForReselect(at coordinate: Coordinate) -> Bool {
        guard selectedFigure != nil, let figure = board.getFigure(at: coordinate), figure.color == selectedFigure?.color else {
            return false
        }
        
        return true
    }
}
