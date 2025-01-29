//
//  GameplayView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//
import SwiftUI
import AVFAudio

struct GameplayVM: View {
     var audioManager: AudioManager

    @State private var rocketAudioPlayer: AVAudioPlayer?
    @Binding var rocketPosition: CGFloat
    @Binding var obstacles: [Obstacle]
    @Binding var bullets: [Bullet]
    let timeElapsed: Int
    @Binding var gameOver: Bool

    @Binding var showLevelUpBanner: Bool
    @Binding var level: Int
    @Binding var currentBackground: String
    @Binding var nextBackground: String
    @Binding var isAnimatingBackground: Bool
    let onCollision: () -> Void

    var body: some View {
        ZStack {
            // Static Background
            Image("space_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            // Rocket
            RocketView()
                .position(x: rocketPosition, y: UIScreen.main.bounds.height * 0.8)

            // Obstacles
            ForEach(obstacles) { obstacle in
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
            ForEach(bullets) { bullet in
                BulletView()
                    .position(x: bullet.xPosition, y: bullet.yPosition)
            }
//
//            if showLevelUpBanner {
//                           LevelUpBanner(level: level)
//                               .transition(.opacity)
//                               .position(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY - 100)
//                       }

            // Time Elapsed
            Text("Time: \(timeElapsed)")
                .font(.headline)
                .foregroundColor(.white)
                .position(x: UIScreen.main.bounds.width - 80, y: 40)

            ZStack {
                if showLevelUpBanner {
                    LevelUpBannerView(level: level)
                        .transition(.opacity)
                } else {
                    Text("Level: \(level)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .position(x: 100, y: 40) // Top-left corner
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    let width = UIScreen.main.bounds.width
                    rocketPosition = min(max(value.location.x, 0), width)
                }
        )
        .onTapGesture {
            let bullet = Bullet(
                xPosition: rocketPosition,
                yPosition: UIScreen.main.bounds.height * 0.8
            )
            bullets.append(bullet)
            audioManager.playSoundEffect(named: "rocketSound", withExtension: "m4a")
        }
    }
}
