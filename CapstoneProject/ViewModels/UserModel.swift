//
//  UserModel.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-11.
//

import Foundation
import Firebase
import FirebaseAuth
import FirebaseStorage

class UserModel: ObservableObject {
    
    // Authentication
    @Published var loggedIn = false
    
    // Reference to Cloud Firestore database
    private let db = Firestore.firestore()
    
    private var weekNumber = 0
    private var roundId = 0
    
    @Published var weeklyMatches = [Match]()
    @Published var usersBets = [Int]()
    
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
            
            var activeBets = [ActiveBets]()
            var intBets = [Int]()
            let activeBetArray =  data?["activeBets"] as? [String]
            
            if activeBetArray == nil{
                for (key, value) in data?["activeBets"] as! [String: [String: Any]] {
                    let activeBet = ActiveBets()
                    activeBet.gameId = Int(key)!
                    activeBet.betAmount = value["betAmount"] as! Int
                    activeBet.betTeamKey = value["betTeamKey"] as! String
                    activeBet.betTeamId = value["betTeamId"] as! Int
                    activeBets.append(activeBet)
                    intBets.append(Int(key)!)
                }
            }
            
            self.usersBets = intBets
            self.checkActiveBets(activeBets: activeBets)
            
            
            var tempMatchHistroy = [MatchHistory]()
            let matchHistoryArray =  data?["matchHistory"] as? [String]
            
            if matchHistoryArray == nil{
                for (key, value) in data?["matchHistory"] as! [String: [String: Any]] {
                    let matchHistoryObject = MatchHistory()
                    matchHistoryObject.gameId = Int(key)!
                    matchHistoryObject.winningTeamKey = value["winningTeamKey"] as! String
                    matchHistoryObject.losingTeamKey = value["losingTeamKey"] as! String
                    matchHistoryObject.userWonBet = value["userWon"] as! Bool
                    tempMatchHistroy.append(matchHistoryObject)
                }
            }
        
