//
//  BoardSquareView.swift
//  Chess
//
//  Created by Сергей Дубовой on 14.08.2023.
//

import SwiftUI

struct BoardSquareView: View {
    @EnvironmentObject var game: Game
    
    let coordinate: Coordinate
    
    let figure: Figure?
    
    var body: some View {
        ZStack {
            Rectangle()
                .fill((coordinate.y + coordinate.x) % 2 == 0 ? Color(white: 0.4) : Color(white: 0.8))
                .overlay {
                    highLight
                        .padding(5)
                    
                    if let figure {
                        Image(figure.getAssetName())
                            .resizable()
                            .padding(5)
                    }
            }
            
            if coordinate.x == 1 {
                topLeftNotation(coordinate.y)
            }

            if coordinate.y == 1 {
                bottomRightNotation(coordinate.x)
            }
        }
        .frame(width: getDeviceBounds().width / 8, height: getDeviceBounds().width / 8)
    }
    
    var highLight: Color {
        if game.availableMoves.contains(coordinate) {
            return Color.pink.opacity(0.5)
                
        }
        
        if let selectedFigure = game.selectedFigure, selectedFigure.coordinate == coordinate {
            return Color.green.opacity(0.7)
        }
        if let checkedCoordinate = game.kingCheckedCoordinate, coordinate == checkedCoordinate {
            return Color.orange.opacity(0.5)
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
        BoardSquareView(coordinate: Coordinate(x: 1, y: 1), figure: King(coordinate: Coordinate(x: 1, y: 1), color: .white))
            .environmentObject(Game())
    }
}
