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
                GameView(onExit: { gameStarted = false })
            } else {
                StartMenuView(onStart: { gameStarted = true })
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
