//
//  Player.swift
//  BgLogger
//
//  Created by Arsh Sharma on 03/10/25.
//

import Foundation

struct Player: Identifiable, Codable{
    let id: UUID
    let name: String
    let is_owner: Bool
    let created_at: Date
}

struct PlayersResponse: Codable {
    let count: Int
    let players: [Player]
    let status: String
}
