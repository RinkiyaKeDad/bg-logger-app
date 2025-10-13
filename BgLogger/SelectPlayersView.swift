//
//  SelectPlayersView.swift
//  BgLogger
//
//  Created by Arsh Sharma on 11/10/25.
//

import SwiftUI

struct SelectPlayersView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var players: [Player] = []
    @Binding var selectedPlayers: Set<Player>
    
    var body: some View {
        VStack{
            if players.isEmpty {
                ProgressView("Loading players...")
                    .task {
                        do {
                            players = try await APIService.fetchPlayers()
                        } catch {
                            print("Error fetching data: \(error)")
                        }
                    }
            } else {
                List(players, id: \.id) { player in
                    HStack {
                        Text(player.name)
                        Spacer()
                        if selectedPlayers.contains(player) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                    .contentShape(Rectangle()) // makes the entire row tappable
                    .onTapGesture {
                        toggleSelection(for: player)
                    }
                }
            }
        }
        .navigationTitle("Select Players")
        .toolbar{
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") {
                    dismiss()
                }
            }
        }
    }
    
    private func toggleSelection (for player: Player) {
        if selectedPlayers.contains(player) {
            selectedPlayers.remove(player)
        } else {
            selectedPlayers.insert(player)
        }
    }
}
