//
//  UserModel.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-11.
//

import Foundation
import Firebase
import FirebaseAuth

class UserModel: ObservableObject {
    
    // Authentication
    @Published var loggedIn = false
    
    // Reference to Cloud Firestore database
    private let db = Firestore.firestore()
    
    // MARK: Authentication Methods
    
    func checkLogin() {
        
        // Check if their is a current user to determine login status
        loggedIn = Auth.auth().currentUser != nil ? true : false
        
        // Check if user meta data has been fetched. If the user was already logged in from a previous session, we need to get their data in a seperate call
        if UserService.shared.user.displayName == "" {
            getUserData()
        }
    }
    
    // MARK: Data Methods
    
    func checkUsername(username: String, completion: @escaping (_ userFound: Bool) -> ()) {
        
        // Check for the entered username
        let ref = db.collection("users").whereField("username", isEqualTo: username)
        ref.getDocuments { snapshot, error in
            if let error = error {
                print("Error finding usernames: \(error)")
            }
            else if snapshot!.count > 0 {
                completion(true)
            } else {
                completion(false)
            }
        }
    }
    
    func getUserData() {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        // Get the meta data for that user
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        ref.getDocument { snapshot, error in
            
            // Check there's no errors
            guard error == nil && snapshot != nil else {
                return
            }
            
            // Parse the data out and set the user meta data
            let data = snapshot!.data()
            let user = UserService.shared.user
            user.displayName = data?["displayName"] as? String ?? ""
            user.favouriteTeam = data?["favouriteTeam"] as? String ?? ""
        }
    }
    
    func saveUserData(username: String, favTeam: Int) {
        
        // Save the first name
        let firebaseUser = Auth.auth().currentUser
        let ref = db.collection("users").document(firebaseUser!.uid)
        
        ref.setData(["username":username.lowercased(),
                     "displayName":username,
                     "favouriteTeam": Constants.LCSTeams[favTeam]], merge: true)
        
        // Update the user meta data
        let user = UserService.shared.user
        user.displayName = username
        user.favouriteTeam = Constants.LCSTeams[favTeam]
    }
}
