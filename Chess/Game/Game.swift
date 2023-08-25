//
//  Game.swift
//  Chess
//
//  Created by Сергей Дубовой on 07.08.2023.
//

import Foundation

@MainActor
class Game: ObservableObject {
    var board: Board
    
    @Published var currentColor: Figure.Color = .white
    @Published var selectedFigure: Figure? = nil
    @Published var availableMoves: Set<Coordinate> = []
    
    @Published var figuresTakenByColor: [Figure.Color: [Figure]] = [.white: [], .black: []]
    @Published var figuresForUpdate: [Figure] = []
    @Published var kingCheckedCoordinate: Coordinate? = nil
    @Published var lastMove: Move? = nil
    
    @Published var isGameEnded = false
    var winner: Figure.Color? = nil
    
    @Published var materialDiff: Int = 0
    @Published var avgMovesPerSecond = 0
    
    init() {
        self.board = Board(
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
//            "8/1k6/5P2/8/4K3/8/1p6/8 w - - 0 1"
        )
    }
    
    func figureForUpdateTapped(_ figure: Figure) {
        board.upgradePawn(by: figure)
        materialDiff = board.materialDiff
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
    
    @discardableResult func checkForDrawOrStaleMate() -> Bool {
        if board.figures.values.count == 2 {
            // MARK: draw if only 2 kings left
            isGameEnded = true
            return true
        }
        
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
    
    func makeMove(to coordinate: Coordinate) {
        if !board.isSquareEmpty(at: coordinate) {
            figuresTakenByColor[selectedFigure!.color]?.append(board.getFigure(at: coordinate)!)
        }
        if let pawn = board.makeMove(from: selectedFigure!.coordinate, to: coordinate) as? Pawn, pawn.isOnLastLine() {
            prepareFiguresForUpdate(at: coordinate, of: pawn.color)
            return
        }
        lastMove = board.moves.last
        rotatePlayer()
        checkForDrawOrStaleMate()
        materialDiff = board.materialDiff
    }
    
    func prepareFiguresForUpdate(at coordinate: Coordinate, of color: Figure.Color) {
        figuresForUpdate = [
            Knight(coordinate: coordinate, color: color, board.moves.count),
            Rook(coordinate: coordinate, color: color, board.moves.count),
            Bishop(coordinate: coordinate, color: color, board.moves.count),
            Queen(coordinate: coordinate, color: color, board.moves.count),
        ]
    }
    
    func rotatePlayer() {
        selectedFigure = nil
        availableMoves = []
        figuresForUpdate = []
        kingCheckedCoordinate = nil
        currentColor = currentColor.opposite()
        if board.isKingChecked(of: currentColor) {
            kingCheckedCoordinate = board.getKing(currentColor).coordinate
        }
    }
    
    func undoMove() {
        if board.moves.isEmpty {
            return
        }
            
        if board.moves.last?.figureTaken != nil {
            figuresTakenByColor[currentColor.opposite()]?.removeLast()
        }
        board.undoMove()
        lastMove = board.moves.last
        rotatePlayer()
        materialDiff = board.materialDiff
    }
    
    func selectFigure(at coordinate: Coordinate) {
        guard let figure = board.getFigure(at: coordinate), figure.color == currentColor else {
            return
        }
        
        selectedFigure = figure
        availableMoves = figure.getAvailableForMoveCoordinates(board)
    }
    
    func checkForReselect(at coordinate: Coordinate) -> Bool {
        guard selectedFigure != nil, let figure = board.getFigure(at: coordinate), figure.color == selectedFigure?.color else {
            return false
        }
        
        return true
    }
}
