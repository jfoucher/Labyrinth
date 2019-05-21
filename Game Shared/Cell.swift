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

struct NCoord {
    var coord: Coord
    var loc: String
}

class Cell: NSCopying {
    var visited = false
    var exit = false
    var coord: Coord
    var max: Coord
    var index: Int
    var scoreLabel: SKLabelNode!
    var mazeSize: CGSize
    
    var coordinates : CGPoint {
        get {
            let c = size.width * CGFloat(coord.i)
            let c2 = size.height * CGFloat(coord.j)
            
            let x = -mazeSize.width/2 + size.width / 2 + c
            let y = mazeSize.height/2 - size.height / 2 - c2
            return CGPoint(x: x, y: y)
        }
    }
    
    var neighbours : [NCoord] {
        get {
            var n = [
                NCoord(coord: Coord(i: coord.i+1, j:coord.j), loc: "E"),
                NCoord(coord: Coord(i: coord.i-1, j:coord.j), loc: "W"),
                NCoord(coord: Coord(i: coord.i, j:coord.j+1), loc: "S"),
                NCoord(coord: Coord(i: coord.i, j:coord.j-1), loc: "N"),
            ]
            
            if (coord.i == 0) {
                if let index = n.firstIndex(where: {$0.loc == "W"}) {
                    n.remove(at: index)
                }
            } else if (coord.i > max.i) {
                if let index = n.firstIndex(where: {$0.loc == "E"}) {
                    n.remove(at: index)
                }
            }
            
            if (coord.j == 0) {
                if let index = n.firstIndex(where: {$0.loc == "N"}) {
                    n.remove(at: index)
                }
            } else if (coord.j > max.j) {
                if let index = n.firstIndex(where: {$0.loc == "S"}) {
                    n.remove(at: index)
                }
            }
            
            return n
        }
    }
    
    fileprivate var size : CGSize
    
    var walls : [Wall]
    var linked : [Cell]
    
    
    init(coord: Coord, size: CGSize, max: Coord, index: Int, mazeSize: CGSize) {
        self.size = CGSize(width: size.width, height: size.height)
        self.coord = coord
        self.max = max
        self.walls = []
        self.linked = []
        self.index = index
        self.mazeSize = mazeSize
    }
    
    func copy(with zone: NSZone? = nil) -> Any {
        let ind = self.index
        return Cell(coord: self.coord, size: self.size, max: self.max, index: ind, mazeSize: self.mazeSize)
    }
    
    func draw() -> [Wall] {
        for n in ["N", "S", "E", "W"] {
            var size: CGSize
            var pos: CGPoint
            var wall: Wall
            
            if (n == "N") {
                if self.linked.filter({
                    $0.coord.i == self.coord.i && $0.coord.j == self.coord.j + 1
                }).count == 0 && !self.exit {
                    size = CGSize(width: self.size.width + 5, height: 5)
                    wall = Wall(color: .white, size: size)
                    pos = CGPoint(x: self.coordinates.x, y: self.coordinates.y - self.size.height / 2)
                    wall.position = pos
                    
                    self.walls.append(wall)
                }
            } else if (n == "S") {
                if self.linked.filter({
                    $0.coord.i == self.coord.i && $0.coord.j == self.coord.j - 1
                }).count == 0 && !self.exit {
                    size = CGSize(width: self.size.width + 5, height: 5)
                    wall = Wall(color: .white, size: size)
                    pos = CGPoint(x: self.coordinates.x, y: self.coordinates.y + self.size.height / 2)
                    wall.position = pos
                    
                    self.walls.append(wall)
                }
            } else if (n == "E") {
                if self.linked.filter({
                    $0.coord.i == self.coord.i - 1 && $0.coord.j == self.coord.j
                }).count == 0  && !self.exit {
                    size = CGSize(width: 5, height: self.size.height + 5)
                    wall = Wall(color: .white, size: size)
                    pos = CGPoint(x: self.coordinates.x - self.size.width / 2, y: self.coordinates.y)
                    wall.position = pos
                    
                    self.walls.append(wall)
                }
            } else {
                if self.linked.filter({
                    $0.coord.i == self.coord.i + 1 && $0.coord.j == self.coord.j
                }).count == 0  && !self.exit {
                    size = CGSize(width: 5, height: self.size.height + 5)
                    wall = Wall(color: .white, size: size)
                    pos = CGPoint(x: self.coordinates.x + self.size.width / 2, y: self.coordinates.y)
                    wall.position = pos
                    
                    self.walls.append(wall)
                }
            }
            
            
        }
        
        return self.walls
        
    }
    
    func label() -> SKLabelNode {
        self.scoreLabel = SKLabelNode()
        self.scoreLabel.text = "\(self.coord.i) \(self.coord.j)"
        self.scoreLabel.horizontalAlignmentMode = .center
        self.scoreLabel.fontSize = 12
        self.scoreLabel.position = self.coordinates
        return self.scoreLabel
    }
}
