//
//  AudioDelegate.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//
import AVFoundation
import AVKit

class AudioManager: NSObject, AVAudioPlayerDelegate, ObservableObject {

    private var backgroundAudioPlayer: AVAudioPlayer?
    private var soundEffectPlayers: [AVAudioPlayer] = []
    private let onFinish: (() -> Void)?

    init(onFinish: (() -> Void)? = nil) {
        self.onFinish = onFinish
    }

    // Play background music (looping enabled)
    func playBackgroundMusic(named soundName: String, withExtension ext: String = "wav") {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: ext) else {
            print("Error: \(soundName).\(ext) not found.")
            return
        }
        do {
            backgroundAudioPlayer = try AVAudioPlayer(contentsOf: soundURL)
            backgroundAudioPlayer?.delegate = self
            backgroundAudioPlayer?.numberOfLoops = -1 // Infinite looping
            backgroundAudioPlayer?.prepareToPlay()
            backgroundAudioPlayer?.play()
        } catch {
            print("Error playing background music \(soundName): \(error.localizedDescription)")
        }
    }

    // Play short sound effects
    func playSoundEffect(named soundName: String, withExtension ext: String = "wav") {
        guard let soundURL = Bundle.main.url(forResource: soundName, withExtension: ext) else {
            print("Error: \(soundName).\(ext) not found.")
            return
        }
        do {
            let soundEffectPlayer = try AVAudioPlayer(contentsOf: soundURL)
            soundEffectPlayer.delegate = self
            soundEffectPlayers.append(soundEffectPlayer) // Keep reference to avoid deallocation
            soundEffectPlayer.prepareToPlay()
            soundEffectPlayer.play()
        } catch {
            print("Error playing sound effect \(soundName): \(error.localizedDescription)")
        }
    }

    // Stop background music
    func stopBackgroundMusic() {
        backgroundAudioPlayer?.stop()
    }

    // Clean up finished sound effects
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        if let index = soundEffectPlayers.firstIndex(of: player) {
            soundEffectPlayers.remove(at: index) // Remove finished sound effect
        }
        onFinish?()
    }
}
