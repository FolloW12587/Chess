//
//  Chess
//  MoveGenerator.swift
//
//  Created by Сергей Дубовой on 29.08.2023.
//

import Foundation


class MoveGenerator {
    // down, up
    static let verticalOffsets: [Int] = [-8, 8]
    // left right
    static let horizontalOffsets: [Int] = [-1, 1]
    // bot-left, bot-right, top-left, top-right
    static let diagonalOffsets: [Int] = [-9, -7, 7, 9]
    
    static let rookOffsets = verticalOffsets + horizontalOffsets
    static let queenOffsets = verticalOffsets + horizontalOffsets + diagonalOffsets
    // left to right
    static let knightOffsets: [Int] = [6, -10, -17, 15, 17, -15, -6, 10]
    // pawn attack offsets white left and right and black left and right
    static let pawnAttackOffsets: [[Int]] = [[7, 9], [-9, -7]]
    // pawn move offsets white black
    static let pawnMoveOffsets: [Int] = [8, -8]
    // pawn ep lines white black
    static let pawnEPLine: [Int] = [4, 3]
    
    // king offsets first tree - left from bot to top, then bot and top, then three right from top to bot
    static let kingOffsets: [Int] = [-9, -1, 7, -8, 8, 9, 1, -7]
    
    // contains data for each square (first index) on the board for each type
    //
    static let calculatedSquaresData: [[[[Int]]]] = Bundle.main.decode([[[[Int]]]].self, from: "calculatedData.json")
    
    var moves: [Move] = []
    var board: Board!
    var kingSquare: Int = 0
    var color: Int = 0
    var colorIndex: Int = 0
    
    var inCheck = false
    var inDoubleCheck = false
    var hasPins = false
    var checkRayBitmask: UInt64 = 0
    var pinRayBitmask: UInt64 = 0
    var opponentAttackMask: UInt64 = 0
    
    func isSquareUnderAttack(_ square: Int) -> Bool {
        (opponentAttackMask >> square) & 1 == 1
    }
    
    func isSquarePinned(_ square: Int) -> Bool {
        hasPins && ((pinRayBitmask >> square) & 1 == 1)
    }
    
    func isSquareInCheckRay(_ square: Int) -> Bool {
        inCheck && ((checkRayBitmask >> square) & 1 == 1)
    }
    
    func isOnDirection(_ startSquare: Int, _ targetSquare: Int, _ direction: Int) -> Bool {
        if abs(direction) > 1 {
            return (targetSquare - startSquare) % direction == 0
        }
        return (targetSquare / 8) == (startSquare / 8)
    }
    
    func generateMoves(board: Board, color: Int) -> [Move] {
        clear()
        
        self.board = board
        self.color = color
        self.colorIndex = Piece.colorIndex(color)
        self.kingSquare = board.getKingSquare(color)
        
        updateAttackData()
        generateKingMoves()
        
        if inDoubleCheck {
            return moves
        }
        
        generateSlidingPieceMoves(board.queens[colorIndex], MoveGenerator.queenOffsets, Piece.Queen)
        generateSlidingPieceMoves(board.rooks[colorIndex], MoveGenerator.rookOffsets, Piece.Rook)
        generateSlidingPieceMoves(board.bishops[colorIndex], MoveGenerator.diagonalOffsets, Piece.Bishop)
        generateKnightMoves(board.knights[colorIndex])
        generatePawnMoves(board.pawns[colorIndex])
        
        return moves
    }
    
    func clear() {
        moves = []
        checkRayBitmask = 0
        pinRayBitmask = 0
        opponentAttackMask = 0
        inCheck = false
        inDoubleCheck = false
        hasPins = false
    }
    
    func updateAttackData() {
        updateSlidingPieceAttackData(board.queens[1 - colorIndex], Piece.Queen)
        updateSlidingPieceAttackData(board.bishops[1 - colorIndex], Piece.Bishop)
        updateSlidingPieceAttackData(board.rooks[1 - colorIndex], Piece.Rook)
        updateKnightsAttackData(board.knights[1 - colorIndex])
        updatePawnsAttackData(board.pawns[1 - colorIndex])
        
        if inDoubleCheck {
            return
        }
        
        updateRays()
    }
    
    func updateSlidingPieceAttackData(_ pieces: ListOfPieces, _ pieceType: Int) {
        for i in 0..<pieces.piecesCount {
            let startSquare = pieces[i]
            let calculatedData = MoveGenerator.calculatedSquaresData[startSquare][pieceType]
            for directionData in calculatedData {
                for targetSquare in directionData {
                    let piece = board.squares[targetSquare]
                    
                    opponentAttackMask |= 1 << targetSquare
                    if piece != 0 {
                        // looks through king square
                        if targetSquare != kingSquare {
                            break
                        }
                        inDoubleCheck = inCheck
                        inCheck = true
                    }
                }
            }
        }
    }
    
