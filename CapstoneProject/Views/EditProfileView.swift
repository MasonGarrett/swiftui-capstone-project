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
    
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var selectedImage: UIImage?
    @State private var isImagePickerDisplay = false
    
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
                    model.saveUserData(image: selectedImage!, team: favTeam, bio: bio)
                    editView = false
                } label: {
                    Text("Done")
                }
                .padding([.trailing], 15)
            }
            
            Divider()
            
            if let selectedImage = selectedImage {
                Image(uiImage: selectedImage)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 128, height:128)
                    .cornerRadius(64)
                    .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3))
            }
            else {
                Image("blankProfile")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 128, height:128)
                    .cornerRadius(64)
                    .overlay(RoundedRectangle(cornerRadius: 64)
                                .stroke(Color.black, lineWidth: 3))
            }
            
            Menu {
                Button("Camera", action: takePicture)
                Button("Photo Library", action: selectPicture)
                
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
            self.selectedImage = user.image
        }
        .onTapGesture {
            bioIsFocused = false
        }
        .sheet(isPresented: self.$isImagePickerDisplay) {
            ImagePickerView(selectedImage: self.$selectedImage, sourceType: self.sourceType)
        }
    }
    
    /**
     Grabs the image from users camera
     */
    func takePicture() {
        self.sourceType = .camera
        self.isImagePickerDisplay.toggle()
    }
    
    /** Grabs the image from users photo library
     */
    func selectPicture() {
        self.sourceType = .photoLibrary
        self.isImagePickerDisplay.toggle()
    }
}
