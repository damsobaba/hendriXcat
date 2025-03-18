//
//  GameplayView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI

struct GameView: View {
    @ObservedObject var viewModel = GameplayViewModel()

    let onExit: () -> Void

    var body: some View {
        ZStack(alignment: .center) {
            GameplayView(viewModel: viewModel)
                .disabled(viewModel.gameOver)

            if viewModel.gameOver {
                GameOverView(timeElapsed: viewModel.timeElapsed,
                             onRestart: viewModel.startGame,
                             onExit: onExit)
            }
        }
        .onAppear(perform: viewModel.startGame)
        .onDisappear(perform: viewModel.cleanupResources)
    }
}
