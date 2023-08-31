//
//  GameView.swift
//  Chess
//
//  Created by Сергей Дубовой on 21.08.2023.
//

import SwiftUI

struct GameView: View {
    @StateObject var game = Game(fen: "r4rk1/1pp1qppp/p1np1n2/2b1p1B1/2B1P1b1/P1NP1N2/1PP1QPPP/R4RK1 w - - 0 10")
    @Binding var selectedTab: MainNavigationView.Tabs?
    
    var body: some View {
        ZStack {
            DismissButtonView {
                withAnimation {
                    selectedTab = nil
                }
            }
                
            VStack {
                Text("\(game.materialDiff)")
                
//                TakenFiguresListView(figures: game.figuresTakenByColor[.black]!)
                BoardView()
                    .environmentObject(game as Game)
                    .disabled(game.isGameEnded)

//                TakenFiguresListView(figures: game.figuresTakenByColor[.white]!)
                
//                Button {
////                    game.undoMove()
//                } label: {
//                    Text("Undo".uppercased())
//                        .font(.title3.bold())
//                        .foregroundColor(.white)
//                        .padding(10)
//                        .frame(minWidth: 150)
//                        .background(
//                            RoundedRectangle(cornerRadius: 10)
//                                .fill(.green)
//                        )
//                }
                
                Button {
                    game.searchTapped()
                } label: {
                    Text("Start Search".uppercased())
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
            
            if game.promoteAtSquare != -1 {
                Color.gray
                    .opacity(0.7)
                    .ignoresSafeArea()
                
                HStack {
                    Image(Piece.assetName(of: Piece.Queen | game.colorTurn))
                        .resizable()
                        .scaledToFit()
                        .frame(width: (getDeviceBounds().width - 50) / 4, height: (getDeviceBounds().width - 50) / 4)
                        .onTapGesture {
                            game.promotePieceTypeChosen(Move.Flag.PromoteToQueen)
                        }
                    Image(Piece.assetName(of: Piece.Bishop | game.colorTurn))
                        .resizable()
                        .scaledToFit()
                        .frame(width: (getDeviceBounds().width - 50) / 4, height: (getDeviceBounds().width - 50) / 4)
                        .onTapGesture {
                            game.promotePieceTypeChosen(Move.Flag.PromoteToBishop)
                        }
                    Image(Piece.assetName(of: Piece.Rook | game.colorTurn))
                        .resizable()
                        .scaledToFit()
                        .frame(width: (getDeviceBounds().width - 50) / 4, height: (getDeviceBounds().width - 50) / 4)
                        .onTapGesture {
                            game.promotePieceTypeChosen(Move.Flag.PromoteToRook)
                        }
                    Image(Piece.assetName(of: Piece.Knight | game.colorTurn))
                        .resizable()
                        .scaledToFit()
                        .frame(width: (getDeviceBounds().width - 50) / 4, height: (getDeviceBounds().width - 50) / 4)
                        .onTapGesture {
                            game.promotePieceTypeChosen(Move.Flag.PromoteToKnight)
                        }
                }
            }
            
            if game.isGameEnded {
                VStack {
//                    if let winner = game.winner {
//                        Text("Победа \(winner == .white ? "Белых" : "Черных")!".capitalized)
//                            .font(.title.bold())
//                    } else {
                        Text("Игра окончена")
                            .font(.title.bold())
//                    }
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
