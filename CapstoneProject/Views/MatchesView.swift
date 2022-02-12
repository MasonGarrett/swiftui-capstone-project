//
//  MatchesView.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-12.
//

import SwiftUI

struct MatchesView: View {
    
    @EnvironmentObject var model: UserModel
        
    var body: some View {
        
        if model.weeklyMatches.count != 0 {
            ScrollView (showsIndicators: false) {
                
                LazyVStack (alignment: .leading){
                    Text(model.weeklyMatches[0].getDate())
                        .font(.title)
                        .bold()
                    ForEach(0..<5) { index in
                        MatchCardView(time: model.weeklyMatches[index].getTime(), teamA: model.weeklyMatches[index].TeamAKey!, teamB: model.weeklyMatches[index].TeamBKey!)
                    }
                    Text(model.weeklyMatches[5].getDate())
                        .font(.title)
                        .bold()
                        .padding(.top)
                    ForEach(5..<self.model.weeklyMatches.count) { index in
                        MatchCardView(time: model.weeklyMatches[index].getTime(), teamA: model.weeklyMatches[index].TeamAKey!, teamB: model.weeklyMatches[index].TeamBKey!)
                    }
                }
            }
            .padding()
        }
        else {
            ProgressView()
        }
    }
}

struct MatchesView_Previews: PreviewProvider {
    static var previews: some View {
        MatchesView()
    }
}
