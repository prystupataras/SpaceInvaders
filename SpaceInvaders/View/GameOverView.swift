//
//  GameOverView.swift
//  SpaceInvaders
//
//  Created by Prystupa Taras on 03.09.2024.
//

import SwiftUI

struct GameOverView: View {
    var score: Int
    var restartAction: () -> Void
    
    var body: some View {
        VStack {
            Text(score == 15 ? "You won!" : "You lose")
                .font(.largeTitle)
                .foregroundStyle(.red)
                .padding()
            
            Text("Scode \(score)")
                .font(.headline)
                .foregroundStyle(.white)
                .padding()
            
            Button(action: restartAction) {
                Text("Restart")
                    .foregroundStyle(.white)
                    .padding()
                    .background(.blue)
                    .cornerRadius(10)
            }
        }
        .background(.black)
        .edgesIgnoringSafeArea(.all)
        .padding(20)
    }
}
