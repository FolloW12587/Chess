//
//  GameView.swift
//  Chess
//
//  Created by Сергей Дубовой on 21.08.2023.
//

import SwiftUI

struct GameView: View {
//    @StateObject var game = Game()
    @StateObject var game = GameAI(.white)
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
                    .environmentObject(game as Game)
                    .disabled(game.isGameEnded)
                TakenFiguresListView(figures: game.figuresTakenByColor[.white]!)
                
                Button {
                    game.undoMove()
                } label: {
                    Text("Undo".uppercased())
                        .font(.title3.bold())
                        .foregroundColor(.white)
                        .padding(10)
                        .frame(minWidth: 150)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.green)
                        )
                }

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
                    if let winner = game.winner {
                        Text("Победа \(winner == .white ? "Белых" : "Черных")!".capitalized)
                            .font(.title.bold())
                    } else {
                        Text("Ничья")
                            .font(.title.bold())
                    }
                }
                .foregroundColor(.black)
                .padding(40)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(.white)
                )
            }
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(selectedTab: .constant(.play))
    }
}
