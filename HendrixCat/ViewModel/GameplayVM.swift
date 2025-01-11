//
//  GameplayView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//
import SwiftUI
import AVFAudio

struct GameplayVM: View {
    @State private var rocketAudioPlayer: AVAudioPlayer?
    @Binding var rocketPosition: CGFloat
    @Binding var obstacles: [Obstacle]
    @Binding var bullets: [Bullet]
    let timeElapsed: Int
    @Binding var gameOver: Bool
    let onCollision: () -> Void

    // Audio Player for the rocket sound
     var rocketSoundPlayer: AVAudioPlayer? = {
        guard let soundURL = Bundle.main.url(forResource: "rocketSound", withExtension: "m4a") else {
            print("Error: rocketSound.wav not found in the bundle.")
            return nil
        }
        do {
            return try AVAudioPlayer(contentsOf: soundURL)
        } catch {
            print("Error initializing rocket sound: \(error)")
            return nil
        }
    }()

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
            playRocketSound()
        }
    }

    func playRocketSound() {
        guard let soundURL = Bundle.main.url(forResource: "rocketSound", withExtension: "m4a") else {
            print("Error: Rocket sound file not found.")
            return
        }
        do {
            rocketAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            rocketAudioPlayer?.prepareToPlay()
            rocketAudioPlayer?.play()
        } catch {
            print("Error loading rocket sound: \(error.localizedDescription)")
        }
    }
}
