//
//  CapstoneProjectApp.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-11.
//

import SwiftUI
import Firebase

@main
struct CapstoneProjectApp: App {
    
    init () {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            LaunchView()
                .environmentObject(UserModel())
        }
    }
}
