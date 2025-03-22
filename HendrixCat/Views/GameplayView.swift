//
//  GameplayView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI

struct GameplayView: View {
    @ObservedObject var viewModel: GameplayViewModel

    var body: some View {
        ZStack(alignment: .top) {
            // Static Background
            Image("space_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            // Rocket
            Image("rocket")
                .resizable()
                .frame(width: 40, height: 60)
                .foregroundColor(.red)
                .position(x: viewModel.rocketPosition.x, y: viewModel.rocketPosition.y)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            viewModel.moveRocket(value: value)
                        }
                )

            // Obstacles
            ForEach(viewModel.obstacles) { obstacle in
                Image(obstacle.type.toString)
                    .resizable()
                    .frame(width: obstacle.width, height: obstacle.height)
                    .scaledToFit()
                    .position(x: obstacle.position.x, y: obstacle.position.y)
            }

            // Bullets
            ForEach(viewModel.bullets) { bullet in
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.yellow)
                    .position(x: bullet.position.x, y: bullet.position.y)
            }

            // Time Elapsed
            Text("Distance: \(viewModel.distance)")
                .font(.headline)
                .foregroundColor(.white)
                .position(x: UIScreen.main.bounds.width - 50, y: 40)

            ZStack {
                if viewModel.showLevelUpBanner {
                    LevelUpBannerView(level: viewModel.level)
                        .transition(.opacity)
                } else {
                    Text("Level: \(viewModel.level)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .position(x: 100, y: 40) // Top-left corner
        }
        .onTapGesture {
            viewModel.throwBullet()
        }
    }
}
