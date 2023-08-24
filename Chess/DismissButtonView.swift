//
//  DismissButtonView.swift
//  Chess
//
//  Created by Сергей Дубовой on 22.08.2023.
//

import SwiftUI

struct DismissButtonView: View {
    var action: () -> ()
    
    var body: some View {
        VStack {
            HStack {
                Button(action: action){
                    Image(systemName: "chevron.left")
                        .padding()
                        .foregroundColor(.white)
                }
                Spacer()
            }
            Spacer()
        }
    }
}

struct DismissButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DismissButtonView(){}
    }
}
