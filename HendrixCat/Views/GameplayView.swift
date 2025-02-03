import SwiftUI
import AVKit
import UIKit

struct GameplayView: View {
    // MARK: - Properties
    let onExit: () -> Void

    @State private var rocketPosition: CGFloat = UIScreen.main.bounds.width / 2
    @State private var obstacles: [Obstacle] = []
    @State private var bullets: [Bullet] = []
    @State private var gameOver = false
    @State private var timeElapsed: Int = 0
    @State private var timer: Timer?
    @State private var speed: CGFloat = 5
    @State private var showLevelUpBanner = false
    @State private var level = 1
    @State private var currentBackground = "space_background"
    @State private var nextBackground = "space_background"
    @State private var isAnimatingBackground = false

    private let audioManager = AudioManager()

    var body: some View {
        ZStack {
            GameplayVM(
                audioManager: audioManager,
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
                    onRestart: resetGame,
                    onExit: onExit
                )
            }
        }// test push
        .onAppear(perform: startGame)
        .onDisappear(perform: cleanupResources)
    }
}

extension GameplayView {
    // MARK: - Game Lifecycle
    private func startGame() {
        resetGameState()
        audioManager.playBackgroundMusic(named: "chords")
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateGame()
        }
    }

    private func stopGame() {
        gameOver = true
        timer?.invalidate()
        audioManager.stopBackgroundMusic()
        audioManager.playSoundEffect(named: "gameStop")
        triggerVibration()
    }

    private func resetGame() {
        resetGameState()
        startGame()
    }

    private func cleanupResources() {
        timer?.invalidate()
        audioManager.stopBackgroundMusic()
    }

    private func resetGameState() {
        rocketPosition = UIScreen.main.bounds.width / 2
        timeElapsed = 0
        level = 1
        obstacles = []
        bullets = []
        gameOver = false
        speed = 5
    }

    // MARK: - Game Updates
    private func updateGame() {
        guard !gameOver else { return }

        timeElapsed += 1

        if timeElapsed % 20 == 0 {
            speed += 1
        }

        if timeElapsed % 100 == 0 {
            triggerLevelUpEffect()
        }

        moveObstacles()
        moveBullets()
        checkCollisions()
    }

    private func moveObstacles() {
        for index in obstacles.indices {
            obstacles[index].yPosition += speed
        }
        obstacles.removeAll { $0.yPosition > UIScreen.main.bounds.height }

        if Int.random(in: 0...10) == 0 {
            spawnObstacle()
        }
    }

    private func spawnObstacle() {
        let randomType = ObstacleType.allCases.randomElement() ?? .planet
        obstacles.append(Obstacle(
            xPosition: CGFloat.random(in: 0...UIScreen.main.bounds.width),
            yPosition: -50,
            type: randomType
        ))
    }

    private func moveBullets() {
        for index in bullets.indices {
            bullets[index].yPosition -= 10
        }

        bullets.removeAll { $0.yPosition < 0 }
    }

    private func checkCollisions() {
        var bulletsToRemove: Set<UUID> = []
        var obstaclesToRemove: Set<UUID> = []

        for bullet in bullets {
            for obstacle in obstacles {
                if bullet.frame.intersects(obstacle.frame) {
                    bulletsToRemove.insert(bullet.id)
                    obstaclesToRemove.insert(obstacle.id)
                    audioManager.playSoundEffect(named: "bubblePop")
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

    // MARK: - Level Up
    private func triggerLevelUpEffect() {
        level += 1
        isAnimatingBackground = true
        currentBackground = nextBackground
        nextBackground = "background_\(level % 5 + 1)"
        audioManager.playSoundEffect(named: "levelUp")
        showLevelUpBanner = true

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            showLevelUpBanner = false
            isAnimatingBackground = false
        }
    }

    // MARK: - Helpers
    private func triggerVibration() {
        UINotificationFeedbackGenerator().notificationOccurred(.error)
    }
}

extension Bullet {
    var frame: CGRect {
        CGRect(x: xPosition - 5, y: yPosition - 5, width: 10, height: 10)
    }
}

extension Obstacle {
    var frame: CGRect {
        CGRect(x: xPosition - 25, y: yPosition - 25, width: 50, height: 50)
    }
}

extension GameplayView {
    var rocketFrame: CGRect {
        CGRect(
            x: rocketPosition - 20,
            y: UIScreen.main.bounds.height * 0.8 - 20,
            width: 40,
            height: 40
        )
    }
}
