//
//  MenuView.swift
//  Chess
//
//  Created by Сергей Дубовой on 21.08.2023.
//

import SwiftUI

struct MenuView: View {
    @Binding var selectedTab: MainNavigationView.Tabs?
    
    var body: some View {
        VStack (spacing: 0){
            Image("chess")
                .resizable()
                .scaledToFit()
            
            ForEach(MainNavigationView.Tabs.allCases, id: \.self) { tab in
                Button {
                    Task { @MainActor in
                        withAnimation {
                            self.selectedTab = tab
                        }
                    }
                } label: {
                    Text(tab.rawValue.uppercased())
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(minWidth: 180)
                        .background(
                            RoundedRectangle(cornerRadius: 30)
                                .fill(Color.gray)
                        )
                }
                .padding(10)
            }

        }
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView(selectedTab: .constant(nil))
    }
}
