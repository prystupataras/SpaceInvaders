//
//  Bullet.swift
//  SpaceInvaders
//
//  Created by Prystupa Taras on 03.09.2024.
//

import Foundation

struct Bullet: Identifiable {
    var id: UUID
    var position: CGPoint
    var velocity: CGVector
    var isPlayerBullet: Bool
}