    func updateKnightsAttackData(_ pieces: ListOfPieces) {
        for i in 0..<pieces.piecesCount {
            let startSquare = pieces[i]
            let calculatedData = MoveGenerator.calculatedSquaresData[startSquare][Piece.Knight][0]
            for square in calculatedData {
                opponentAttackMask |= 1 << square
                if square == kingSquare {
                    inDoubleCheck = inCheck
                    inCheck = true
                    checkRayBitmask |= 1 << startSquare
                }
            }
        }
    }
    
    func updatePawnsAttackData(_ pieces: ListOfPieces) {
        for i in 0..<pieces.piecesCount {
            let startSquare = pieces[i]
            let calculatedData = MoveGenerator.calculatedSquaresData[startSquare][1 - colorIndex][1]
            for square in calculatedData {
                opponentAttackMask |= 1 << square
                if square == kingSquare {
                    inDoubleCheck = inCheck
                    inCheck = true
                    checkRayBitmask |= 1 << startSquare
                }
            }
        }
    }
    
    func updateRays() {
        let calculatedData = MoveGenerator.calculatedSquaresData[kingSquare][Piece.Queen]
        
        for (i, directionData) in calculatedData.enumerated() {
            let isDiagonalRay = i > 3
            var rayMask: UInt64 = 0
            var isFriendPieceOnTheWay = false
            
            for square in directionData {
                rayMask |= 1 << square
                
                let piece = board.squares[square]
                if piece == 0 {
                    continue
                }
                
                if Piece.isColor(piece, color) {
                    if isFriendPieceOnTheWay {
                        break
                    }
                    
                    isFriendPieceOnTheWay = true
                    continue
                }
                
                if (Piece.isType(piece, Piece.Queen) ||  isDiagonalRay && Piece.isType(piece, Piece.Bishop) || !isDiagonalRay && Piece.isType(piece, Piece.Rook)){
                    if isFriendPieceOnTheWay {
                        pinRayBitmask |= rayMask
                        hasPins = true
                        break
                    }
                    
                    checkRayBitmask |= rayMask
                    break
                }
                break
            }
        }
    }
    
    
    func generateKingMoves() {
        let calculatedData = MoveGenerator.calculatedSquaresData[kingSquare][Piece.King][0]
        for square in calculatedData {
            let piece = board.squares[square]
            if Piece.isColor(piece, color) || isSquareUnderAttack(square){
                continue
            }
            moves.append(Move(kingSquare, square))
        }
        
        if inCheck {
            return
        }
        
        // check for castle
        if color == Piece.White && board.canWhiteKingsideCastle {
            if board.squares[5] == 0 && board.squares[6] == 0 && !isSquareUnderAttack(5) && !isSquareUnderAttack(6) {
                moves.append(Move(kingSquare, 6, Move.Flag.Castling))
            }
        }
        if color == Piece.White && board.canWhiteQueensideCastle {
            if board.squares[3] == 0 && board.squares[2] == 0 && board.squares[1] == 0 && !isSquareUnderAttack(3) && !isSquareUnderAttack(2) {
                moves.append(Move(kingSquare, 2, Move.Flag.Castling))
            }
        }
        if color == Piece.Black && board.canBlackKingsideCastle {
            if board.squares[61] == 0 && board.squares[62] == 0 && !isSquareUnderAttack(61) && !isSquareUnderAttack(62) {
                moves.append(Move(kingSquare, 62, Move.Flag.Castling))
            }
        }
        if color == Piece.Black && board.canBlackQueensideCastle {
            if board.squares[59] == 0 && board.squares[58] == 0 && board.squares[57] == 0 && !isSquareUnderAttack(59) && !isSquareUnderAttack(58) {
                moves.append(Move(kingSquare, 58, Move.Flag.Castling))
            }
        }
    }
    
