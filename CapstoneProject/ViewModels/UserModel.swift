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
    
    private var weekNumber = 0
    private var roundId = 0
    
    @Published var weeklyMatches = [Match]()
        
    init () {
        
        getRound()
    }
    
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
            user.bio = data?["bio"] as? String ?? ""
            user.winStreak = data?["winStreak"] as? Int ?? 0
            user.correctGames = data?["correctGames"] as? Int ?? 0
            user.balance = data?["balance"] as? Int ?? 0
        }
    }
    
    func createUser(username: String, favTeam: Int) {
        
        // Save the first name
        let firebaseUser = Auth.auth().currentUser
        let ref = db.collection("users").document(firebaseUser!.uid)
        
        ref.setData(["username":username.lowercased(),
                     "displayName":username,
                     "favouriteTeam": Constants.LCSTeams[favTeam],
                     "bio": "My name is, \(username)!",
                     "winStreak": 0,
                     "correctGames": 0,
                     "balance": 50], merge: true)
        
        // Update the user meta data
        let user = UserService.shared.user
        user.displayName = username
        user.favouriteTeam = Constants.LCSTeams[favTeam]
        user.bio = ""
        user.winStreak = 0
        user.correctGames = 0
        user.balance = 50
    }
    
    func getRound() {
                
        let calendar = Calendar.current
        var today = Date()
        
        while !Calendar.current.isDateInWeekend(today) {
            today = calendar.date(byAdding: .day, value: 1, to: today)!
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let date = formatter.string(from: today)
        
        // Create URL
        var searchString = Constants.apiMatchesURL
        searchString += "/\(date)?key="
        
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
            let apiKey = dict["apiKey"] as? String
            searchString += apiKey!
            let urlComponents = URLComponents(string: searchString)
            let url = urlComponents!.url
            
            // Create URL Request
            var request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            // Get URL Session
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                // Check that there isn't an error
                if error == nil {
                    
                    do {
                        // Parse json
                        let decoder = JSONDecoder()
                        let result = try decoder.decode([Round].self, from: data!)
                        
                        for match in result {
                            if Constants.LCSTeamKeys.contains(match.TeamAKey ?? "") || Constants.LCSTeamKeys.contains(match.TeamBKey ?? "") {
                                self.roundId = match.RoundId!
                                self.weekNumber = match.Week!
                                break
                            }
                        }
                    }
                    catch {
                        print(error)
                    }
                }
            }
            // Start the Data Task
            dataTask.resume()
        }
    }
    
    func getWeekly() {
        
        // Create URL
        var searchString = Constants.apiWeeklyURL
        searchString += "/\(roundId)?key="
        
        var keys: NSDictionary?
        
        if let path = Bundle.main.path(forResource: "Keys", ofType: "plist") {
            keys = NSDictionary(contentsOfFile: path)
        }
        
        if let dict = keys {
            let apiKey = dict["apiKey"] as? String
            searchString += apiKey!
            let urlComponents = URLComponents(string: searchString)
            let url = urlComponents!.url
            
            // Create URL Request
            var request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            // Get URL Session
            let session = URLSession.shared
            
            // Create Data Task
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                
                // Check that there isn't an error
                if error == nil {
                    
                    do {
                        // Parse json
                        let decoder = JSONDecoder()
                        let result = try decoder.decode([Match].self, from: data!)
                        
                        var matches = [Match]()
                        for match in result {
                            if match.Week == self.weekNumber {
                                matches.append(match)
                            }
                        }
                        DispatchQueue.main.async {
                            self.weeklyMatches = matches
                        }
                    }
                    catch {
                        print(error)
                    }
                }
            }
            // Start the Data Task
            dataTask.resume()
        }
    }
    
}
