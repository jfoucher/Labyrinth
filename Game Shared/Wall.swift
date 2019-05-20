//
//  Wall.swift
//  Game
//
//  Created by Jonathan Foucher on 20/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import SpriteKit

class Wall : SKSpriteNode {
    override init(texture: SKTexture!, color: UIColor, size: CGSize) {
        super.init(texture: nil, color: color, size: size)
        self.physicsBody = SKPhysicsBody(rectangleOf: size)
        self.physicsBody?.isDynamic = false
        self.physicsBody?.restitution = 0.5
    }
    
    required init?(coder adecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
