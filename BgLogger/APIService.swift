//
//  APIService.swift
//  BgLogger
//
//  Created by Arsh Sharma on 06/10/25.
//

import Foundation

struct APIService {
    
    static let baseURL = "http://localhost:3000/api"
    
    static func fetchPlayers() async throws -> [Player] {
        guard let url = URL(string: "\(baseURL)/players") else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(PlayersResponse.self, from: data)
        return decoded.players
    }
    
    static func fetchGames() async throws -> [Game] {
        guard let url = URL(string: "\(baseURL)/games") else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(GamesResponse.self, from: data)
        return decoded.games
    }
    
    static func fetchPlays() async throws -> [Play] {
        guard let url = URL(string: "\(baseURL)/plays") else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(PlaysResponse.self, from: data)
        return decoded.plays
    }
    
    static func fetchAllPlayParticipants() async throws -> [PlayParticipant] {
        guard let url = URL(string: "\(baseURL)/playparticipants") else { throw URLError(.badURL) }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let decoded = try decoder.decode(PlayParticipantsResponse.self, from: data)
        return decoded.play_participants
    }
}
