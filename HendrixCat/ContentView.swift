//
//  ContentView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 06/12/2024.
//

import SwiftUI

struct ContentView: View {
    @State private var gameStarted = false

    var body: some View {
        ZStack {
            if gameStarted {
                GameplayView(
                    onExit: { gameStarted = false } // Return to start menu
                )
            } else {
                StartMenuView(
                    onStart: { gameStarted = true } // Start the game
                )
            }
        }
        .animation(.easeInOut, value: gameStarted)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
