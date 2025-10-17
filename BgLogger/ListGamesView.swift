//
//  ListGamesView.swift
//  BgLogger
//
//  Created by Arsh Sharma on 17/10/25.
//

import SwiftUI

struct ListGamesView: View {
    @State private var games: [Game] = []
    @State private var showingAddGameView: Bool = false
    
    
    var body: some View {
        VStack{
            if games.isEmpty {
                Text("No games yet").foregroundStyle(.secondary)
            } else {
                List(games) { game in
                    HStack {
                        Text(game.name)
                        Spacer()
                        Text(game.creator_name)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
            }
        }
        .navigationTitle("Games")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    showingAddGameView = true
                } label: {
                    Image(systemName: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddGameView) {
            NavigationStack {
                AddGameView()
            }
        }
        .onChange(of: showingAddGameView) { oldValue, newValue in
            if oldValue == true && newValue == false {
                Task {
                    do {
                        games = try await APIService.fetchGames()
                    } catch {
                        print("Error fetching games: \(error)")
                    }
                }
            }
        }
        .task{
            do {
                games = try await APIService.fetchGames()
            } catch {
                print("Error fetching games: \(error)")
            }
        }
    }
}

