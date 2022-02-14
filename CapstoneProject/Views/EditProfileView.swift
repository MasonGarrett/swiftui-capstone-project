//
//  EditProfileView.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-14.
//

import SwiftUI

struct EditProfileView: View {
    
    @EnvironmentObject var model: UserModel
    let user = UserService.shared.user
    
    @State var bio = ""
    @State var favTeam = 0
    
    @Binding var editView: Bool
    @FocusState var bioIsFocused: Bool
    
    var body: some View {
        
        VStack (alignment: .center, spacing: 20) {
            
            HStack {
                Button {
                    editView = false
                } label: {
                    Text("Cancel")
                }
                .padding([.leading], 15)

                
                Spacer()
                Text("Edit Profile")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    model.saveUserData(team: favTeam, bio: bio)
                    editView = false
                } label: {
                    Text("Done")
                }
                .padding([.trailing], 15)
            }
            
            Divider()
            
            Image("lcslogo")
                .resizable()
                .scaledToFit()
                .frame(width: 50)
            
            Button {
                // TODO: Change pic
            } label: {
                Text("Change Profile Picture")
            }

            Divider()
            
            VStack (alignment: .leading) {
                Form {
                    Section {
                        HStack {
                            Text("Favourite Team")
                                .font(.subheadline)
                                .bold()
                            
                            Spacer()
                            
                            Picker("Select Favorite Team", selection: $favTeam) {
                                ForEach(0..<Constants.LCSTeams.count) {
                                    Text(Constants.LCSTeams[$0])
                                }
                            }
                            .pickerStyle(MenuPickerStyle())
                                                    
                            Spacer()
                        }
                    }
                    
                    Section {
                        HStack {
                            Text("Bio")
                                .font(.subheadline)
                                .bold()
                            
                            Spacer()
                            
                            ZStack {
                                TextEditor(text: $bio)
                                    .padding(.horizontal, 20)
                                    .focused($bioIsFocused)
                                    .onTapGesture {
                                        bioIsFocused = true
                                    }
                                
                                Text(bio)
                                    .opacity(0)
                                    .padding(.all, 8)
                            }
                        
                            Spacer()
                        }
                    }
                }
            }
        }
        .padding(.top, 40)
        .onAppear {
            for (index, team) in Constants.LCSTeams.enumerated() {
                if user.favouriteTeam == team{
                    self.favTeam = index
                    break
                }
            }
            self.bio = user.bio
        }
        .onTapGesture {
            bioIsFocused = false
        }
    }
}
