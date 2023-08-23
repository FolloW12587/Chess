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
        Button(action: action){
            Image(systemName: "chevron.left")
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .padding()
                .foregroundColor(.white)
        }
    }
}

struct DismissButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DismissButtonView(){}
    }
}
