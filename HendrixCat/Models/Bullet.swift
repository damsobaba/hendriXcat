//
//  Bullet.swift
//  HendrixCat
//
//  Created by Adam Mabrouki on 10/01/2025.
//

import SwiftUI

// TODO: Look to embed in protocol

struct Bullet: Identifiable {
    let id = UUID()
    var position: CGPoint
    var frame: CGRect {
        CGRect(x: position.x - 5, y: position.y - 5, width: 10, height: 10)
    }
}
