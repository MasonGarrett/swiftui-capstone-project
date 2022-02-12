//
//  MatchCardView.swift
//  CapstoneProject
//
//  Created by Mason Garrett on 2022-02-12.
//

import SwiftUI

struct MatchCardView: View {
    
    var time: String
    var teamA: String
    var teamB: String
    
    var body: some View {
        
        ZStack(alignment: .center) {
            Rectangle()
                .foregroundColor(Color(.lightGray))
            
            HStack {
                Group {
                    Text(time)
                    Spacer()
                    Image(teamA)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                    Spacer()
                    Text(teamA)
                        .bold()
                    Spacer()
                }
                Group {
                    Text("vs")
                    Spacer()
                    Image(teamB)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50)
                    Spacer()
                    Text(teamB)
                        .bold()
                }
            }
            .padding(10)
        }
    }
}
