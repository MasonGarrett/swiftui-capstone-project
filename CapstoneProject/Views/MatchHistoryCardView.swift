//
//  MatchHistoryCardView.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-23.
//

import SwiftUI

struct MatchHistoryCardView: View {
    var winningTeam: String
    var losingTeam: String
    var userWon: Bool
    
    var body: some View {
        
        ZStack(alignment: .center) {
            Rectangle()
                .foregroundColor(Color(.lightGray))
            
            HStack {
                Group {
                    
                    Image(systemName: userWon == true ? "checkmark.circle" : "x.circle")
                
                    
                    Spacer()
                    Image(winningTeam)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                    Spacer()
                    Text(winningTeam)
                        .bold()
                    Spacer()
                }
                Group {
                    Text("vs")
                    Spacer()
                    Image(losingTeam)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                    Spacer()
                    Text(losingTeam)
                        .bold()
                }
            }
            .padding(10)
            .foregroundColor(.black)
        }
    }
}
