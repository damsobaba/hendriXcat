import SwiftUI
import AVFoundation
import AVKit

struct ContentView: View {
    @State private var rocketPosition: CGFloat = UIScreen.main.bounds.width / 2
    @State private var obstacles: [Obstacle] = []
    @State private var gameOver = false
    @State private var gameStarted = false // New state to control the game start
    @State private var timer: Timer?
    @State private var speed: CGFloat = 5 // Initial speed
    @State private var timeElapsed: Int = 0 // Time elapsed for speed scaling
    @State private var audioPlayer: AVAudioPlayer? // Audio player instance
    @State private var currentTrackIndex: Int = 0 // Track index
    private let audioTracks = ["space-ship", "chords"] // List of music tracks
    @State private var bullets: [Bullet] = [] // Bullets fired by the rocket
    var body: some View {
        ZStack {
            // Static Background
            Image("space_background")
                .resizable()
                .scaledToFill()
                .edgesIgnoringSafeArea(.all)

            if gameStarted {
                if gameOver {
                    GameOverView(timeElapsed: timeElapsed, onRestart: {
                        resetGame()
                    })
                } else {
                    GameplayView(
                            rocketPosition: $rocketPosition,
                            obstacles: $obstacles,
                            bullets: $bullets,
                            timeElapsed: timeElapsed,
                            gameOver: $gameOver,
                            onCollision: stopGame
                        )
                }
            } else {
                StartMenuView(onStart: {
                    gameStarted = true
                    startGame()
                })
            }
        }
        .gesture(
            DragGesture()
                .onChanged { value in
                    guard !gameOver else { return } // Prevent movement if game is over
                    let width = UIScreen.main.bounds.width
                    rocketPosition = min(max(value.location.x, 0), width)
                }
        )
    }

    // MARK: - Game Logic
    func fireBullet() {
        let rocketY = UIScreen.main.bounds.height * 0.8
        bullets.append(Bullet(xPosition: rocketPosition, yPosition: rocketY - 30))
    }

    func startGame() {
        currentTrackIndex = 0 // Start with the first track
        playNextTrack()
        gameOver = false
        obstacles = []
        speed = 5 // Reset speed
        timeElapsed = 0
        timer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { _ in
            updateGame()
        }
    }

    func resetGame() {
        rocketPosition = UIScreen.main.bounds.width / 2
        gameStarted = false // Show the start menu again
    }

    func stopGame() {
        gameOver = true
        timer?.invalidate() // Stop the timer
        audioPlayer?.stop() // Stop the music
    }

    func updateGame() {
        guard !gameOver else { return }

        // Increment elapsed time
        timeElapsed += 1

        // Gradually increase speed every second
        if timeElapsed % 20 == 0 {
            speed += 1
        }

        // Move obstacles down
        for index in obstacles.indices {
            obstacles[index].yPosition += speed
        }

        // Remove obstacles that are out of screen
        obstacles.removeAll { $0.yPosition > UIScreen.main.bounds.height }

        // Add new obstacles
        if Int.random(in: 0...10) == 0 {
            let randomType: ObstacleType = Bool.random() ? .planet : .satellite
            obstacles.append(Obstacle(xPosition: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                                      yPosition: -50,
                                      type: randomType))
        }

        // Check for collisions
        for obstacle in obstacles {
            if checkCollision(with: obstacle) {
                stopGame()
                break
            }
        }
        for index in bullets.indices {
            bullets[index].yPosition -= 10
        }

        // Remove bullets that go off-screen
        bullets.removeAll { $0.yPosition < 0 }

        // Check for bullet-obstacle collisions
        var bulletsToRemove: Set<UUID> = []
        var obstaclesToRemove: Set<UUID> = []

        for bullet in bullets {
            for obstacle in obstacles {
                let bulletFrame = CGRect(x: bullet.xPosition - 5, y: bullet.yPosition - 5, width: 10, height: 10)
                let obstacleFrame = CGRect(x: obstacle.xPosition - 25, y: obstacle.yPosition - 25, width: 50, height: 50)

                if bulletFrame.intersects(obstacleFrame) {
                    // Mark the bullet and obstacle for removal
                    bulletsToRemove.insert(bullet.id)
                    obstaclesToRemove.insert(obstacle.id)
                }
            }
        }

        // Remove bullets and obstacles after the loops
        bullets.removeAll { bullet in bulletsToRemove.contains(bullet.id) }
        obstacles.removeAll { obstacle in obstaclesToRemove.contains(obstacle.id) }
    }

