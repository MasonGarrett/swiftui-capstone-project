//
//  ProfileView.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-11.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        
        VStack {
            
            // User Info
            HStack {
                
            }
            
            // Match History Button
            HStack {
                Spacer()
                Button {
                    // TODO: Show match history
                } label: {
                    Text("Match History")
                }
            }
            
            // Users Stats
            HStack {
                
            }
            
            // Users Balance
            ZStack {
                
            }
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
