//
//  StartMenuView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI

struct StartMenuView: View {
    var onStart: () -> Void

    var body: some View {
        ZStack {
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

            VStack {
                Text("Welcome HendrixCat game ")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()

                Button(action: {
                    onStart()
                }) {
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
