//
//  Constants.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-11.
//

import Foundation

struct Constants {
    
    enum LoginMode {
        
        case login
        case createAccount
    }
    
    static var LCSTeams = ["Cloud 9", "Dignitas", "FlyQuest", "100 Thieves", "Evil Geniuses", "Team Liquid", "Team Solo Mid", "Immortals", "Counter Logic Gaming", "Golden Guardians"]
    
    static var LCSTeamKeys = ["C9", "DIG", "FLY", "100", "EG", "TL", "TSM", "IMT", "CLG", "GG"]
        
    static var apiMatchesURL = "https://api.sportsdata.io/v3/lol/scores/json/GamesByDate"
    
    static var apiWeeklyURL = "https://api.sportsdata.io/v3/lol/scores/json/Schedule"
    
    static var apiResultsURL = "https://api.sportsdata.io/v3/lol/stats/json/BoxScore"
}
