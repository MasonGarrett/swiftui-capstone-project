//
//  LaunchView.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-11.
//

import SwiftUI
import FirebaseAuth

struct LaunchView: View {
    
    @EnvironmentObject var model: UserModel
    
    var body: some View {
        
        if model.loggedIn == false {
            
            // Show LoginView
            LoginView()
                .onAppear {
                    // Check if user is logged in or out
                    self.model.checkLogin()
                }
        }
        else {
            
            // Show ProfileView
            TabView {
                
                ProfileView()
                    .tabItem {
                        VStack {
                            Image(systemName: "person")
                            Text("Profile")
                        }
                    }
                
                MatchesView()
                    .tabItem {
                        VStack {
                            Image(systemName: "calendar")
                            Text("Matches")
                        }
                    }
                    .onAppear {
                        self.model.getWeekly()
                    }
                
                Text("Sign Out")
                    .tabItem {
                        VStack {
                            Image(systemName: "rectangle.portrait.and.arrow.right")
                            Text("Sign Out")
                        }
                    }
                    .onAppear {
                        // Sign out the user
                        try! Auth.auth().signOut()
                        
                        // Change to logged out view
                        self.model.checkLogin()
                    }
            }
            .onAppear {
                //self.model.getUserData()
                UITabBar.appearance().backgroundColor = UIColor(red: 248/255, green: 247/255, blue: 248/255, alpha: 100)
            }
        }
    }
}

struct LaunchView_Previews: PreviewProvider {
    static var previews: some View {
        LaunchView()
    }
}
