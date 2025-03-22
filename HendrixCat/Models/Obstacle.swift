//
//  Obstacle.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI

// TODO: Look to embed in protocol

enum ObstacleType: CaseIterable {
    case planet
    case satelliteBlue
    case satelliteOrange
    case moon
    case alien
    
    var toString: String {
        switch self {
        case .planet:
            return "mars_planet"
        case .satelliteBlue:
            return "satellite_blue"
        case .satelliteOrange:
            return "satellite_orange"
        case .moon:
            return "moon"
        case .alien:
            return "alien"
        }
    }
}

struct Obstacle: Identifiable {
    let id = UUID()
    let type: ObstacleType

    var position: CGPoint
    var width: CGFloat
    var height: CGFloat
    var frame: CGRect {
        CGRect(x: position.x - 25, y: position.y - 25, width: 50, height: 50)
    }
}
