//
//  GameOverView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI

struct GameOverView: View {
    let distance: Int
    let onRestart: () -> Void
    let onExit: () -> Void

    var body: some View {
        VStack(spacing: 20) {
            Text("Game Over")
                .font(.largeTitle)
                .foregroundColor(.white)

            Text("You lasted \(distance) seconds!")
                .font(.title2)
                .foregroundColor(.white)

            Button(action: onRestart) {
                Text("Restart")
                    .font(.title)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(10)
            }

            Button(action: onExit) {
                Text("Exit to Menu")
                    .font(.title3)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            Button(action: shareOnTwitter) {
                HStack {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title)
                    Text("Share on Twitter")
                        .font(.title3)
                }
                .padding()
                .background(Color.blue)
                .foregroundColor(.white)
                .cornerRadius(10)
            }
        }
    }

    private func shareOnTwitter() {
        let tweetText = "I lasted \(distance) seconds in Space Adventure! 🚀 #SpaceAdventureGame"
        let tweetUrl = "https://twitter.com/intent/tweet?text=\(tweetText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: tweetUrl) {
            UIApplication.shared.open(url)
        }
    }
}
