//
//  Maze.swift
//  Game
//
//  Created by Jonathan Foucher on 20/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import Foundation
import SpriteKit
import os

class Maze {
    var walls: [Wall]
    var cells: [Cell]
    fileprivate var cellSize: CGSize
    
    init(cellSize: CGFloat) {
        
        var cellNumH = UIScreen.main.bounds.width / cellSize;
        cellNumH.round()
        
        var cellNumV = UIScreen.main.bounds.height / cellSize;
        cellNumV.round()
        
        let intH = Int(cellNumH)
        let intV = Int(cellNumV)
        
        self.cellSize = CGSize(width: UIScreen.main.bounds.width / cellNumH, height: UIScreen.main.bounds.height / cellNumV)
        
        self.walls = []
        
        self.cells = []
        
        // TODO calculate cellsize such that it is as square as possible and we can fit as many as possible in the screen
        
        os_log("H: %d V: %d", intH, intV)
        
        for i in 0...intH * intV - 1 {
            let k = i % intH;
            let j = Int(floor(CGFloat(i) / cellNumH));
            os_log("k: %d j: %d", k, j)
            
            let cell = Cell(i: k, j: j, size: self.cellSize)
            
            let wls = cell.draw()
            
            self.walls.append(contentsOf: wls)
        }
        

    }
    
    
}
