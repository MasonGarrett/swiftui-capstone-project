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
    @State var user = UserService.shared.user
    
    var body: some View {
        
        GeometryReader { geo in
            VStack (alignment: .leading, spacing: 20) {
                
                Spacer()
                
                // User Info
                HStack {
                    Spacer()
                    Image("lcslogo")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                    
                    Spacer()
                    
                    VStack(alignment: .leading) {
                        Text("MaseLoL")
                            .font(.headline)
                        Text("Counter Logic Gaming")
                    }
                    
                    Spacer()
                    
                    Button {
                        // TODO: Edit users profile
                        print(UserService.shared.user.displayName)
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
                }
                                
                Text("Hi! My name is MaseLoL, also known as Mase! I am an avid CLG fan for the last 6 year. I main ADC and I am currently Diamond 3 on the NA ladder.")
                                
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
                            Text("7")
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
                            Text("25")
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
                            Text("77%")
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
                        
                        Text("$125.00")
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
