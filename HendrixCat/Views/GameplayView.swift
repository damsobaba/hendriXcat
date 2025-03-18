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
            RocketView()
                .position(x: viewModel.rocketPosition.x, y: viewModel.rocketPosition.y)

            // Obstacles
            ForEach(viewModel.obstacles) { obstacle in
                switch obstacle.type {
                case .planet:
                    PlanetObstacleView()
                        .position(x: obstacle.xPosition, y: obstacle.yPosition)
                case .satellite:
                    SateliteObstacleView()
                        .position(x: obstacle.xPosition, y: obstacle.yPosition)
                case .moon:
                    MoonObstacleView()
                        .position(x: obstacle.xPosition, y: obstacle.yPosition)
                case .alien:
                    AlienObstacleView()
                        .position(x: obstacle.xPosition, y: obstacle.yPosition)
                case .station:
                    StationObstacleView()
                        .position(x: obstacle.xPosition, y: obstacle.yPosition)
                }
            }

            // Bullets
            ForEach(viewModel.bullets) { bullet in
                BulletView()
                    .position(x: bullet.xPosition, y: bullet.yPosition)
            }

            // Time Elapsed
            Text("Distance: \(viewModel.timeElapsed)")
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
        .gesture(
            DragGesture()
                .onChanged { value in
                    viewModel.moveRocket(value: value)
                }
        )
        .onTapGesture {
            viewModel.throwBullet()
        }
    }
}
