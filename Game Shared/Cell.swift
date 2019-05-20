//
//  Cell.swift
//  Game
//
//  Created by Jonathan Foucher on 20/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import SpriteKit
import os

class Cell {
    var visited = false
    var i: Int
    var j: Int

    fileprivate var coords : CGPoint {
        get {
            let c = size.width * CGFloat(i)
            let c2 = size.height * CGFloat(j)
            
            let x = -UIScreen.main.bounds.width/2 + size.width / 2 + c
            let y = UIScreen.main.bounds.height/2 - size.height / 2 - c2
            return CGPoint(x: x, y: y)
        }
    }
    fileprivate var size : CGSize
    
    var walls : [Wall]
    var linked : [Cell]
    
    
    init(i: Int, j: Int, size: CGSize) {
        self.size = size
        self.i = i
        self.j = j
        self.walls = []
        self.linked = []
    }
    
    func draw() -> [Wall] {
        for index in 1...4 {
            var size: CGSize
            var pos: CGPoint
            var wall: Wall
            
            if(index == 1 || index == 3) {
                size = CGSize(width: self.size.width, height: 5)
                wall = Wall(color: .white, size: size)
                
                if (index == 1) {
                    pos = CGPoint(x: self.coords.x, y: self.coords.y  + self.size.height / 2)
                } else {
                    pos = CGPoint(x: self.coords.x, y: self.coords.y -  self.size.height / 2)
                }
            } else {
                size = CGSize(width: 5, height: self.size.height)
                wall = Wall(color: .white, size: size)
                if (index == 2) {
                    pos = CGPoint(x: self.coords.x - self.size.width / 2, y: self.coords.y)
                } else {
                    pos = CGPoint(x: self.coords.x + self.size.width / 2, y: self.coords.y)
                }
            }
            wall.position = pos
            
            self.walls.append(wall)
        }
        
        return self.walls
        
    }
}
