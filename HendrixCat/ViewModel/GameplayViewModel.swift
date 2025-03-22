//
//  GameplayViewModel.swift
//  HendrixCat
//
//  Created by Victor Derveaux on 18/03/2025.
//

import SwiftUI
import AVFAudio
import UIKit.UIScreen

class GameplayViewModel: ObservableObject {
    @Published var rocketPosition: CGPoint = .zero
    @Published var obstacles: [Obstacle] = []
    @Published var bullets: [Bullet] = []
    @Published var gameOver = false
    @Published var distance: Int = 0
    @Published var level = 1
    @Published var showLevelUpBanner = false

    private let audioManager: AudioManager = AudioManager()
    private let screenOffetWidth: CGFloat = 65

    private var screenWidth = UIScreen.main.bounds.width
    private var screenHeight = UIScreen.main.bounds.height
    private var timer: Timer?
    private var speed: CGFloat = 5
    private var currentBackground = "space_background"
    private var nextBackground = "space_background"

    // TODO: Look to create rocket object singleton + embed in protocol with obstacle and bullet
    private var rocketFrame: CGRect {
        CGRect(x: rocketPosition.x - 20, y: rocketPosition.y - 20, width: 40, height: 40)
    }

    private var initialRocketPosition: CGPoint {
        CGPoint(x: (screenWidth + screenOffetWidth) / 2, y: screenHeight * 0.8)
    }

    init() {
        rocketPosition = initialRocketPosition
    }

    func cleanupResources() {
        timer?.invalidate()
        audioManager.stopBackgroundMusic()
    }

    private func triggerLevelUpEffect() {
        level += 1
        currentBackground = nextBackground
        nextBackground = "background_\(level % 5 + 1)"
        audioManager.playSoundEffect(named: "levelUp")

        withAnimation { // TODO: choose cool animation
            showLevelUpBanner = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showLevelUpBanner = false
            }
        }
    }
}


// MARK: - Game Lifecycle
extension GameplayViewModel {
    func startGame() {
        setNewGameState()
        audioManager.playBackgroundMusic(named: "chords")
        timer = Timer.scheduledTimer(withTimeInterval: 0.03, repeats: true) { _ in
            self.updateGame()
        }
    }

    private func stopGame() {
        gameOver = true
        audioManager.playSoundEffect(named: "gameStop")
        triggerVibration()
        cleanupResources()
    }

    private func updateGame() {
        guard !gameOver else { return }

        distance += 1

        if distance % 100 == 0 {
            speed += 0.5
            triggerLevelUpEffect()
        }

        updateObstacles()
        updateBullets()
        checkBulletsCollisions()
        checkRocketCollisions()
    }

    private func setNewGameState() {
        rocketPosition = initialRocketPosition
        distance = 0
        level = 1
        obstacles = []
        bullets = []
        gameOver = false
        speed = 5
    }
}


// MARK: - Rocket
extension GameplayViewModel {
    func moveRocket(value: DragGesture.Value) {
        rocketPosition.x = min(max(value.location.x, screenOffetWidth), screenWidth)
        rocketPosition.y = max(min(value.location.y, screenHeight * 0.8), screenHeight * 0.2)
    }
}


// MARK: - Obstacles
extension GameplayViewModel {
    private func updateObstacles() {
        // Moving obstacles
        for index in obstacles.indices {
            obstacles[index].position.y += speed
        }

        // Deleting objects that go out of screen
        obstacles.removeAll { $0.position.y > UIScreen.main.bounds.height }

        // Spawning obstacles
        if Int.random(in: 0...(20 - level)) == 0 {
            generateObstacle()
        }
    }

    private func generateObstacle() {
        let randomType = ObstacleType.allCases.randomElement() ?? .planet
        let newObstaclePosition = CGPoint(x: CGFloat.random(in: screenOffetWidth...screenWidth), y: -50)
        let obstacleSize: CGFloat = randomType == .satelliteBlue ? 50 : 40
        let newObstacle = Obstacle(type: randomType,
                                   position: newObstaclePosition,
                                   width: obstacleSize,
                                   height: obstacleSize)

        // Preventing obstacles to overlap by spawning only in empty spaces
        let doesOverlap = obstacles.contains(where: { $0.frame.intersects(newObstacle.frame) })
        if !doesOverlap {
            obstacles.append(newObstacle)
        }
    }
}


// MARK: - Bullets
extension GameplayViewModel {
    private func updateBullets() {
        // Moving bullets
        for index in bullets.indices {
            bullets[index].position.y -= 15
        }

        // Deleting bullets that go out of screen
        bullets.removeAll { $0.position.y < -50 }
    }

    func throwBullet() {
        let bullet = Bullet(position: rocketPosition)
        bullets.append(bullet)
        audioManager.playSoundEffect(named: "rocketSound", withExtension: "m4a")
    }
}


// MARK: - Collisions
extension GameplayViewModel {
    private func checkBulletsCollisions() {
        var bulletsToRemove: Set<UUID> = []
        var obstaclesToRemove: Set<UUID> = []

        for bullet in bullets {
            for obstacle in obstacles {
                if bullet.frame.intersects(obstacle.frame) {
                    bulletsToRemove.insert(bullet.id)
                    obstaclesToRemove.insert(obstacle.id)
                    audioManager.playSoundEffect(named: "bubblePop")
                    distance += 10
                }
            }
        }

        bullets.removeAll { bulletsToRemove.contains($0.id) }
        obstacles.removeAll { obstaclesToRemove.contains($0.id) }
    }

    private func checkRocketCollisions() {
        for obstacle in obstacles {
            if rocketFrame.intersects(obstacle.frame) {
                stopGame()
                break
            }
        }
    }
}


// MARK: - Helpers
extension GameplayViewModel {
    private func triggerVibration() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}
