//
//  AddPlayView.swift
//  BgLogger
//
//  Created by Arsh Sharma on 03/10/25.
//


import SwiftUI

struct AddPlayView: View {
    @Environment(\.dismiss) var dismiss
    
    @State private var games: [Game] = []
    @State private var players: [Player] = []
    @State private var selectedGame: Game?
    @State private var selectedPlayers: Set<Player> = []
    @State private var showSelectPlayers = false
    @State private var isSubmitting: Bool = false
    @State private var showSuccess: Bool = false
    
    var body: some View {
        VStack {
            if games.isEmpty  {
                ProgressView("Loading...")
                    .task {
                        do {
                            games = try await APIService.fetchGames()
                            players = try await APIService.fetchPlayers()
                        } catch {
                            print("Error fetching data: \(error)")
                        }
                    }
            } else {
                Form {
                    Section(header: Text("Select Game")) {
                        Picker("Game", selection: $selectedGame) {
                            Text("Select a game").tag(Optional<Game>.none)
                            ForEach(games) { game in
                                Text(game.name).tag(Optional(game))
                            }
                        }
                        
                    }
                    
                    Section(header: Text("Select Players")) {
                        if selectedPlayers.isEmpty {
                            Text("No players selected")
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(selectedPlayers), id: \.id) { player in
                                Text(player.name)
                            }
                        }
                        
                        Button("Select Players") {
                            showSelectPlayers = true
                        }
                    }
                    
                    Section {
                        Button {
                            Task { await recordPlay() }
                        } label: {
                            if isSubmitting {
                                ProgressView()
                            } else {
                                Text("Record Play")
                                    .frame(maxWidth: .infinity)
                            }
                        }
                        .disabled(selectedGame == nil || selectedPlayers.isEmpty)
                    }
                }
            }
        }
        .navigationTitle("Record Play")
        .sheet(isPresented: $showSelectPlayers) {
            NavigationStack{
                SelectPlayersView(selectedPlayers: $selectedPlayers)
            }
        }
        .alert("Play recorded!", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                dismiss()
            }
        }
    }
    
    private func recordPlay() async {
        guard let selectedGame = selectedGame else { return }
        
        isSubmitting = true
        defer { isSubmitting = false }
        
        // send a create play request to the API
        guard let createPlayURL = URL(string: "http://localhost:3000/api/plays") else { return }
        
        let newPlay = ["game_id": selectedGame.id.uuidString]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: newPlay) else { return }
        
        var playRequest = URLRequest(url: createPlayURL)
        playRequest.httpMethod = "POST"
        playRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        playRequest.httpBody = jsonData
        
        do {
            let (data,_) = try await URLSession.shared.data(for: playRequest)
            print(String(data: data, encoding: .utf8) ?? "no response") // for debugging
            
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            
            let wrapper = try decoder.decode(PlayResponseWrapper.self, from: data)
            let createdPlay = wrapper.data.play.Ok
            
            for player in selectedPlayers {
                await addParticipant(playId: createdPlay.id,playerId: player.id)
            }
            
            showSuccess = true
            
        } catch {
            print("Failed to record play: \(error)")
        }
    }
    
    private func addParticipant(playId: UUID, playerId: UUID) async {
        guard let url = URL(string: "http://localhost:3000/api/playparticipants") else { return }
        let participant = ["play_id": playId.uuidString, "player_id": playerId.uuidString]
        guard let jsonData = try? JSONSerialization.data(withJSONObject: participant) else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData
        
        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            if let httpResponse = response as? HTTPURLResponse {
                print("Added participant \(playerId): \(httpResponse.statusCode)")
            }
        } catch {
            print("Failed to add participant: \(error)")
        }
    }
}
