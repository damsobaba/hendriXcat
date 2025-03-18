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
    @Published var rocketPosition: CGPoint
    @Published var obstacles: [Obstacle] = []
    @Published var bullets: [Bullet] = []
    @Published var gameOver = false
    @Published var timeElapsed: Int = 0
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
    private var initialRocketPosition: CGPoint

    init() {
        initialRocketPosition = CGPoint(x: (screenWidth + screenOffetWidth) / 2, y: screenHeight * 0.8)
        rocketPosition = initialRocketPosition
    }
    
    private var rocketFrame: CGRect {
        CGRect(x: rocketPosition.x - 20,
               y: rocketPosition.y - 20,
               width: 40,
               height: 40)
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

        timeElapsed += 1

        if timeElapsed % 100 == 0 {
            speed += 0.5
            triggerLevelUpEffect()
        }

        moveObstacles()
        moveBullets()
        checkCollisions()
    }

    private func setNewGameState() {
        rocketPosition = initialRocketPosition
        timeElapsed = 0
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
    private func spawnObstacle() {
        let randomType = ObstacleType.allCases.randomElement() ?? .planet
        obstacles.append(Obstacle(xPosition: CGFloat.random(in: screenOffetWidth...screenWidth),
                                  yPosition: -50,
                                  type: randomType))
    }

    private func moveObstacles() {
        for index in obstacles.indices {
            obstacles[index].yPosition += speed
        }

        obstacles.removeAll { $0.yPosition > UIScreen.main.bounds.height }

        if Int.random(in: 0...(20 - level)) == 0 {
            spawnObstacle()
        }
    }
}


// MARK: - Bullets
extension GameplayViewModel {
    func throwBullet() {
        let bullet = Bullet(xPosition: rocketPosition.x, yPosition: rocketPosition.y)
        bullets.append(bullet)
        audioManager.playSoundEffect(named: "rocketSound", withExtension: "m4a")
    }

    private func moveBullets() {
        for index in bullets.indices {
            bullets[index].yPosition -= 15
        }

        bullets.removeAll { $0.yPosition < 0 }
    }
}


// MARK: - Collisions
extension GameplayViewModel {
    private func checkCollisions() {
        var bulletsToRemove: Set<UUID> = []
        var obstaclesToRemove: Set<UUID> = []

        for bullet in bullets {
            for obstacle in obstacles {
                if bullet.frame.intersects(obstacle.frame) {
                    bulletsToRemove.insert(bullet.id)
                    obstaclesToRemove.insert(obstacle.id)
                    audioManager.playSoundEffect(named: "bubblePop")
                    timeElapsed += 10
                }
            }
        }

        bullets.removeAll { bulletsToRemove.contains($0.id) }
        obstacles.removeAll { obstaclesToRemove.contains($0.id) }

        checkRocketCollisions()
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
