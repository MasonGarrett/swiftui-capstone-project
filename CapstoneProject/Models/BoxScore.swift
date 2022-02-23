//
//  BoxScore.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-19.
//

import Foundation

class BoxScore: Decodable, Identifiable, ObservableObject {
    
    var Game: Game?
    var Matches: [Matches]?
}

class Game: Decodable {
    
    var GameId: Int?
    var TeamAId: Int?
    var TeamAKey: String?
    var TeamAName: String?
    var TeamAScore: Int?
    var TeamBId: Int?
    var TeamBName: String?
    var TeamBKey: String?
    var TeamBScore: Int?
}

class Matches: Decodable {
    
    var GameId: Int?
    var WinningTeamId: Int?
}
