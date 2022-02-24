//
//  UserService.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-11.
//

import Foundation

/**
 UserService object that makes sure there is only one instance of User object.
 */
class UserService {
    
    var user = User()
    
    static var shared = UserService()
    
    private init() {
        
    }
}
