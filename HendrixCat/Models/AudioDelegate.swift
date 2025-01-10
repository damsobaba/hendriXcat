//
//  AudioDelegate.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//
import AVFoundation
import AVKit

class AudioDelegate: NSObject, AVAudioPlayerDelegate {
    private let onFinish: () -> Void

    init(handler: @escaping () -> Void) {
        self.onFinish = handler
    }

    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        onFinish()
    }
}
