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
                        let coordinate = Coordinate(x: x, y: y)
                        BoardSquareView(coordinate: coordinate, figure: game.board.getFigure(at: coordinate))
                            .onTapGesture {
                                game.squareTapped(at: coordinate)
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
