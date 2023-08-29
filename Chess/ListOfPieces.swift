//
//  class ListOfPieces.swift
//  Chess
//
//  Created by Сергей Дубовой on 26.08.2023.
//

import Foundation

class ListOfPieces {
    var piecesCount: Int = 0
    // Map to go from index of a square, to the index in the occupiedSquares array where that square is stored
    var map: [Int]
    var piecesSquares: [Int]
    
    init(capacity: Int = 16) {
        self.map = Array(repeating: -1, count: 64)
        self.piecesSquares = Array(repeating: -1, count: capacity)
    }
    
    func addPieceAtSquare(_ square: Int) {
        piecesSquares[piecesCount] = square
        map[square] = piecesCount
        piecesCount += 1
    }
    
    func removePieceAtSquare(_ square: Int) {
        let index = map[square]
        piecesSquares[index] = piecesSquares[piecesCount-1]
        map[piecesSquares[index]] = index
        piecesCount -= 1
    }
    
    func movePiece(from: Int, to: Int) {
        let index = map[from]
        piecesSquares[index] = to
        map[to] = index
    }
    
    subscript(index: Int) -> Int {
        piecesSquares[index]
    }
}
