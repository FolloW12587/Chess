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
    var movesGenerator = MoveGenerator()
    
    @Published var isGameEnded = false
    @Published var selectedSquare: Int = -1
    var moves: [Move] = []
    @Published var highlightedSquares: Set<Int> = []
    @Published var isWhiteTurn = true
    @Published var colorTurn = Piece.White
    
    @Published var promoteAtSquare: Int = -1
    
    @Published var lastMove: Move? = nil
    @Published var materialDiff: Int = 0
    
    init() {
        self.board = Board.example
        moves = movesGenerator.generateMoves(board: board, color: colorTurn)
    }
    
    init(fen: String) {
        self.board = Board(fen)
        
        let turn = fen.split(separator: " ")[1]
        if turn == "w" {
            isWhiteTurn = true
            colorTurn = Piece.White
        } else if turn == "b" {
            isWhiteTurn = false
            colorTurn = Piece.Black
        } else {
            fatalError("Can't understand whose turn it is to move!")
        }
        moves = movesGenerator.generateMoves(board: board, color: colorTurn)
        materialDiff = board.materialDiff
    }

    func promotePieceTypeChosen(_ promoteType: Int) {
        makeMove(move: Move(selectedSquare, promoteAtSquare, promoteType))
    }
    
    func squareTapped(_ square: Int) {
        if isGameEnded {
            return
        }

        if square == selectedSquare {
            selectedSquare = -1
            updateHighlightedSquares()
            return
        }
        
        if selectedSquare == -1 {
            let piece = board.squares[square]
            guard piece != 0, Piece.isColor(piece, colorTurn) else {
                return
            }
            selectedSquare = square
            updateHighlightedSquares()
            return
        }
        
        let filteredMoves = moves.filter { move in
            move.startedSquare == selectedSquare && move.targetSquare == square
        }
        if filteredMoves.count == 0 {
            return
        }
        if filteredMoves.count > 1 {
            promoteAtSquare = square
            return
        }

        makeMove(move: filteredMoves.first!)
    }
    
    func makeMove(move: Move) {
        board.makeMove(move)
        isWhiteTurn = !isWhiteTurn
        colorTurn = Piece.oppositeColor(of: colorTurn)
    
        moves = movesGenerator.generateMoves(board: board, color: colorTurn)
        if moves.isEmpty {
            if movesGenerator.inCheck {
                print("Won \(Piece.oppositeColor(of: colorTurn))")
            } else {
                print("Draw")
            }
            isGameEnded = true
        }
        selectedSquare = -1
        promoteAtSquare = -1
        updateHighlightedSquares()
        materialDiff = board.materialDiff
        lastMove = move
    }
    
    func updateHighlightedSquares() {
        if selectedSquare == -1 {
            highlightedSquares = []
        }
        highlightedSquares = Set(moves.compactMap({ move in
            if move.startedSquare != selectedSquare {
                return nil
            }
            return move.targetSquare
        }))
    }
    
    func searchTapped() {
        let searcher = AISearch()
        let move = searcher.startSearch(at: board, for: colorTurn)
        print(String(reflecting: move))
    }
//
//    @discardableResult func checkForDrawOrStaleMate() -> Bool {
//        if board.figures.values.count == 2 {
//            // MARK: draw if only 2 kings left
//            isGameEnded = true
//            return true
//        }
//
//        for figure in board.getFigures(currentColor) {
//            if figure.getAvailableMoves(board).count > 0 {
//                return false
//            }
//        }
//
//        if board.isKingChecked(of: currentColor) {
//            winner = currentColor.opposite()
//        }
//
//        isGameEnded = true
//        return true
//    }
//
//    func makeMove(_ move: Move) {
//        if let figure = move.figureTaken {
//            figuresTakenByColor[selectedFigure!.color]?.append(figure)
//        }
//        if let pawn = board.makeMove(move: move) as? Pawn, pawn.isOnLastLine {
//            prepareFiguresForUpdate(at: pawn.coordinate, of: pawn.color)
//            return
//        }
//        lastMove = move
//        rotatePlayer()
//        checkForDrawOrStaleMate()
//        materialDiff = board.materialDiff
//    }
//
//    func prepareFiguresForUpdate(at coordinate: Coordinate, of color: Figure.Color) {
//        figuresForUpdate = [
//            Knight(coordinate: coordinate, color: color, board.moves.count),
//            Rook(coordinate: coordinate, color: color, board.moves.count),
//            Bishop(coordinate: coordinate, color: color, board.moves.count),
//            Queen(coordinate: coordinate, color: color, board.moves.count),
//        ]
//    }
//
//    func rotatePlayer() {
//        selectedFigure = nil
//        availableMoves = []
//        figuresForUpdate = []
//        kingCheckedCoordinate = nil
//        currentColor = currentColor.opposite()
//        if board.isKingChecked(of: currentColor) {
//            kingCheckedCoordinate = board.getKing(currentColor).coordinate
//        }
//    }
//
//    func undoMove() {
//        if board.moves.isEmpty {
//            return
//        }
//
//        if board.moves.last?.figureTaken != nil {
//            figuresTakenByColor[currentColor.opposite()]?.removeLast()
//        }
//        board.undoMove()
//        lastMove = board.moves.last
//        rotatePlayer()
//        materialDiff = board.materialDiff
//    }
}
