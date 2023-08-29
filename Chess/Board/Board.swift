//
//  Board.swift
//  Chess
//
//  Created by Сергей Дубовой on 01.08.2023.
//

import Foundation


class Board {
    var squares: [Int] = Array(repeating: 0, count: 64)
    var allPiecesList: [ListOfPieces] = [ListOfPieces(), ListOfPieces()]
    var pawns: [ListOfPieces] = [ListOfPieces(capacity: 8), ListOfPieces(capacity: 8)]
    var knights: [ListOfPieces] = [ListOfPieces(capacity: 10), ListOfPieces(capacity: 10)]
    var bishops: [ListOfPieces] = [ListOfPieces(capacity: 10), ListOfPieces(capacity: 10)]
    var queens: [ListOfPieces] = [ListOfPieces(capacity: 9), ListOfPieces(capacity: 9)]
    var rooks: [ListOfPieces] = [ListOfPieces(capacity: 10), ListOfPieces(capacity: 10)]
    
    var kingSquare: [Int] = [0, 0]
    var materialDiff: Int = 0
    var moves = [Move]()
    
    
    // Bits 0-3 store white and black kingside/queenside castling legality
    // Bits 4-7 store file of ep square (starting at 1, so 0 = no ep square)
    // Bits 8-13 captured piece
    var gameState: Int = 0
    var gameStateHistory: [Int] = []
    
    static let whiteCastleKingsideMask = 0b1111111111111110;
    static let whiteCastleQueensideMask = 0b1111111111111101;
    static let blackCastleKingsideMask = 0b1111111111111011;
    static let blackCastleQueensideMask = 0b1111111111110111;
    
    static let whiteCastleMask = whiteCastleKingsideMask & whiteCastleQueensideMask;
    static let blackCastleMask = blackCastleKingsideMask & blackCastleQueensideMask;
    
    var canWhiteKingsideCastle: Bool {
        ~Board.whiteCastleKingsideMask & gameState == 1
    }
    var canWhiteQueensideCastle: Bool {
        ((~Board.whiteCastleQueensideMask & gameState) >> 1) == 1
    }
    var canBlackKingsideCastle: Bool {
        ((~Board.whiteCastleQueensideMask & gameState) >> 2) == 1
    }
    var canBlackQueensideCastle: Bool {
        ((~Board.whiteCastleQueensideMask & gameState) >> 3) == 1
    }
    
    init(_ fen: String) {
        let info = fen.split(separator: " ")
        let rowsInfo = info[0].split(separator: "/")
        
        for (i, row) in rowsInfo.enumerated() {
            let y = 8 - i
            var x = 1
            
            for char in row {
                if char.isNumber {
                    x += Int(String(char))!
                    continue
                }
                
                let color = char.isUppercase ? Piece.White : Piece.Black
                let colorIndex = Piece.colorIndex(color)
                let figure: Int
                let index = x-1 + (y-1)*8
                
                switch(char.lowercased()){
                case "r":
                    figure = Piece.Rook | color
                    rooks[colorIndex].addPieceAtSquare(index)
                case "n":
                    figure = Piece.Knight | color
                    knights[colorIndex].addPieceAtSquare(index)
                case "b":
                    figure = Piece.Bishop | color
                    bishops[colorIndex].addPieceAtSquare(index)
                case "q":
                    figure = Piece.Queen | color
                    queens[colorIndex].addPieceAtSquare(index)
                case "k":
                    figure = Piece.King | color
                    kingSquare[colorIndex] = index
                case "p":
                    figure = Piece.Pawn | color
                    pawns[colorIndex].addPieceAtSquare(index)
                default:
                    fatalError("Incorrect fen notation!")
                }
                squares[index] = figure
                x += 1
            }
        }
        
        allPiecesList = [
            ListOfPieces(capacity: 0),
            pawns[0],
            ListOfPieces(capacity: 0),
            knights[0],
            bishops[0],
            rooks[0],
            queens[0],
            ListOfPieces(capacity: 0),
            pawns[1],
            ListOfPieces(capacity: 0),
            knights[1],
            bishops[1],
            rooks[1],
            queens[1],
        ]
        
        var castleInfo = info[2]
        if castleInfo != "-" {
            while castleInfo != "" {
                let letter = castleInfo.removeFirst()
                switch letter {
                case "K":
                    gameState |= 1
                case "k":
                    gameState |= 1 << 2
                case "Q":
                    gameState |= 1 << 1
                case "q":
                    gameState |= 1 << 3
                default:
                    fatalError("Can't decode castle info")
                }
            }
        }
        
        let epMoveInfo = info[3]
        if epMoveInfo != "-" {
            let x = epMoveInfo.first!.asciiValue! - 96
            gameState |= Int(x) << 4
        }
        gameStateHistory.append(gameState)
    }
    
    func getPiecesList(_ pieceType: Int, _ colorIndex: Int) -> ListOfPieces {
        allPiecesList[colorIndex*7 + pieceType]
    }
    
