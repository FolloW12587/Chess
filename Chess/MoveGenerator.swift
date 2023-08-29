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
    // clockwise from most bottom left
    static let knightOffsets: [Int] = [-17, -10, 6, 15, 17, 10, -6, -15]
    // pawn attack offsets white left and right and black left and right
    static let pawnAttackOffsets: [[Int]] = [[7, 9], [-7, -9]]
    // pawn move offsets white black
    static let pawnMoveOffsets: [Int] = [8, -8]
    
    // king offsets clockwise from bottom
    static let kingOffsets: [Int] = [-8, -9, -1, 7, 8, 9, 1, -7]
    
    var moves: [Move] = []
    var board: Board!
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
    
    func isOnDirection(_ startingSquare: Int, _ targetSquare: Int, _ direction: Int) -> Bool {
        if abs(direction) > 1 {
            return (targetSquare - startingSquare) % direction == 0
        }
        return (targetSquare / 8) == (startingSquare / 8)
    }
    
    func isOnPromotionLine(_ line: Int) -> Bool {
        (line == 6 && color == Piece.White) || (line == 1 && color == Piece.Black)
    }
    
    func isOnStartingLine(_ line: Int) -> Bool {
        // for pawns
        (line == 1 && color == Piece.White) || (line == 6 && color == Piece.Black)
    }
    
    func isEPLine(_ line: Int) -> Bool {
        (line == 5 && color == Piece.White) || (line == 2 && color == Piece.Black)
    }
    
    
    func generateMoves(board: Board, color: Int) -> [Move] {
        self.board = board
        self.color = color
        self.colorIndex = Piece.colorIndex(color)
        
        updateAttackData()
        generateKingMoves()
        
        if inDoubleCheck {
            return moves
        }
        
        generateSlidingPieceMoves(board.queens[colorIndex], MoveGenerator.queenOffsets)
        generateSlidingPieceMoves(board.rooks[colorIndex], MoveGenerator.rookOffsets)
        generateSlidingPieceMoves(board.bishops[colorIndex], MoveGenerator.diagonalOffsets)
        generateKnightMoves(board.knights[colorIndex])
        generatePawnMoves(board.pawns[colorIndex], MoveGenerator.pawnMoveOffsets[colorIndex], MoveGenerator.pawnAttackOffsets[colorIndex])
        
        return moves
    }
    
    func updateAttackData() {
        updateSlidingPieceAttackData(board.queens[1 - colorIndex], MoveGenerator.queenOffsets)
        updateSlidingPieceAttackData(board.bishops[1 - colorIndex], MoveGenerator.diagonalOffsets)
        updateSlidingPieceAttackData(board.rooks[1 - colorIndex], MoveGenerator.rookOffsets)
        updateKnightsAttackData(board.knights[1 - colorIndex])
        updatePawnsAttackData(board.pawns[1 - colorIndex], MoveGenerator.pawnAttackOffsets[1-colorIndex])
        
        if inDoubleCheck {
            return
        }
        
        updateRays()
    }
    
    func updateSlidingPieceAttackData(_ pieces: ListOfPieces, _ offsets: [Int]) {
        for i in 0..<pieces.piecesCount {
            let startSquare = pieces[i]
            let startSquareX = startSquare % 8
            let startSquareY = startSquare / 8
            for offset in offsets {
                for j in 1...7 {
                    let square = startSquare + offset * j
                    if square > 63 || square < 0 {
                        break
                    }
                    
                    let x = square % 8
                    let y = square / 8
                    guard x == startSquareX || startSquareY == y || abs(startSquareX - x) == abs(startSquareY - y) else {
                        break
                    }
                    
                    let piece = board.squares[square]
                    opponentAttackMask |= 1 << square
                    if piece != 0 {
                        // looks through king square
                        if square != board.getKingSquare(color) {
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
            let startingSquare = pieces[i]
            let startingX = startingSquare % 8
            let startingY = startingSquare / 8
            for offset in MoveGenerator.knightOffsets {
                let square = startingSquare + offset
                guard square > -1 && square < 64 else {
                    continue
                }
                let x = square % 8
                let y = square / 8
                guard abs(startingX-x) + abs(startingY-y) == 3 else {
                    continue
                }
                opponentAttackMask |= 1 << square
                if square == board.getKingSquare(color) {
                    inDoubleCheck = inCheck
                    inCheck = true
                    checkRayBitmask |= 1 << startingSquare
                }
            }
        }
    }
    
    func updatePawnsAttackData(_ pieces: ListOfPieces, _ offsets: [Int]) {
        for i in 0..<pieces.piecesCount {
            let startingSquare = pieces[i]
            let startingSquareY = startingSquare / 8
            for offset in offsets{
                let square = startingSquare + offset
                let y = square / 8
                guard square > -1 && square < 64 && abs(y - startingSquareY) == 1 else {
                    continue
                }
                opponentAttackMask |= 1 << square
                if square == board.getKingSquare(color) {
                    inDoubleCheck = inCheck
                    inCheck = true
                    checkRayBitmask |= 1 << startingSquare
                }
            }
        }
    }
    
    func updateRays() {
        let kingSquare = board.getKingSquare(color)
        let startSquareX = kingSquare % 8
        let startSquareY = kingSquare / 8
        
        for (i, offset) in MoveGenerator.queenOffsets.enumerated() {
            let isDiagonalRay = i > 3
            var rayMask: UInt64 = 0
            var isFriendPieceOnTheWay = false
            
            for j in 1...7 {
                let square = kingSquare + offset * j
                if square > 63 || square < 0 {
                    break
                }
                
                let x = square % 8
                let y = square / 8
                guard x == startSquareX || startSquareY == y || abs(startSquareX - x) == abs(startSquareY - y) else {
                    break
                }
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
            }
        }
    }
    
    
    func generateKingMoves() {
        let kingSquare = board.getKingSquare(color)
        let kingY = kingSquare / 8
        for offset in MoveGenerator.kingOffsets {
            let square = kingSquare - offset
            guard square > -1 && square < 64 else {
                continue
            }
//            let x = square % 8
            let y = square / 8
            guard square > -1 && square < 64 else {
                continue
            }
            if abs(offset) == 1 && y != kingY {
                continue
            }
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
    
    func generateSlidingPieceMoves(_ pieces: ListOfPieces, _ offsets: [Int]) {
        for i in 0..<pieces.piecesCount {
            let startingSquare = pieces[i]
            let isPinned = isSquarePinned(startingSquare)
            if inCheck && isPinned {
                continue
            }
            let startingSquareX = startingSquare % 8
            let startingSquareY = startingSquare / 8
            for offset in offsets {
                if isPinned && !isOnDirection(startingSquare, board.getKingSquare(color), offset) {
                    continue
                }

                for j in 1...7 {
                    let square = startingSquare + offset * j
                    let x = square % 8
                    let y = square / 8
                    guard square > -1 && square < 64 && (x == startingSquareX || startingSquareY == y || abs(startingSquareX - x) == abs(startingSquareY - y)) else {
                        break
                    }
                    
                    let piece = board.squares[square]
                    if Piece.isColor(piece, color) {
                        break
                    }
                    let preventsCheck = isSquareInCheckRay(square)
                    if preventsCheck || !inCheck {
                        moves.append(Move(startingSquare, square))
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
            let startingSquare = pieces[i]
            let isPinned = isSquarePinned(startingSquare)
            if isPinned {
                continue
            }
            let startingX = startingSquare % 8
            let startingY = startingSquare / 8
            for offset in MoveGenerator.knightOffsets {
                let square = startingSquare + offset
                guard square > -1 && square < 64 else {
                    continue
                }
                let x = square % 8
                let y = square / 8
                guard abs(startingX-x) + abs(startingY-y) == 3 else {
                    continue
                }
                let piece = board.squares[square]
                if Piece.isColor(piece, color) || (inCheck && !isSquareInCheckRay(square)) {
                    continue
                }
                moves.append(Move(startingSquare, square))
            }
        }
    }
    
    func generatePawnMoves(_ pieces: ListOfPieces, _ moveOffset: Int, _ attackOffsets: [Int]) {
        let epX = (board.gameState >> 4) & 0b1111
        for i in 0..<pieces.piecesCount {
            let startingSquare = pieces[i]
            let startingSquareY = startingSquare / 8
            let isPinned = isSquarePinned(startingSquare)
            let onPromotionLine = isOnPromotionLine(startingSquareY)
            let onStartingLine = isOnStartingLine(startingSquareY)
            
            let moveSquare = startingSquare + moveOffset
            if board.squares[moveSquare] == 0 {
                if (!isPinned || isOnDirection(startingSquare, board.getKingSquare(color), moveOffset)) && (!inCheck || isSquareInCheckRay(moveSquare)) {
                    if onPromotionLine {
                        moves.append(Move(startingSquare, moveSquare, Move.Flag.PromoteToQueen))
                        moves.append(Move(startingSquare, moveSquare, Move.Flag.PromoteToRook))
                        moves.append(Move(startingSquare, moveSquare, Move.Flag.PromoteToBishop))
                        moves.append(Move(startingSquare, moveSquare, Move.Flag.PromoteToKnight))
                    } else {
                        moves.append(Move(startingSquare, moveSquare))
                        if onStartingLine && board.squares[moveSquare+moveOffset] == 0 {
                            moves.append(Move(startingSquare, moveSquare+moveOffset, Move.Flag.PawnTwoForward))
                        }
                    }
                    
                }
            }
            
            for offset in attackOffsets {
                let targetSquare = startingSquare + offset
                let x = targetSquare % 8
                let y = targetSquare / 8
                guard targetSquare > -1 && targetSquare < 64 && abs(y - startingSquareY) == 1 else {
                    continue
                }
                let piece = board.squares[targetSquare]
                if Piece.isColor(piece, color) || (isPinned && !isOnDirection(startingSquare, board.getKingSquare(color), offset)) || (inCheck && !isSquareInCheckRay(targetSquare)) {
                    continue
                }
                if onPromotionLine {
                    moves.append(Move(startingSquare, targetSquare, Move.Flag.PromoteToQueen))
                    moves.append(Move(startingSquare, targetSquare, Move.Flag.PromoteToRook))
                    moves.append(Move(startingSquare, targetSquare, Move.Flag.PromoteToBishop))
                    moves.append(Move(startingSquare, targetSquare, Move.Flag.PromoteToKnight))
                    continue
                }
                
                if piece != 0 {
                    moves.append(Move(startingSquare, targetSquare))
                    continue
                }
                if isEPLine(y) && x == epX && !isInCheckAfterEPCapture(x, startingSquareY){
                    moves.append(Move(startingSquare, targetSquare, Move.Flag.EnPassantCapture))
                }
            }
        }
    }
    
    func isInCheckAfterEPCapture(_ x: Int, _ y: Int) -> Bool {
        let kingSquare = board.getKingSquare(color)
        let kingY = kingSquare / 8
        if kingY != y {
            return false
        }
        let kingX = kingSquare % 8
        let offset = x - kingX > 0 ? 1 : -1
        var currentX = x + offset
        while currentX < 8 {
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
