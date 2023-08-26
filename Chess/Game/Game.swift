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
    @Published var availableMoves: Set<Move> = []
    
    @Published var figuresTakenByColor: [Figure.Color: [Figure]] = [.white: [], .black: []]
    @Published var figuresForUpdate: [Figure] = []
    @Published var kingCheckedCoordinate: Coordinate? = nil
    @Published var lastMove: Move? = nil
    
    @Published var isGameEnded = false
    var winner: Figure.Color? = nil
    
    @Published var materialDiff: Int = 0
    @Published var isPaused: Bool = false
    @Published var avgMovesPerSecond = 0
    
    init() {
        self.board = Board(
            "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
//            "8/pppppppp/PPPPPPPP/8/4k3/8/8/4K3 w - - 0 1"
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

        if let move = availableMoves.compactMap({ move in
            move.to == coordinate ? move : nil
        }).first {
            makeMove(move)
        }
        
    }
    
    @discardableResult func checkForDrawOrStaleMate() -> Bool {
        if board.figures.values.count == 2 {
            // MARK: draw if only 2 kings left
            isGameEnded = true
            return true
        }
        
        for figure in board.getFigures(currentColor) {
            if figure.getAvailableMoves(board).count > 0 {
                return false
            }
        }
        
        if board.isKingChecked(of: currentColor) {
            winner = currentColor.opposite()
        }
        
        isGameEnded = true
        return true
    }
    
    func makeMove(_ move: Move) {
        if let figure = move.figureTaken {
            figuresTakenByColor[selectedFigure!.color]?.append(figure)
        }
        if let pawn = board.makeMove(move: move) as? Pawn, pawn.isOnLastLine {
            prepareFiguresForUpdate(at: pawn.coordinate, of: pawn.color)
            return
        }
        lastMove = move
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
        availableMoves = figure.getAvailableMoves(board)
    }
    
    func checkForReselect(at coordinate: Coordinate) -> Bool {
        guard selectedFigure != nil, let figure = board.getFigure(at: coordinate), figure.color == selectedFigure?.color else {
            return false
        }
        
        return true
    }
}
