//
//  GameView.swift
//  Chess
//
//  Created by Сергей Дубовой on 21.08.2023.
//

import SwiftUI

struct GameView: View {
    @StateObject var game = Game()
    @Binding var selectedTab: MainNavigationView.Tabs?
    
    var body: some View {
        ZStack {
            DismissButtonView {
                withAnimation {
                    selectedTab = nil
                }
            }
                
            VStack {
                TakenFiguresListView(figures: game.figuresTakenByColor[.black]!)
                BoardView(board: game.board)
                    .environmentObject(game)
                    .disabled(game.isGameEnded)
                TakenFiguresListView(figures: game.figuresTakenByColor[.white]!)
            }
            
            if !game.figuresForUpdate.isEmpty {
                Color.gray
                    .opacity(0.7)
                    .ignoresSafeArea()
                
                HStack {
                    ForEach(game.figuresForUpdate) { figure in
                        Image(figure.getAssetName())
                            .resizable()
                            .scaledToFit()
                            .frame(width: (getDeviceBounds().width - 50) / 4, height: (getDeviceBounds().width - 50) / 4)
                            .onTapGesture {
                                game.figureForUpdateTapped(figure)
                            }
                    }
                }
            }
            
            if game.isGameEnded {
                VStack {
                    Text("Game Over!".uppercased())
                        .font(.title.bold())
                    
                    if let winner = game.winner {
                        Text("\(winner.rawValue) won".capitalized)
                    } else {
                        Text("Draw")
                    }
                }
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(selectedTab: .constant(.play))
    }
}
