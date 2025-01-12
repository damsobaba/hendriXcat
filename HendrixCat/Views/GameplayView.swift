//
//  GameplayViewModel.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI
import AVFoundation
import AVKit
import UIKit

struct GameplayView: View {
    let onExit: () -> Void // Exit callback

    @State private var rocketPosition: CGFloat = UIScreen.main.bounds.width / 2
    @State private var obstacles: [Obstacle] = []
    @State private var bullets: [Bullet] = []
    @State private var gameOver = false
    @State private var timeElapsed: Int = 0
    @State private var timer: Timer?
    @State private var speed: CGFloat = 5 // Initial speed
    @State private var audioPlayer: AVAudioPlayer? // Audio player instance
    @State private var currentTrackIndex: Int = 0 // Track index
    private let audioTracks = ["chords"] // List of music tracks
    @State private var gameStopAudioPlayer: AVAudioPlayer? // Separate audio player for the game stop sound
    @State private var showLevelUpBanner: Bool = false

    @State private var level: Int = 1
    @State private var currentBackground: String = "space_background"
    @State private var nextBackground: String = "space_background"
    @State private var isAnimatingBackground: Bool = false
    var soundEffectPlayer: AVAudioPlayer?


    var body: some View {
        ZStack {
            GameplayVM(
                rocketPosition: $rocketPosition,
                obstacles: $obstacles,
                bullets: $bullets,
                timeElapsed: timeElapsed,
                gameOver: $gameOver,
                showLevelUpBanner: $showLevelUpBanner,
                level: $level,
                currentBackground: $currentBackground,
                nextBackground: $nextBackground,
                isAnimatingBackground: $isAnimatingBackground,
                onCollision: stopGame

            )

            if gameOver {
                GameOverView(
                    timeElapsed: timeElapsed,
                    onRestart: {
                        resetGame()
                    },
                    onExit: onExit
                )
            }
        }
        .onAppear(perform: startGame)
        .onDisappear {
            timer?.invalidate() // Clean up timer on exit
            audioPlayer?.stop() // Stop the music when exiting
        }
    }


    // MARK: - Game Logic
    func startGame() {
        timeElapsed = 0
        level = 0
        obstacles = []
        bullets = []
        gameOver = false
        speed = 5

        currentTrackIndex = 0 // Start the music
        playNextTrack()

        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateGame()
        }
    }
    func stopGame() {
        gameOver = true
        timer?.invalidate()
        audioPlayer?.stop()
        playGameStopSound()
        triggerVibration()
    }

    func resetGame() {
        rocketPosition = UIScreen.main.bounds.width / 2
        startGame()
    }

    func updateGame() {
        guard !gameOver else { return }

        // Increment elapsed time
        timeElapsed += 1

        // Gradually increase speed every second
        if timeElapsed % 20 == 0 {
            speed += 1
        }

        // Check for level-up condition
          if timeElapsed % 100 == 0 {
              triggerLevelUpEffect()
          }


        // Move obstacles
        for index in obstacles.indices {
            obstacles[index].yPosition += speed
        }
        obstacles.removeAll { $0.yPosition > UIScreen.main.bounds.height }

        // Spawn new obstacles
        if Int.random(in: 0...10) == 0 {
            let randomType: ObstacleType = {
                let types: [ObstacleType] = [.planet, .satellite, .moon, .alien, .station]
                return types.randomElement() ?? .planet
            }()
            obstacles.append(Obstacle(
                xPosition: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                yPosition: -50,
                type: randomType
            ))
        }

        // Move bullets
        for index in bullets.indices {
            bullets[index].yPosition -= 10
        }
        bullets.removeAll { $0.yPosition < 0 }

        // Check collisions
        var bulletsToRemove: Set<UUID> = []
        var obstaclesToRemove: Set<UUID> = []

        for bullet in bullets {
            for obstacle in obstacles {
                let bulletFrame = CGRect(x: bullet.xPosition - 5, y: bullet.yPosition - 5, width: 10, height: 10)
                let obstacleFrame = CGRect(x: obstacle.xPosition - 25, y: obstacle.yPosition - 25, width: 50, height: 50)

                if bulletFrame.intersects(obstacleFrame) {
                    bulletsToRemove.insert(bullet.id)
                    obstaclesToRemove.insert(obstacle.id)
                }
            }
        }

        bullets.removeAll { bulletsToRemove.contains($0.id) }
        obstacles.removeAll { obstaclesToRemove.contains($0.id) }

        // Check rocket collisions
        for obstacle in obstacles {
            let rocketFrame = CGRect(
                x: rocketPosition - 20,
                y: UIScreen.main.bounds.height * 0.8 - 20,
                width: 40,
                height: 40
            )
            let obstacleFrame = CGRect(
                x: obstacle.xPosition - 25,
                y: obstacle.yPosition - 25,
                width: 50,
                height: 50
            )

            if rocketFrame.intersects(obstacleFrame) {
                stopGame()
                break
            }
        }
    }

    // MARK: - Audio Logic
    func playNextTrack() {
        if currentTrackIndex < audioTracks.count {
            let nextTrack = audioTracks[currentTrackIndex]
            setupAudioPlayer(with: nextTrack)
            audioPlayer?.play()
            currentTrackIndex += 1
        } else {
            currentTrackIndex = 0 // Loop back to the first track
            playNextTrack()
        }
    }

    func setupAudioPlayer(with trackName: String) {
        guard let soundURL = Bundle.main.url(forResource: trackName, withExtension: "wav") else {
            print("Error: Sound file \(trackName) not found.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.delegate = AudioDelegate(handler: playNextTrack)
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
        }
    }



      func playLevelUpSound() {
        guard let soundURL = Bundle.main.url(forResource: "levelUp", withExtension: "wav") else {
            print("Error: Game stop sound file not found.")
            return
        }
        do {
            gameStopAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            gameStopAudioPlayer?.prepareToPlay()
            gameStopAudioPlayer?.play()
        } catch {
            print("Error loading game stop sound: \(error.localizedDescription)")
        }
    }
    func playGameStopSound() {
        guard let soundURL = Bundle.main.url(forResource: "gameStop", withExtension: "wav") else {
            print("Error: Game stop sound file not found.")
            return
        }
        do {
            gameStopAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            gameStopAudioPlayer?.prepareToPlay()
            gameStopAudioPlayer?.play()
        } catch {
            print("Error loading game stop sound: \(error.localizedDescription)")
        }
    }
    func triggerVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }


    // level-up code:
    func triggerLevelUpEffect() {
        level += 1 // Increment the level
        isAnimatingBackground = true // Start background animation

        // Change to the next background
        currentBackground = nextBackground
        nextBackground = "background_\(level % 5 + 1)" // Cycle through background images


        playLevelUpSound()

        // Show level-up banner
        showLevelUpBanner = true

        // Hide the banner after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showLevelUpBanner = false
        }

        // Stop background animation after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isAnimatingBackground = false
        }
    }
}

struct LevelUpBanner: View {
    let level: Int

    var body: some View {
        Text("Level \(level)!")
            .font(.largeTitle)
            .bold()
            .foregroundColor(.yellow)
            .padding()
            .background(Color.black.opacity(0.8))
            .cornerRadius(10)
            .shadow(radius: 10)
            .onAppear {
                triggerVibration()
            }
    }
    func triggerVibration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}