    func generateSlidingPieceMoves(_ pieces: ListOfPieces, _ offsets: [Int], _ pieceType: Int) {
        for i in 0..<pieces.piecesCount {
            let startSquare = pieces[i]
            let isPinned = isSquarePinned(startSquare)
            if inCheck && isPinned {
                continue
            }
            let calculatedData = MoveGenerator.calculatedSquaresData[startSquare][pieceType]
            for (j, directionData) in MoveGenerator.calculatedSquaresData[startSquare][pieceType].enumerated() {
                if isPinned && !isOnDirection(startSquare, kingSquare, offsets[j]) {
                    continue
                }

                for square in directionData {
                    let piece = board.squares[square]
                    if Piece.isColor(piece, color) {
                        break
                    }
                    let preventsCheck = isSquareInCheckRay(square)
                    if preventsCheck || !inCheck {
                        moves.append(Move(startSquare, square))
                    }
                    
                    if piece != 0 || preventsCheck {
                        break
                    }
                }
                
            }
        }
    }
    
    func generateKnightMoves(_ pieces: ListOfPieces) {
        for i in 0..<pieces.piecesCount {
            let startSquare = pieces[i]
            if isSquarePinned(startSquare) {
                continue
            }
            for square in MoveGenerator.calculatedSquaresData[startSquare][Piece.Knight][0] {
                let piece = board.squares[square]
                if Piece.isColor(piece, color) || (inCheck && !isSquareInCheckRay(square)) {
                    continue
                }
                moves.append(Move(startSquare, square))
            }
        }
    }
    
    func generatePawnMoves(_ pieces: ListOfPieces) {
        var epX = (board.gameState >> 4) & 0b1111
        let hasEPPossibility = epX > 0
        epX -= 1
        for i in 0..<pieces.piecesCount {
            let startSquare = pieces[i]
            
            let isPinned = isSquarePinned(startSquare)
            let calculatedData = MoveGenerator.calculatedSquaresData[startSquare][colorIndex]
            let onEPLine = calculatedData[2][0] == 1
            let onPromotionLine = calculatedData[2][1] == 1
            
            for (j, moveSquare) in calculatedData[0].enumerated() {
                if isPinned && !isOnDirection(startSquare, kingSquare, MoveGenerator.pawnMoveOffsets[colorIndex]) || board.squares[moveSquare] != 0 {
                    break
                }
                let flag = j == 0 ? 0 : Move.Flag.PawnTwoForward
                if !inCheck || isSquareInCheckRay(moveSquare) {
                    if onPromotionLine {
                        moves.append(Move(startSquare, moveSquare, Move.Flag.PromoteToQueen))
                        moves.append(Move(startSquare, moveSquare, Move.Flag.PromoteToRook))
                        moves.append(Move(startSquare, moveSquare, Move.Flag.PromoteToBishop))
                        moves.append(Move(startSquare, moveSquare, Move.Flag.PromoteToKnight))
                    } else {
                        moves.append(Move(startSquare, moveSquare, flag))
                    }
                }
            }
            
            for targetSquare in calculatedData[1] {
                let piece = board.squares[targetSquare]
                if Piece.isColor(piece, color) || (isPinned && !isOnDirection(startSquare, kingSquare, targetSquare-startSquare)) || (inCheck && !isSquareInCheckRay(targetSquare)) {
                    continue
                }
                
                if piece != 0 {
                    if onPromotionLine {
                        moves.append(Move(startSquare, targetSquare, Move.Flag.PromoteToQueen))
                        moves.append(Move(startSquare, targetSquare, Move.Flag.PromoteToRook))
                        moves.append(Move(startSquare, targetSquare, Move.Flag.PromoteToBishop))
                        moves.append(Move(startSquare, targetSquare, Move.Flag.PromoteToKnight))
                    } else {
                        moves.append(Move(startSquare, targetSquare))
                    }
                    continue
                }
                if hasEPPossibility && onEPLine {
                    let x = targetSquare % 8
                    if x == epX && !isInCheckAfterEPCapture(x, MoveGenerator.pawnEPLine[colorIndex]){
                        let piece = board.squares[targetSquare - MoveGenerator.pawnMoveOffsets[colorIndex]]
                        moves.append(Move(startSquare, targetSquare, Move.Flag.EnPassantCapture))
                    }
                }
            }
        }
    }
    
    func isInCheckAfterEPCapture(_ x: Int, _ y: Int) -> Bool {
        let kingY = kingSquare / 8
        if kingY != y {
            return false
        }
        let kingX = kingSquare % 8
        let offset = x - kingX > 0 ? 1 : -1
        var currentX = x + offset
        while currentX < 8 || currentX > -1 {
            let square = currentX + y*8
            let piece = board.squares[square]
            currentX += offset
            if piece == 0 {
                continue
            }
            if Piece.isColor(piece, color) {
                return false
            }
            if Piece.isType(piece, Piece.Rook) || Piece.isType(piece, Piece.Queen) {
                return true
            }
        }
        return false
    }
}
