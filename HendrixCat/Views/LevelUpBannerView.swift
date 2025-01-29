//
//  LevelUpBannerView.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 13/01/2025.
//

import AVFoundation
import SwiftUI

struct LevelUpBannerView: View {
    let level: Int

    var body: some View {
        Text("Level \(level)")
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
