//
//  PlayHistoryView.swift
//  BgLogger
//
//  Created by Arsh Sharma on 13/10/25.
//

import SwiftUI

struct PlayHistoryView: View {
    
    @State private var plays: [Play] = []
    @State private var games: [Game] = []
    @State private var players: [Player] = []
    @State private var playParticipants: [PlayParticipant] = []
    @State private var isLoading: Bool = true
    @State private var showRecordPlay = false
    
    private var groupedPlays: [Date: [Play]] {
        Dictionary(grouping: plays) { play in
            Calendar.current.startOfDay(for: play.created_at)
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if isLoading {
                    ProgressView("Loading play history...")
                } else if plays.isEmpty {
                    Text("No recorded games found.")
                        .foregroundStyle(.secondary)
                } else {
                    List {
                        ForEach(groupedPlays.keys.sorted(by: >), id: \.self) { date in
                            Section(header: Text(sectionHeader(for: date))) {
                                ForEach(
                                    (groupedPlays[date] ?? []).sorted(by: { $0.created_at > $1.created_at }),
                                ) { play in
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(gameName(for: play.game_id))
                                            .font(.headline)
                                        Text(playerNames(for: play))
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }
            .navigationTitle("Play History")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showRecordPlay = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showRecordPlay) {
                NavigationStack {
                    RecordSessionView()
                }
            }
            .onChange(of: showRecordPlay) { oldValue, newValue in
                if oldValue == true && newValue == false {
                    Task {
                        await loadData()
                    }
                }
            }
            .task {
                await loadData()
            }
        }
    }
    
    private func loadData() async {
        do {
            async let allPlays: [Play]  = APIService.fetchPlays()
            async let allGames: [Game] = APIService.fetchGames()
            async let allPlayers: [Player] = APIService.fetchPlayers()
            async let allParticipants: [PlayParticipant] = APIService.fetchAllPlayParticipants()
            
            let (playsResult, gamesResult, playersResult, participantsResult) = try await (
                allPlays,
                allGames,
                allPlayers,
                allParticipants
            )
            
            self.plays = playsResult
            self.games = gamesResult
            self.players = playersResult
            self.playParticipants = participantsResult
            
        } catch {
            print("Error loading play history: \(error)")
        }
        isLoading = false
    }
    
    private func sectionHeader(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d, yyyy"
        return formatter.string(from: date)
    }
    
    private func gameName(for gameId: UUID) -> String {
        games.first(where: { $0.id == gameId })?.name ?? "Unknown Game"
    }
    
    private func playerNames(for play: Play) -> String {
        let participants = playParticipants.filter { $0.play_id == play.id}
        let names = participants.compactMap { participant in
            players.first(where: { $0.id == participant.player_id })?.name
        }
        return names.joined(separator: ",")
    }
}

