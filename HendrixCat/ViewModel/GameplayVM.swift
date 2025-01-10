//
//  GameplayView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//
import SwiftUI

struct GameplayVM: View {
    @Binding var rocketPosition: CGFloat
    @Binding var obstacles: [Obstacle]
    @Binding var bullets: [Bullet]
    let timeElapsed: Int
    @Binding var gameOver: Bool
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
                if obstacle.type == .planet {
                    PlanetObstacleView()
                        .position(x: obstacle.xPosition, y: obstacle.yPosition)
                } else if obstacle.type == .satellite {
                    SateliteObstacleView()
                        .position(x: obstacle.xPosition, y: obstacle.yPosition)
                }
            }

            // Bullets
            ForEach(bullets) { bullet in
                BulletView()
                    .position(x: bullet.xPosition, y: bullet.yPosition)
            }

            // Time Elapsed
            Text("Time: \(timeElapsed)")
                .font(.headline)
                .foregroundColor(.white)
                .position(x: UIScreen.main.bounds.width - 80, y: 40)
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
        }
    }
}
