//
//  BoardView.swift
//  Chess
//
//  Created by Сергей Дубовой on 14.08.2023.
//

import SwiftUI

struct BoardView: View {
    @EnvironmentObject var game: Game
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(1...8, id: \.self){ _y in
                HStack(spacing: 0) {
                    ForEach(1...8, id: \.self){ x in
                        let y = 9 - _y
                        let index = (x-1) + (y-1)*8
                        BoardSquareView(square: index, piece: game.board.squares[index])
                            .onTapGesture {
                                game.squareTapped(index)
                            }
                    }
                }
            }
        }
        
    }
    
    
}

struct BoardView_Previews: PreviewProvider {
    static var previews: some View {
        BoardView()
            .environmentObject(Game())
    }
}
