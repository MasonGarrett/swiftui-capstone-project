//
//  MatchHistoryView.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-23.
//

import SwiftUI

struct MatchHistoryView: View {
    
    @EnvironmentObject var model: UserModel
    let user = UserService.shared.user
    @Binding var editView: Bool
    
    var body: some View {
        ScrollView (showsIndicators: false) {
            
            LazyVStack (alignment: .leading) {
                
                Text("Match History")
                    .font(.title)
                    .bold()
                
                ForEach(0..<user.matchHistory.count) { index in
                    let match = user.matchHistory[index]
                    MatchHistoryCardView(winningTeam: match.winningTeamKey, losingTeam: match.losingTeamKey, userWon: match.userWonBet)
                }
            }
            .padding()
        }
    }
}
