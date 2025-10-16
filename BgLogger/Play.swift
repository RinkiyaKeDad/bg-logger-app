//
//  Play.swift
//  BgLogger
//
//  Created by Arsh Sharma on 06/10/25.
//

import Foundation


struct PlaysResponse: Codable {
    let count: Int
    let plays: [Play]
    let status: String
}

struct Play: Identifiable, Codable {
    let id: UUID
    let game_id: UUID
    let created_at: Date
}


// these three needed for the response which comes when you save a play
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



struct PlayParticipantsResponse: Codable {
    let count: Int
    let play_participants: [PlayParticipant]
    let status: String
}

struct PlayParticipant: Codable {
    let play_id: UUID
    let player_id: UUID
}
