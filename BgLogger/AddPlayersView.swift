//
//  AddPlayersView.swift
//  BgLogger
//
//  Created by Arsh Sharma on 03/10/25.
//

import SwiftUI

struct AddPlayersView: View {
    @State private var players: [Player] = []
    @State private var showingAddPlayer = false
    @State private var newPlayerName: String = ""
    
    var body: some View {
        VStack{
            if players.isEmpty {
                Text("No players yet").foregroundStyle(.secondary)
            } else {
                List(players) { player in
                        HStack{
                        Text(player.name)
                            if player.is_owner {
                                Spacer()
                                Text("(You)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                    }
                }
            }
        }
        .navigationTitle("Players")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    self.showingAddPlayer.toggle()
                }) {
                    Image(systemName: "plus")
                }
            }
        }
        .task{
            await fetchPlayers()
        }
        .alert("Add New Player", isPresented: $showingAddPlayer){
            TextField("Player name", text: $newPlayerName)
            Button("Cancel", role: .cancel) {}
            Button("Add") {
                Task {
                    await addPlayer(name: newPlayerName)
                    newPlayerName = ""
                }
            }
        }
    }
    
    private func fetchPlayers() async {
        guard let url = URL(string: "http://localhost:3000/api/players") else { return }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            players = try decoder.decode(PlayersResponse.self, from: data).players
        } catch {
            print("Failed to fetch players: \(error)")
        }
    }
    
    private func addPlayer(name: String) async {
        guard let url = URL(string: "http://localhost:3000/api/players") else { return }
        
        let newPlayer: [String: Any] = ["name": name, "is_owner": false]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newPlayer, options: []) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("POST status: \(httpResponse.statusCode)")
            }
            await fetchPlayers()
        } catch {
            print("Failed to add player: \(error)")
        }
    }
}