        func checkCollision(with obstacle: Obstacle) -> Bool {
            let rocketFrame = CGRect(x: rocketPosition - 20,
                                     y: UIScreen.main.bounds.height * 0.8 - 20,
                                     width: 40, height: 40)
            let obstacleFrame = CGRect(x: obstacle.xPosition - 25,
                                       y: obstacle.yPosition - 25,
                                       width: 50, height: 50)

            return rocketFrame.intersects(obstacleFrame)
        }

        func playNextTrack() {
            if currentTrackIndex < audioTracks.count {
                let nextTrack = audioTracks[currentTrackIndex]
                setupAudioPlayer(with: nextTrack)
                audioPlayer?.play()
                currentTrackIndex += 1
            } else {
                currentTrackIndex = 0 // Reset to the first track for looping
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
    }

    // MARK: - Subviews

    struct StartMenuView: View {
        var onStart: () -> Void

        var body: some View {
            VStack {
                Text("Welcome to Space Adventure!")
                    .font(.largeTitle)
                    .foregroundColor(.white)
                    .padding()

                Button(action: {
                    onStart()
                }) {
                    Text("Start Game")
                        .font(.title)
                        .padding()
                        .background(Color.green)
                        .cornerRadius(10)
                        .foregroundColor(.white)
                }
            }
        }
    }

struct GameplayView: View {
    @Binding var rocketPosition: CGFloat
    @Binding var obstacles: [Obstacle]
    @Binding var bullets: [Bullet]
    let timeElapsed: Int
    @Binding var gameOver: Bool
    let onCollision: () -> Void

    var body: some View {
        ZStack {
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
                Circle()
                    .frame(width: 10, height: 10)
                    .foregroundColor(.yellow)
                    .position(x: bullet.xPosition, y: bullet.yPosition)
            }

            // Detect tap to shoot
            Color.clear // Transparent layer for tap gesture
                .contentShape(Rectangle())
                .onTapGesture {
                    shootBullet()
                }
        }
    }

    func shootBullet() {
        guard !gameOver else { return } // Prevent shooting if game over

        let bullet = Bullet(
            xPosition: rocketPosition, // Align bullet's position with the rocket's x-coordinate
            yPosition: UIScreen.main.bounds.height * 0.8 // Start just above the rocket
        )
        bullets.append(bullet)
    }
}
struct GameOverView: View {
    let timeElapsed: Int
    let onRestart: () -> Void

    var body: some View {
        VStack {
            Text("Game Over")
                .font(.largeTitle)
                .foregroundColor(.white)
                .padding()

            Text("You lasted \(timeElapsed) seconds!")
                .font(.title2)
                .foregroundColor(.white)
                .padding()

            Button("Restart") {
                onRestart()
            }
            .font(.title)
            .padding()
            .background(Color.white)
            .cornerRadius(10)
        }
    }
}

// MARK: - Supporting Views and Models
struct Bullet: Identifiable {
    let id = UUID()
    var xPosition: CGFloat
    var yPosition: CGFloat
}

struct RocketView: View {
    var body: some View {
        Image(systemName: "triangle.fill")
            .resizable()
            .frame(width: 40, height: 40)
            .foregroundColor(.red)
    }
}

struct PlanetObstacleView: View {
    var body: some View {
        Circle()
            .frame(width: 30, height: 40)
            .foregroundColor(.green)
    }
}

struct SateliteObstacleView: View {
    var body: some View {
        Rectangle()
            .frame(width: 50, height: 50)
            .foregroundColor(.gray)
    }
}

enum ObstacleType {
    case planet
    case satellite
}

struct Obstacle: Identifiable {
    let id = UUID()
    var xPosition: CGFloat
    var yPosition: CGFloat
    var type: ObstacleType
}

// Audio delegate class
class AudioDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinish: () -> Void

    init(handler: @escaping () -> Void) {
        self.onFinish = handler
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
