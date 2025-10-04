//
//  MenuView.swift
//  BgLogger
//
//  Created by Arsh Sharma on 03/10/25.
//

import SwiftUI

struct MenuView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("What do you want to do?")
                .font(.largeTitle)
                .padding(.bottom, 30)
            
            NavigationLink("➕ Add More Players", destination: AddPlayersView())
            NavigationLink("🎲 Add New Games", destination: AddGamesView())
            NavigationLink("📝 Record a Play Session", destination: RecordSessionView())
            NavigationLink("📊 See Stats", destination: StatsView())
        }
        .padding()
        .navigationTitle("BGLogger Menu")
    }
}
