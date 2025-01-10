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
        ZStack {
            // Background for Start Menu
            Image("menu_background") // Replace with your menu background image
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            VStack {
                Text("Welcome to Space Adventure!")
                    .font(.largeTitle)
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
