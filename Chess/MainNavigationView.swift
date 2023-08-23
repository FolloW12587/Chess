//
//  MainNavigationView.swift
//  Chess
//
//  Created by Сергей Дубовой on 21.08.2023.
//

import SwiftUI

struct MainNavigationView: View {
    @State var selectedTab: Tabs?
    
    var body: some View {
        switch selectedTab {
        case .play:
            GameView(selectedTab: $selectedTab)
                .transition(.move(edge: .trailing))
        case .settings:
            ZStack {
                DismissButtonView{
                    withAnimation {
                        selectedTab = nil
                    }
                }
                
                Text("Settings")
                    .font(.title.bold())
            }
            .transition(.move(edge: .trailing))
        default:
            MenuView(selectedTab: $selectedTab)
        }
    }
}

extension MainNavigationView {
    enum Tabs: String, CaseIterable {
        case play, settings
    }
}

struct MainNavigationView_Previews: PreviewProvider {
    static var previews: some View {
        MainNavigationView()
    }
}
