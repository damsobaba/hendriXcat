import SwiftUI
import AVFoundation

struct ContentView: View {
    @State private var rocketPosition: CGFloat = UIScreen.main.bounds.width / 2
    @State private var obstacles: [Obstacle] = []
    @State private var gameOver = false
    @State private var timer: Timer?
    @State private var speed: CGFloat = 5 // Initial speed
    @State private var timeElapsed: Int = 0 // Time elapsed for speed scaling
    @State private var audioPlayer: AVAudioPlayer? // Audio player instance
    @State private var currentTrackIndex: Int = 0 // Track index
    private let audioTracks = ["space-ship", "chords"] // List of music tracks
    @State private var backgroundOffset: CGFloat = 0.0
    @State private var backgroundTimer: Timer? // Timer for the scrolling background

    var body: some View {
        ZStack {

            // Dynamic Background
            GeometryReader { geometry in
                ZStack {
                    // Background layers
                    ForEach(0..<3, id: \.self) { i in
                        Image("space_background")
                            .resizable()
                            .scaledToFill()
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .offset(y: backgroundOffset - CGFloat(i) * geometry.size.height)
                    }
                }
                .onAppear {
                    startBackgroundAnimation(screenHeight: geometry.size.height)
                }
            }

            // Game Content
            if gameOver {
                VStack {
                    Text("Game Over")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                        .padding()

                    Text("You lasted \(timeElapsed) seconds!")
                        .font(.title2)
                        .foregroundColor(.white)
                        .padding()

                    HStack {
                        Button("Restart") {
                            resetGame()
                        }
                        .font(.title)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)

                        // Twitter Share Button
                        Link(destination: twitterShareURL()) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Share on Twitter")
                            }
                            .font(.title)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                    }
                }
            } else {
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

                // Score or Time Display
                Text("Time: \(timeElapsed)")
                    .font(.headline)
                    .foregroundColor(.white)
                    .position(x: UIScreen.main.bounds.width - 80, y: 40)

                // Level Indicator at the bottom of the screen
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text("Level: \(timeElapsed)")
                            .font(.title)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(1))
                            .cornerRadius(10)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding(.bottom, 1) // Add some padding to place it above the bottom edge
                    }
                }
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
        .onAppear(perform: startGame)

    }

    func stopBackgroundAnimation() {
        timer?.invalidate()
    }

    func startBackgroundAnimation(screenHeight: CGFloat) {
        backgroundTimer?.invalidate() // Stop any existing timer

        // Scroll background down smoothly
        backgroundTimer = Timer.scheduledTimer(withTimeInterval: 0.02, repeats: true) { _ in
            withAnimation(.linear(duration: 0.02)) {
                backgroundOffset += 2 // Adjust scroll speed here
            }

            // Reset backgroundOffset to loop seamlessly when it goes beyond the screen height
            if backgroundOffset >= screenHeight {
                backgroundOffset = 0 // Reset to the top, no gap at the bottom
            }
        }
    }

    func twitterShareURL() -> URL {
        let message = "I lasted \(timeElapsed) seconds in this amazing space game! 🚀 Check it out! #SpaceGame"
        let encodedMessage = message.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let appURL = URL(string: "twitter://post?message=\(encodedMessage)")!
        let webURL = URL(string: "https://twitter.com/intent/tweet?text=\(encodedMessage)")!

        // Check if Twitter app is installed
        if UIApplication.shared.canOpenURL(appURL) {
            return appURL
        } else {
            return webURL
        }
    }

    func setupAudioPlayer(with trackName: String) {
        guard let soundURL = Bundle.main.url(forResource: trackName, withExtension: "wav") else {
            print("Error: Sound file \(trackName) not found.")
            return
        }
        do {
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            audioPlayer?.delegate = AudioDelegate(handler: onTrackFinished) // Set delegate
            audioPlayer?.prepareToPlay()
        } catch {
            print("Error loading sound file: \(error.localizedDescription)")
        }
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
        backgroundOffset = 0 // Reset offset to start fresh
        rocketPosition = UIScreen.main.bounds.width / 2
        startGame()
    }

    func updateGame() {
        guard !gameOver else { return } // Stop updating if the game is over

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
                gameOver = true
                timer?.invalidate() // Stop the timer
                audioPlayer?.stop() // Stop the music
                stopBackgroundAnimation()
                break
            }
        }
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

    func onTrackFinished() {
        playNextTrack()
    }
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
    var type: ObstacleType // Type of the obstacle
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
