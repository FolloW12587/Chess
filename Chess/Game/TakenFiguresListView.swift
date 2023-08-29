//
//  TakenFiguresListView.swift
//  Chess
//
//  Created by Сергей Дубовой on 22.08.2023.
//

import SwiftUI

//struct TakenFiguresListView: View {
//    var figures: [Figure]
//    let size = (getDeviceBounds().width - 20) / 15
//    var points: Int {
//        figures.reduce(0) { partialResult, figure in
//            partialResult + figure.value
//        }
//    }
//    
//    var body: some View {
//        HStack (spacing: 0) {
//            ForEach(figures.sorted().reversed()) { figure in
//                Image(figure.getAssetName())
//                    .resizable()
//                    .scaledToFit()
//                    .frame(width: size, height: size)
//                    .frame(width: figure is Pawn ? size*0.5 : size*0.8)
//            }
//            
//            Spacer(minLength: 0)
//            Text("pts: \(points)")
//                .font(.headline)
//                .foregroundColor(.white)
//        }
//        .padding(10)
//        .frame(maxWidth: .infinity, alignment: .leading)
//        .frame(height: size)
//        .background(
//            RoundedRectangle(cornerRadius: 5)
//                .fill(Color.gray)
//        )
//    }
//}
//
//struct TakenFiguresListView_Previews: PreviewProvider {
//    static var previews: some View {
//        TakenFiguresListView(figures: [Queen(coordinate: Coordinate(x: 1, y: 1), color: .black), Rook(coordinate: Coordinate(x: 1, y: 1), color: .black), Bishop(coordinate: Coordinate(x: 1, y: 1), color: .black), Knight(coordinate: Coordinate(x: 1, y: 1), color: .black)] + Array(repeating: Pawn(coordinate: Coordinate(x: 1, y: 1), color: .black), count: 8))
//    }
//}