            DispatchQueue.main.async {
                user.displayName = data?["displayName"] as? String ?? ""
                user.favouriteTeam = data?["favouriteTeam"] as? String ?? ""
                user.bio = data?["bio"] as? String ?? ""
                user.winStreak = data?["winStreak"] as? Int ?? 0
                user.correctGames = data?["correctGames"] as? Int ?? 0
                user.totalGamesBet = data?["totalGamesBet"] as? Int ?? 0
                user.balance = data?["balance"] as? Int ?? 0
                user.activeBets = activeBets
                user.matchHistory = tempMatchHistroy
            }
            self.downloadImage()
        }
    }
    
    func saveUserData(image: UIImage, team: Int, bio: String) {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        
        ref.setData(["favouriteTeam": Constants.LCSTeams[team], "bio": bio], merge: true)
        
        saveImage(image: image)
        
        let user = UserService.shared.user
        
        DispatchQueue.main.async {
            user.favouriteTeam = Constants.LCSTeams[team]
            user.bio = bio
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
                     "totalGamesBet": 0,
                     "balance": 200,
                     "activeBets": [],
                     "matchHistory": []], merge: true)
        
        // Update the user meta data
        let user = UserService.shared.user
        user.displayName = username
        user.favouriteTeam = Constants.LCSTeams[favTeam]
        user.bio = ""
        user.winStreak = 0
        user.correctGames = 0
        user.totalGamesBet = 0
        user.balance = 50
        
        saveImage()
    }
    
    func saveImage(image: UIImage = UIImage(named: "blankProfile")!) {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        let storage = Storage.storage()
        
        let storageRef = storage.reference(withPath: Auth.auth().currentUser!.uid)
        
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        storageRef.putData(imageData, metadata: nil) { metadeta, error in
            
            if let error = error {
                print(error.localizedDescription)
                return
            }
        }
        DispatchQueue.main.async {
            UserService.shared.user.image = image
        }
    }
    
    func downloadImage() {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        let storage = Storage.storage()
        
        let storageRef = storage.reference(withPath: Auth.auth().currentUser!.uid)
        
        
        storageRef.downloadURL { url, error in
            
            if let error = error{
                print(error.localizedDescription)
                return
            }
            
            self.getData(from: url!) { data, response, error in
                guard let data = data, error == nil else { return }
                // always update the UI from the main thread
                DispatchQueue.main.async {
                    UserService.shared.user.image = UIImage(data: data)!
                }
            }
        }
    }
    
    func getData(from url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url, completionHandler: completion).resume()
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
                                DispatchQueue.main.async {
                                    self.roundId = match.RoundId!
                                    self.weekNumber = match.Week!
                                }
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
    
    func topUp() {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        let user = UserService.shared.user
        
        if user.balance < 50 {
            
            let ref = db.collection("users").document(Auth.auth().currentUser!.uid)

            ref.setData(["balance": user.balance + 50], merge: true)
            
            DispatchQueue.main.async {
                user.balance = user.balance + 50
            }
        }
        else {
            // notify user
        }
    }
    
    func bet(team: String, gameId: Int, teamId: Int) {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        let user = UserService.shared.user
        if user.balance >= 50 {
            
            let newBet = ActiveBets()
            newBet.betAmount = 50
            newBet.betTeamKey = team
            newBet.gameId = gameId
            newBet.betTeamId = teamId
            
            let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
            let data: [String: Any] = [
                    String(gameId) : [
                        "betTeamKey" : team,
                        "betAmount" : 50,
                        "betTeamId": teamId]
                ]
            
            
            ref.setData(["balance": user.balance - 50, "activeBets": data], merge: true)
            
            DispatchQueue.main.async {
                user.activeBets.append(newBet)
                user.balance = user.balance - 50
                self.usersBets.append(gameId)
            }
        }
        else {
           // Notify user
        }
    }
    
    func addMatchToHistory(winningTeamKey: String, losingTeamKey: String, userWon: Bool, gameId: Int) {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        let newMatchHistory = MatchHistory()
        
        newMatchHistory.gameId = gameId
        newMatchHistory.winningTeamKey = winningTeamKey
        newMatchHistory.losingTeamKey = losingTeamKey
        newMatchHistory.userWonBet = userWon
        
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        let data: [String: Any] = [
                String(gameId) : [
                    "gameId" : gameId,
                    "winningTeamKey" : winningTeamKey,
                    "losingTeamKey": losingTeamKey,
                    "userWon": userWon
                ]
            ]
        
        ref.setData(["matchHistory": data], merge: true)
        
        DispatchQueue.main.async {
            UserService.shared.user.matchHistory.append(newMatchHistory)
        }
    }
    
    func checkActiveBets(activeBets: [ActiveBets]) {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        let user = UserService.shared.user
        
        for game in activeBets {
            
            // Create URL
            var searchString = Constants.apiResultsURL
            searchString += "/\(game.gameId)?key="
            
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
                            let result = try decoder.decode([BoxScore].self, from: data!)
                            
                            let boxscore = result[0]
                            
                            if boxscore.Matches!.count > 0 {
                                
                                let firebaseUser = Auth.auth().currentUser

                                // If the user bet on the correct team, award them points
                                if game.betTeamId == boxscore.Matches![0].WinningTeamId {
                                    
                                    let ref = self.db.collection("users").document(firebaseUser!.uid)
                                    ref.setData(["balance": user.balance + (game.betAmount * 2),
                                                 "winStreak": user.winStreak + 1,
                                                 "correctGames": user.correctGames + 1,
                                                 "totalGamesBet": user.totalGamesBet + 1], merge: true)
                                    DispatchQueue.main.async {
                                        user.balance = user.balance + (game.betAmount * 2)
                                        user.winStreak = user.winStreak + 1
                                        user.correctGames = user.correctGames + 1
                                        user.totalGamesBet = user.totalGamesBet + 1
                                    }
                                    
                                    if game.betTeamKey == boxscore.Game!.TeamAKey {
                                        self.addMatchToHistory(winningTeamKey: boxscore.Game!.TeamAKey!, losingTeamKey: boxscore.Game!.TeamBKey!, userWon: true, gameId: boxscore.Game!.GameId!)
                                    } else {
                                        self.addMatchToHistory(winningTeamKey: boxscore.Game!.TeamBKey!, losingTeamKey: boxscore.Game!.TeamAKey!, userWon: true, gameId: boxscore.Game!.GameId!)
                                    }
                                }
                                else {
                                    let ref = self.db.collection("users").document(firebaseUser!.uid)
                                    ref.setData(["winStreak": 0,
                                                 "totalGamesBet": user.totalGamesBet + 1], merge: true)
                                    DispatchQueue.main.async {
                                        user.winStreak = 0
                                        user.totalGamesBet = user.totalGamesBet + 1
                                    }
                                    
                                    if game.betTeamKey == boxscore.Game!.TeamAKey {
                                        self.addMatchToHistory(winningTeamKey: boxscore.Game!.TeamBKey!, losingTeamKey: boxscore.Game!.TeamAKey!, userWon: false, gameId: boxscore.Game!.GameId!)
                                    } else {
                                        self.addMatchToHistory(winningTeamKey: boxscore.Game!.TeamAKey!, losingTeamKey: boxscore.Game!.TeamBKey!, userWon: false, gameId: boxscore.Game!.GameId!)
                                    }
                                }

                                // Remove game from weekly matches
                                for (index, match) in self.weeklyMatches.enumerated() {
                                    if match.GameId == boxscore.Game!.GameId {
                                        DispatchQueue.main.async {
                                            self.weeklyMatches.remove(at: index)
                                        }
                                        break
                                    }
                                }
                                
                                // Remove game from active bets
                                let ref = self.db.collection("users").document(firebaseUser!.uid)
                                
                                ref.getDocument { snapshot, error in
                                    
                                    // Check there's no errors
                                    guard error == nil && snapshot != nil else {
                                        return
                                    }
                                    
                                    // Parse the data out and set the user meta data
                                    let data = snapshot!.data()
                                    var activeBets = [ActiveBets]()

                                    
                                    for (key, value) in data?["activeBets"] as! [String: [String: Any]] {
                                        let activeBet = ActiveBets()
                                        activeBet.gameId = Int(key)!
                                        activeBet.betAmount = value["betAmount"] as! Int
                                        activeBet.betTeamKey = value["betTeamKey"] as! String
                                        activeBet.betTeamId = value["betTeamId"] as! Int
                                        activeBets.append(activeBet)
                                    }
                                    
                                    var betIndex = -1
                                    for (index, activeBet) in activeBets.enumerated() {
                                        if activeBet.gameId == game.gameId {
                                            betIndex = index
                                        }
                                    }
                                    
                                    if betIndex != -1 {
                                        activeBets.remove(at: betIndex)
                                        var newBetsArray = [String: Any]()
                                        
                                        for activeBet in activeBets {
                                            
                                            newBetsArray[String(activeBet.gameId)] = [
                                                    "betTeamKey" : activeBet.betTeamKey,
                                                    "betAmount" : activeBet.betAmount,
                                                    "betTeamId": activeBet.betAmount
                                            ]
                                        }
                                                                                
                                        ref.updateData(["activeBets": newBetsArray])
                                    }
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
    }
    
    func addWin() {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        let newBet = ActiveBets()
        newBet.betAmount = 50
        newBet.betTeamKey = "100"
        newBet.gameId = 100013086
        newBet.betTeamId = 100000045
        
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        let data: [String: Any] = [
                String(100013086) : [
                    "betTeamKey" : "100",
                    "betAmount" : 50,
                    "betTeamId": 100000045]
            ]
        
        
        ref.setData(["activeBets": data], merge: true)
        
        DispatchQueue.main.async {
            UserService.shared.user.activeBets.append(newBet)
        }
    }
    
    func addLoss() {
        
        // Check that there's a logged in user
        guard Auth.auth().currentUser != nil else {
            return
        }
        
        let newBet = ActiveBets()
        newBet.betAmount = 50
        newBet.betTeamKey = "GG"
        newBet.gameId = 100013086
        newBet.betTeamId = 100000047
        
        let ref = db.collection("users").document(Auth.auth().currentUser!.uid)
        let data: [String: Any] = [
                String(100013086) : [
                    "betTeamKey" : "GG",
                    "betAmount" : 50,
                    "betTeamId": 100000047]
            ]
        
        
        ref.setData(["activeBets": data], merge: true)
        
        DispatchQueue.main.async {
            UserService.shared.user.activeBets.append(newBet)
        }
    }
}
