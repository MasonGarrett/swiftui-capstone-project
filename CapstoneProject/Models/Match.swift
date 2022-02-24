//
//  Match.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-12.
//

import Foundation

/**
 Match object from SportsDataIO API
 */
class Match: Decodable, Identifiable, ObservableObject {

    var GameId: Int?
    var TeamAId: Int?
    var TeamAKey: String?
    var TeamAName: String?
    var TeamBId: Int?
    var TeamBName: String?
    var TeamBKey: String?
    var Week: Int?
    var DateTime: String?
    
    /**
     getTime converts the given DateTime and converts to the time that the game starts at.
     */
    func getTime() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let date = formatter.date(from: DateTime!)
        let modifiedDate = Calendar.current.date(byAdding: .hour, value: -5, to: date!)
        
        formatter.dateFormat = "hh:mm a"
        let date2 = formatter.string(from: modifiedDate!)

        return "\(date2)"
    }
    
    /**
     getDate converts the given DateTime and converts the date to display as "Friday, Feb 25"
     */
    func getDate() -> String {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        
        let date = formatter.date(from: DateTime!)
        
        formatter.dateFormat = "EEEE, MMM d"
        let date2 = formatter.string(from: date!)
        
        return "\(date2)"
    }
    
    /**
     getSplitDate converts the given DateTime and splits up the string to just display the date. 
     */
    func getSplitDate() -> String {
        
        let date = DateTime!.components(separatedBy: "T")
        
        return date[0]
    }
}

