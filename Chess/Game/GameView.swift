//
//  GameView.swift
//  Chess
//
//  Created by Сергей Дубовой on 21.08.2023.
//

import SwiftUI

struct GameView: View {
//    @StateObject var game = Game()
//    @StateObject var game = GameAI(.white)
    @StateObject var game = GameAIvsAI()
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
                
                TakenFiguresListView(figures: game.figuresTakenByColor[.black]!)
                BoardView()
                    .environmentObject(game as Game)
                    .disabled(game.isGameEnded)
                    .onChange(of: game.currentColor) { newValue in
                        if let game = game as? GameAIvsAI {
                            Task {
                                try? await Task.sleep(nanoseconds: 250000000)
                                game.makeMove()
                            }
                        }
                    }
                    .onAppear {
                        if let game = game as? GameAIvsAI {
                            game.makeMove()
                        }
                    }
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

                Text("AVG moves per 0.001 seconds: \(game.avgMovesPerSecond / 1000)")
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
