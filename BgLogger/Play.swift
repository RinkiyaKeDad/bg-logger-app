//
//  Play.swift
//  BgLogger
//
//  Created by Arsh Sharma on 06/10/25.
//

import Foundation

struct Play: Identifiable, Codable {
    let id: UUID
    let game_id: UUID
    let created_at: Date
}

struct PlayParticipant: Codable {
    let play_id: UUID
    let player_id: UUID
}

struct PlayResponseWrapper: Codable {
    let status: String
    let data: PlayData
}

struct PlayData: Codable {
    let play: PlayStatus
}

struct PlayStatus: Codable {
    let Ok: Play
}
