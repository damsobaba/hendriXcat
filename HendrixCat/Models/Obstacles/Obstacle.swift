//
//  Obstacle.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI

enum ObstacleType: CaseIterable {
    case planet
    case satellite
    case moon
    case alien
    case station
}

struct Obstacle: Identifiable {
    let id = UUID()
    var xPosition: CGFloat
    var yPosition: CGFloat
    var type: ObstacleType

    var frame: CGRect {
        CGRect(x: xPosition - 25, y: yPosition - 25, width: 50, height: 50)
    }
}
