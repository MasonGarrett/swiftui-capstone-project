//
//  ProfileView.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-11.
//

import SwiftUI
import Firebase

struct ProfileView: View {
    
    @EnvironmentObject var model: UserModel
    let user = UserService.shared.user
    
    @State var editView = false
    
    var body: some View {
        GeometryReader { geo in
            VStack (alignment: .leading, spacing: 20) {
                
                Spacer()
                
                // User Info
                HStack {
                    Image("lcslogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                                        
                    VStack(alignment: .leading) {
                        Text(user.displayName)
                            .font(.headline)
                        Text(user.favouriteTeam)
                    }
                    
                    Spacer()
                    
                    Button {
                        // TODO: Edit users profile
                        editView = true

                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                                .frame(width: 110, height: 35)
                            
                            Text("Edit Profile")
                                .foregroundColor(.white)
                        }
                    }
                    .sheet(isPresented: $editView) {
                        editView = false
                    } content: {
                        EditProfileView(editView: $editView)
                    }
                }
                
                Text(user.bio)
                
                // Match History Button
                HStack {
                    Spacer()
                    Button {
                        // TODO: Show match history
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                                .frame(width: 120, height: 40)
                            
                            Text("Match History")
                                .foregroundColor(.white)
                        }
                    }
                }
                
                // Users Stats
                HStack {
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(.lightGray))
                            .frame(width: geo.size.width / 3 - 20, height: geo.size.width / 3 - 20)
                        VStack{
                            Text(String(user.winStreak))
                                .font(.system(size: 13))
                                .bold()
                            
                            Text("Win Streak")
                                .font(.system(size: 13))
                        }
                    }
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(.lightGray))
                            .frame(width: geo.size.width / 3 - 20, height: geo.size.width / 3 - 20)
                        VStack{
                            Text(String(user.correctGames))
                                .font(.system(size: 13))
                                .bold()
                            
                            Text("Correct Games")
                                .font(.system(size: 13))
                        }
                    }
                    Spacer()
                    ZStack {
                        Rectangle()
                            .foregroundColor(Color(.lightGray))
                            .frame(width: geo.size.width / 3 - 20, height: geo.size.width / 3 - 20)
                        VStack{
                            Text("\(user.correctGames / (user.totalGamesBet == 0 ? 1 : 0))%")
                                .font(.system(size: 13))
                                .bold()
                            
                            Text("Correct Games %")
                                .font(.system(size: 13))
                            
                        }
                    }
                }
                
                Spacer()
                
                // Users Balance
                ZStack {
                    Rectangle()
                        .foregroundColor(Color(.lightGray))
                        .cornerRadius(10)
                    
                    VStack {
                        Spacer()
                        Text("Current Balance")
                            .font(.system(size: 20))
                            .bold()
                        
                        Spacer()
                        
                        Text("\(user.balance) Points")
                            .font(.system(size: 40))
                            .bold()
                        
                        Spacer()
                        
                        HStack {
                            Button {
                                // TODO: Withdraw money
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                        .frame(width: 110, height: 35)
                                    
                                    Text("Withdraw")
                                        .foregroundColor(.white)
                                }
                            }
                            
                            Spacer()
                            
                            Button {
                                // TODO: Deposit money
                            } label: {
                                ZStack {
                                    Rectangle()
                                        .foregroundColor(.blue)
                                        .cornerRadius(10)
                                        .frame(width: 110, height: 35)
                                    
                                    Text("Deposit")
                                        .foregroundColor(.white)
                                }
                            }
                        }
                        .padding(.horizontal, 40)
                        
                        Spacer()
                    }
                }
                
            }
            .padding()
        }
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
