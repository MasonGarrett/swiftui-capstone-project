//
//  MatchesView.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-12.
//

import SwiftUI
import EventKit

struct MatchesView: View {
    
    @EnvironmentObject var model: UserModel
    let user = UserService.shared.user
    @State var alertShowing = false
        
    var body: some View {
        
        if model.weeklyMatches.count != 0 {
            ScrollView (showsIndicators: false) {
                
                LazyVStack (alignment: .leading){
                    Text(model.weeklyMatches[0].getDate())
                        .font(.title)
                        .bold()
                    ForEach(0..<5) { index in
                        let game = model.weeklyMatches[index]
                        let disabledFlag = checkForMatch(gameId: game.GameId!)
                        Menu {
                            Button("Bet on \(game.TeamAKey!)", action: {
                                self.model.bet(team: game.TeamAKey!, gameId: game.GameId!, teamId: game.TeamAId!)
                            })
                                .disabled(disabledFlag)
                            
                            Button("Bet on \(game.TeamBKey!)", action: {
                                self.model.bet(team: game.TeamBKey!, gameId: game.GameId!, teamId: game.TeamBId!)
                            })
                                .disabled(disabledFlag)
                            
                            Button("Add to Reminder", action: {
                                setReminder(game: game) {
                                }
                            })
                            
                            Button("Add to Calendar") {
                                setCalendar(game: game) {
                                }
                            }
                        } label: {
                            MatchCardView(time: game.getTime(), teamA: game.TeamAKey!, teamB: game.TeamBKey!)
                        }
                    }
                    Text(model.weeklyMatches[5].getDate())
                        .font(.title)
                        .bold()
                        .padding(.top)
                    ForEach(5..<self.model.weeklyMatches.count) { index in
                        let game = model.weeklyMatches[index]
                        let disabledFlag = checkForMatch(gameId: game.GameId!)
                        Menu {
                            Button("Bet on \(game.TeamAKey!)", action: {
                                self.model.bet(team: game.TeamAKey!, gameId: game.GameId!, teamId: game.TeamAId!)
                            })
                                .disabled(disabledFlag)
                            
                            Button("Bet on \(game.TeamBKey!)", action: {
                                self.model.bet(team: game.TeamBKey!, gameId: game.GameId!, teamId: game.TeamBId!)
                            })
                                .disabled(disabledFlag)
                            
                            Button("Add to Reminder", action: {
                                setReminder(game: game) {
                                }
                            })
                            
                            Button("Add to Calendar") {
                                setCalendar(game: game) {
                                }
                            }
                        } label: {
                            MatchCardView(time: game.getTime(), teamA: game.TeamAKey!, teamB: game.TeamBKey!)
                        }
                    }
                }
                
                HStack {
                    
                    // For Testing Purposes
                    Button {
                        self.model.addWin()
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                                .frame(width: 120, height: 40)
                            
                            Text("Add Winning Bet")
                                .foregroundColor(.white)
                        }
                    }
                    
                    Button {
                        self.model.addLoss()
                    } label: {
                        ZStack {
                            Rectangle()
                                .foregroundColor(.blue)
                                .cornerRadius(10)
                                .frame(width: 120, height: 40)
                            
                            Text("Add Losing Bet")
                                .foregroundColor(.white)
                        }
                    }
                }

            }
            .padding()
        }
        else {
            ProgressView()
        }
    }
    
    /**
     Checks to see if the user has already bet on the game.
     */
    func checkForMatch(gameId: Int) -> Bool {
        var matchFound = false
        for bet in model.usersBets {
            if bet == gameId {
                matchFound = true
                break
            }
        }
        return matchFound
    }
    
    /**
     Requests access to users reminders. If granted it will add the selected game to the reminders app.
      
     - Paramater game: The game selected
     
     Ref: https://nemecek.be/blog/35/how-to-create-ios-reminders-in-code-with-alarms-or-recurrences
     */
    func setReminder(game: Match, grantedAction: @escaping () -> Void) {
        let store = EKEventStore()

        store.requestAccess(to: .reminder) { (granted, error) in
            if let error = error {
                print(error)
                return
            }

            if granted {
                guard let calendar = store.defaultCalendarForNewReminders() else { return }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                let date = formatter.date(from: game.DateTime!)
                
                let newReminder = EKReminder(eventStore: store)
                newReminder.calendar = calendar
                newReminder.title = "\(game.TeamAKey!) VS \(game.TeamBKey!)"
                newReminder.dueDateComponents = Calendar.current.dateComponents([.year, .month, .day], from: date!)
                
                try! store.save(newReminder, commit: true)

            }
        }
    }
    
    /**
     Requests access to users calendar. If granted it will add the selected game to the calendar app.
      
     - Paramater game: The game selected
     
     Ref: https://stackoverflow.com/questions/246249/programmatically-add-custom-event-in-the-iphone-calendar
     */
    func setCalendar(game: Match, grantedAction: @escaping () -> Void) {
        let store = EKEventStore()

        store.requestAccess(to: .event) { (granted, error) in
            if let error = error {
                print(error)
                return
            }

            if granted {
                guard let calendar = store.defaultCalendarForNewEvents else { return }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
                
                let endDate = formatter.date(from: game.DateTime!)
                
                let newEvent = EKEvent(eventStore: store)
                newEvent.calendar = calendar
                newEvent.title = "\(game.TeamAKey!) VS \(game.TeamBKey!)"
                newEvent.startDate = endDate!
                newEvent.endDate = endDate!
                
                try! store.save(newEvent, span: .thisEvent, commit: true)

            }
        }
    }
}


struct MatchesView_Previews: PreviewProvider {
    static var previews: some View {
        MatchesView()
    }
}
