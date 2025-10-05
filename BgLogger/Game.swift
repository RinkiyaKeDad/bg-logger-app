//
//  Game.swift
//  BgLogger
//
//  Created by Arsh Sharma on 05/10/25.
//

import Foundation

struct Game: Identifiable, Codable{
    let id: UUID
    let name: String
    let creator_name: String
    let created_at: Date
}

struct GamesResponse: Codable {
    let count: Int
    let games: [Game]
    let status: String
}
