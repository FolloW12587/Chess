//
//  ContentView.swift
//  Chess
//
//  Created by Сергей Дубовой on 30.07.2023.
//

import SwiftUI

struct ContentView: View {
    
    var body: some View {
        MainNavigationView()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
