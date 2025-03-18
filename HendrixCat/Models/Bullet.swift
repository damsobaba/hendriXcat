//
//  Bullet.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI

struct Bullet: Identifiable {
    let id = UUID()
    var xPosition: CGFloat
    var yPosition: CGFloat
    
    var frame: CGRect {
        CGRect(x: xPosition - 5, y: yPosition - 5, width: 10, height: 10)
    }
}
