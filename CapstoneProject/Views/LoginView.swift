//
//  LoginView.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-11.
//

import SwiftUI
import Firebase
import FirebaseAuth

struct LoginView: View {
    
    @EnvironmentObject var model: UserModel
    
    @State var loginMode = Constants.LoginMode.login
    @State var username = ""
    @State var email = ""
    @State var password = ""
    @State var confirmPassword = ""
    @State var selectedTeam = 0
    @State var errorMessage: String?
    
    var buttonText: String {
        
        if loginMode == Constants.LoginMode.login {
            return "Login"
        } else {
            return "Sign Up"
        }
    }
    
    var body: some View {
        
        VStack (spacing: 10) {
            
            Spacer()
            
            // Logo
            Image("lcslogo")
                .resizable()
                .scaledToFit()
                .frame(width: 150)
            
            // Title
            Text("LCS Betting")
                .font(.title)
                .bold()
                .padding(.bottom, 40)
            
            //Spacer()
            
            // Picker (Login or Signup)
            Picker(selection: $loginMode) {
                
                Text("Login")
                    .tag(Constants.LoginMode.login)
                
                Text("Sign Up")
                    .tag(Constants.LoginMode.createAccount)
            } label: {
                Text("Login/Signup")
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // Form
            if loginMode == Constants.LoginMode.login {
                Group {
                    TextField("Email", text: $email)
                    
                    SecureField("Password", text: $password)
                }
            }
            else {
                Group {
                    TextField("Username", text: $username)
                    
                    TextField("Email", text: $email)
                    
                    SecureField("Password", text: $password)
                    
                    SecureField("Confirm Password", text: $confirmPassword)
                    
                    HStack {
                        Text("Your Favorite Team: ")
                        Picker("Select Favorite Team", selection: $selectedTeam) {
                            ForEach(0..<Constants.LCSTeams.count) {
                                Text(Constants.LCSTeams[$0])
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                }
            }
            
            if errorMessage != nil {
                Text(errorMessage!)
            }
                        
            // Button
            Button {
                
                if loginMode == Constants.LoginMode.login {
                    
                    // Log the user in
                    Auth.auth().signIn(withEmail: email, password: password) { result, error in
                        
                        // Check for errors
                        guard error == nil else {
                            self.errorMessage = error!.localizedDescription
                            return
                        }
                        
                        // Clear error message
                        self.errorMessage = nil
                        
                        // Fetch the user meta data
                        self.model.getUserData()
                        
                        // Change the view to logged in view
                        self.model.checkLogin()
                    }
                }
                else {
                    
                    // Check if passwords match
                    model.checkUsername(username: username) { userFound in
                        if userFound {
                            self.errorMessage = "Username already in use!"
                        }
                        else if password != confirmPassword {
                            self.errorMessage = "Passwords do not match!"
                        }
                        else {
                            // Create a new account
                            Auth.auth().createUser(withEmail: email, password: password) { result, error in
                                
                                guard error == nil else {
                                    self.errorMessage = error!.localizedDescription
                                    return
                                }
                                
                                // Clear error message
                                self.errorMessage = nil
                                
                                // Send user data to firestore
                                self.model.createUser(username: username, favTeam: selectedTeam)
                                
                                // Change the view to logged in view
                                self.model.checkLogin()
                            }
                        }
                    }
                }
            } label: {
                ZStack {
                    Rectangle()
                        .foregroundColor(.blue)
                        .frame(height: 40)
                        .cornerRadius(10)
                    
                    Text(buttonText)
                        .foregroundColor(.white)
                }
            }
            .padding(.top, 40)
            
            Spacer()
        }
        .padding(.horizontal, 40)
        .textFieldStyle(RoundedBorderTextFieldStyle())
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
