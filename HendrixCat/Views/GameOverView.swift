//
//GameOverView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//
import SwiftUI

struct GameOverView: View {
    let timeElapsed: Int
    let onRestart: () -> Void
    let onExit: () -> Void // Add this to handle exit

    var body: some View {
        VStack {
            Text("Game Over")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()

            Text("You lasted \(timeElapsed) seconds!")
                .font(.title2)
                .foregroundColor(.white)
                .padding()

            Button("Restart") {
                onRestart()
            }
            .font(.title)
            .padding()
            .background(Color.white)
            .cornerRadius(10)

            Button(action: onExit) {
                Text("Exit to Menu")
                    .font(.title3)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }

            // Add Twitter Share Button here
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

    func shareOnTwitter() {
        let tweetText = "I lasted \(timeElapsed) seconds in Space Adventure! 🚀 #SpaceAdventureGame"
        let tweetUrl = "https://twitter.com/intent/tweet?text=\(tweetText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"

        if let url = URL(string: tweetUrl) {
            UIApplication.shared.open(url)
        }
    }
}
