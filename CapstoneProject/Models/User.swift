//
//  User.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-11.
//

import Foundation
import UIKit

/**
 User object holds all of the users information that is displayed on the profile page.
 */
class User {
    
    var displayName: String = ""
    var favouriteTeam: String = ""
    var bio: String = ""
    var winStreak: Int = 0
    var correctGames: Int = 0
    var totalGamesBet: Int = 0
    var balance: Int = 50
    var image: UIImage = UIImage(named: "blankProfile")!
    var activeBets: [ActiveBets] = [ActiveBets]()
    var matchHistory: [MatchHistory] = [MatchHistory]()
}

/**
 ActiveBets object is the bet object that the user has currently betted on before the game is complete.
 */
class ActiveBets {
    
    var gameId: Int = 0
    var betAmount: Int = 0
    var betTeamKey: String = ""
    var betTeamId: Int = 0
}

/**
 MatchHistory object is the bet object that is of a game that is already completed. 
 */
class MatchHistory {
    
    var gameId: Int = 0
    var losingTeamKey: String = ""
    var winningTeamKey: String = ""
    var userWonBet: Bool = false
}
