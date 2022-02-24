//
//  Round.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-12.
//

import Foundation

/**
 Round object from SportsDataIO API
 */
class Round: Decodable, Identifiable, ObservableObject {

    var RoundId: Int?
    var TeamAKey: String?
    var TeamBKey: String?
    var Week: Int?
}
