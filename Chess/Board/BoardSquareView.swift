//
//  BoardSquareView.swift
//  Chess
//
//  Created by Сергей Дубовой on 14.08.2023.
//

import SwiftUI

struct BoardSquareView: View {
    @EnvironmentObject var game: Game
    
    let square: Int
    let piece: Int
    
    var x: Int {
        return (square % 8) + 1
    }
    
    var y: Int {
        return (square / 8) + 1
    }
    
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill((x + y) % 2 == 0 ? Color(white: 0.4) : Color(white: 0.8))
                .overlay {
                    if square == game.lastMove?.startedSquare || square == game.lastMove?.targetSquare {
                        Color(red: 255/255, green: 248/255, blue: 100/255)
                            .padding(5)
                            .opacity(0.8)
                    }

                    highLight
                        .padding(5)

                    if piece != 0 {
                        Image(Piece.assetName(of: piece))
                            .resizable()
                            .padding(5)
                    }
                }
            
            if x == 1 {
                topLeftNotation(y)
            }
            
            if y == 1 {
                bottomRightNotation(x)
            }
        }
        .frame(width: getDeviceBounds().width / 8, height: getDeviceBounds().width / 8)
    }
    
    var highLight: Color {
        if game.selectedSquare == square {
            return Color.green.opacity(0.7)
        }
        if game.highlightedSquares.contains(square) {
            return Color.pink.opacity(0.5)
        }
        return Color.clear
    }
    
    func topLeftNotation(_ n: Int) -> some View {
        Text("\(n)")
            .padding(.horizontal, 2)
            .font(.subheadline.bold())
            .foregroundColor(n % 2 == 1 ? .white : .black)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
    
    func bottomRightNotation(_ n: Int) -> some View {
        Text("\(String(UnicodeScalar(96+n)!))")
            .padding(2)
            .font(.subheadline.bold())
            .foregroundColor(n % 2 == 1 ? .white : .black)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
    }
}

struct BoardSquareView_Previews: PreviewProvider {
    static var previews: some View {
        BoardSquareView(square: 0, piece: Piece.King)
            .environmentObject(Game())
    }
}
