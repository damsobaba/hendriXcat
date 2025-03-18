//
//  StartMenuView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI

struct StartMenuView: View {
    let onStart: () -> Void

    var body: some View {
        ZStack(alignment: .center) {
            // Space-like gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.blue.opacity(0.8),
                    Color.purple,
                    Color.black
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all) // Extend the gradient to cover the entire screen

            VStack(spacing: 20) {
                Text("Welcome HendrixCat game")
                    .font(.headline)
                    .foregroundColor(.white)

                Button(action: onStart) {
                    Text("Start Game")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
        }
    }
}