    func makeMove(_ move: Move) {
        let moveFrom = move.startedSquare
        let moveTo = move.targetSquare
        let castleState = gameState & 0b1111
        var newCastleState = castleState
        gameState = 0
        
        var movePiece = squares[moveFrom]
        let color = Piece.color(of: movePiece)
        let colorToMoveIndex = Piece.colorIndex(color)
        
        let capturedPiece = squares[moveTo]
        if capturedPiece != 0 && move.flag != Move.Flag.EnPassantCapture {
            getPiecesList(Piece.type(of: capturedPiece), 1 - colorToMoveIndex).removePieceAtSquare(moveTo)
        }
        
        gameState |= capturedPiece << 8
        if Piece.isType(movePiece, Piece.King) {
            kingSquare[Piece.colorIndex(color)] = moveTo
            newCastleState &= color == Piece.White ? Board.whiteCastleMask : Board.blackCastleMask
        } else {
            getPiecesList(Piece.type(of: movePiece), Piece.colorIndex(color)).movePiece(from: moveFrom, to: moveTo)
        }
        
        if move.isPromotion {
            let promoteType: Int
            switch move.flag {
            case Move.Flag.PromoteToQueen:
                promoteType = Piece.Queen
                queens[colorToMoveIndex].addPieceAtSquare(moveTo);
            case Move.Flag.PromoteToRook:
                promoteType = Piece.Rook;
                rooks[colorToMoveIndex].addPieceAtSquare(moveTo);
            case Move.Flag.PromoteToBishop:
                promoteType = Piece.Bishop;
                bishops[colorToMoveIndex].addPieceAtSquare(moveTo);
            case Move.Flag.PromoteToKnight:
                promoteType = Piece.Knight;
                knights[colorToMoveIndex].addPieceAtSquare(moveTo);
            default:
                fatalError("Can't promote to given type!")
            }
            movePiece = promoteType | color;
            pawns[colorToMoveIndex].removePieceAtSquare(moveTo);
        } else {
            switch move.flag {
            case Move.Flag.EnPassantCapture:
                let epPawnSquare = moveTo + ((color == Piece.White) ? -8 : 8);
                gameState |= squares[epPawnSquare] << 8
                squares[epPawnSquare] = 0
                pawns[1 - colorToMoveIndex].removePieceAtSquare(epPawnSquare)
            case Move.Flag.Castling:
                let kingSide = moveTo == 6 || moveTo == 62
                let rookStartingIndex = kingSide ? moveTo + 1 : moveTo - 2
                let rookTargetIndex = kingSide ? moveTo - 1 : moveTo + 1
                
                squares[rookStartingIndex] = 0
                squares[rookTargetIndex] = Piece.Rook | color
                
                rooks[colorToMoveIndex].movePiece(from: rookStartingIndex, to: rookTargetIndex)
            default:
                break
            }
        }
        
        if move.flag == Move.Flag.PawnTwoForward {
            gameState |= (moveFrom % 8) << 4
        }
        
        if castleState != 0 {
            newCastleState = checkMoveForNewCastleState(newCastleState, moveFrom, moveTo)
        }
        
        squares[move.targetSquare] = movePiece
        squares[move.startedSquare] = 0
        gameState |= newCastleState
        gameStateHistory.append(gameState)
    }
    
    private func checkMoveForNewCastleState(_ castleState: Int, _ moveFrom: Int, _ moveTo: Int) -> Int {
        if moveTo == 0 || moveFrom == 0 {
            return castleState & Board.whiteCastleQueensideMask
        }
        if moveTo == 7 || moveFrom == 7 {
            return castleState & Board.whiteCastleKingsideMask
        }
        if moveTo == 55 || moveFrom == 55 {
            return castleState & Board.blackCastleQueensideMask
        }
        if moveTo == 63 || moveFrom == 63 {
            return castleState & Board.blackCastleKingsideMask
        }
        
        return castleState
    }
    
    func undoMove(_ move: Move) {
        let moveFrom = move.startedSquare
        let moveTo = move.targetSquare
        let movePiece = squares[moveTo]
        let color = Piece.color(of: movePiece)
        let colorIndex = Piece.colorIndex(color)
        
        let capturedPiece = gameState >> 8 & 0b11111
        if capturedPiece != 0 && move.flag != Move.Flag.EnPassantCapture {
            getPiecesList(Piece.type(of: capturedPiece), 1 - colorIndex).addPieceAtSquare(moveTo)
        }
        
        if Piece.isType(movePiece, Piece.King) {
            kingSquare[colorIndex] = moveFrom
        } else if !move.isPromotion {
            getPiecesList(Piece.type(of: movePiece), colorIndex).movePiece(from: moveTo, to: moveFrom)
        }
        
        squares[moveFrom] = movePiece
        squares[moveTo] = capturedPiece
        
        if move.isPromotion {
            pawns[colorIndex].addPieceAtSquare(moveFrom)
            switch move.flag {
            case Move.Flag.PromoteToQueen:
                queens[colorIndex].removePieceAtSquare(moveTo);
            case Move.Flag.PromoteToRook:
                rooks[colorIndex].removePieceAtSquare(moveTo);
            case Move.Flag.PromoteToBishop:
                bishops[colorIndex].removePieceAtSquare(moveTo);
            case Move.Flag.PromoteToKnight:
                knights[colorIndex].removePieceAtSquare(moveTo);
            default:
                fatalError("Can't promote to given type!")
            }
        } else if move.flag == Move.Flag.EnPassantCapture {
            squares[moveTo] = 0
            let index = moveTo + (color == Piece.White ? -8 : 8)
            squares[index] = capturedPiece
            pawns[1-colorIndex].addPieceAtSquare(index)
        } else if move.flag == Move.Flag.Castling {
            let kingSide = moveTo == 6 || moveTo == 62
            let rookStartingIndex = kingSide ? moveTo + 1 : moveTo - 2
            let rookTargetIndex = kingSide ? moveTo - 1 : moveTo + 1
            
            squares[rookTargetIndex] = 0
            squares[rookStartingIndex] = Piece.Rook | color
            
            rooks[colorIndex].movePiece(from: rookTargetIndex, to: rookStartingIndex)
        }
        
        gameStateHistory.removeLast()
        gameState = gameStateHistory.last!
    }

    func getKingSquare(_ color: Int) -> Int {
        kingSquare[(color >> 3) / 2]
    }
    
    static let example = Board("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
}
