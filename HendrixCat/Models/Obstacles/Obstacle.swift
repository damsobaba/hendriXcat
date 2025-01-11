//
//  Obstacle.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI

struct Obstacle: Identifiable {
    let id = UUID()
    var xPosition: CGFloat
    var yPosition: CGFloat
    var type: ObstacleType
}
