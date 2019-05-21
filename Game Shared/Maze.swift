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

struct Coord: Equatable {
    var i: Int
    var j: Int
    static func == (lhs: Coord, rhs: Coord) -> Bool {
        return lhs.i == rhs.i && lhs.j == rhs.j
    }
}

struct PossibleExit {
    var cell: Cell
    var stackLength: Int
    var stack: [Cell]
}

enum MazeGenerationError: Error {
    case invalidCells
}


class Maze {
    var walls: [Wall]
    var labels: [SKLabelNode]
    var cells: [Cell]
    fileprivate var cellSize: CGSize
    
    var startCell: Cell?
    
    init(cellSize: CGFloat, mazeSize: CGSize) {
        
        var cellNumH = mazeSize.width / cellSize;
        cellNumH.round()
        
        var cellNumV = mazeSize.height / cellSize;
        cellNumV.round()
        
        let intH = Int(cellNumH)
        let intV = Int(cellNumV)
        
        
        self.cellSize = CGSize(width: mazeSize.width / cellNumH, height: mazeSize.height / cellNumV)
        
        self.walls = []
        self.labels = []
        self.cells = []
        
        // TODO calculate cellsize such that it is as square as possible and we can fit as many as possible in the screen
        
        os_log("H: %d V: %d", intH, intV)
        let max = Coord(i: intH, j: intV)
        // Create cells
        for i in 0...intH * intV - 1 {
            let k = i % intH;
            let j = Int(floor(CGFloat(i) / cellNumH));
            
            let cell = Cell(coord: Coord(i: k, j: j), size: self.cellSize, max: max, index: i, mazeSize: mazeSize)
            
            self.cells.append(cell)
        }
        
        var possibleExit = PossibleExit(cell: Cell(coord: Coord(i: 20, j: 20), size: self.cellSize, max: max, index: 20, mazeSize: mazeSize), stackLength: 0, stack: []);
        var stack = [Cell]();
        
        if let st = self.cells.randomElement() {
            st.visited = true;
            stack.append(st);
            self.startCell = st
            var currentCell = st
            
            
            while stack.count > 0 {
                var neighbours = [Cell]()
                for nei in currentCell.neighbours {
                    for c in self.cells {
                        if c.coord == nei.coord {
                            neighbours.append(c)
                        }
                    }
                }
                
                let unvisited = neighbours.filter { $0.visited == false }
                

                if (unvisited.count > 0) {
                    if let rnd = unvisited.randomElement() {
                        rnd.visited = true
                        rnd.linked.append(currentCell);
                        currentCell.linked.append(rnd);
                        stack.append(rnd);
                        currentCell = rnd;
                    }
                } else {
                    if (currentCell.coord.i == 0
                        || currentCell.coord.j == 0
                        || currentCell.coord.i == intH - 1
                        || currentCell.coord.j == intV - 1
                        ) {
           
                        if (possibleExit.stackLength < stack.count) {
                            possibleExit = PossibleExit(cell: currentCell.copy() as! Cell, stackLength: stack.count, stack: stack)
                        }
                     
                    }
                    currentCell = stack.removeLast();
                }
            
            }
            let f = self.cells.filter { $0.index == possibleExit.cell.index }
            if let ex = f.first {
                self.cells[ex.index].exit = true
            }
            let allCells = self.cells
            
            
            print(allCells.filter {$0.exit}.map {"\($0.index) \($0.coord.i) \($0.coord.j)"})
            
            for ce in allCells {
                let wls = ce.draw()
                self.labels.append(ce.label())
                self.walls.append(contentsOf: wls)
            }
        }
    }
}
