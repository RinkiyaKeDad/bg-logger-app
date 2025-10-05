//
//  AddGamesView.swift
//  BgLogger
//
//  Created by Arsh Sharma on 03/10/25.
//


import SwiftUI

struct AddGamesView: View {
    @State private var games: [Game] = []
    @State private var showingAddGameView: Bool = false
    @State private var newGameName: String = ""
    @State private var newGameCreatorName: String = ""
    
    
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
                Button(action: {
                    self.showingAddGameView.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .task{
            await fetchGames()
        }
        .alert("Add New Game", isPresented: $showingAddGameView) {
            TextField("Game name", text: $newGameName)
            TextField("Creator name", text: $newGameCreatorName)
            Button("Cancel", role: .cancel) {}
            Button("Add") {
                Task {
                    await addGame(name: newGameName, creator_name: newGameCreatorName)
                    newGameName = ""
                    newGameCreatorName = ""
                }
            }
        }
    }
    
    private func fetchGames() async {
        guard let url = URL(string: "http://localhost:3000/api/games") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            games = try decoder.decode(GamesResponse.self, from: data).games
        } catch {
            print("Failed to fetch games: \(error)")
        }
    }
    
    private func addGame(name: String, creator_name: String) async {
        guard let url = URL(string: "http://localhost:3000/api/games") else { return }
        
        let newGame: [String: Any] = ["name": name, "creator_name": creator_name]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newGame, options: []) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("POST status: \(httpResponse.statusCode)")
            }
            await fetchGames()
        } catch {
            print("Failed to add game: \(error)")
        }
    }
}

