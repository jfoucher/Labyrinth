//
//  GameScene.swift
//  Game Shared
//
//  Created by Jonathan Foucher on 20/05/2019.
//  Copyright © 2019 Jonathan Foucher. All rights reserved.
//

import SpriteKit
import os
import CoreMotion

var motionManager: CMMotionManager!



class GameScene: SKScene {
    
    fileprivate var touches = Int(0)
    var start = Date()
    fileprivate var maze : Maze?
    fileprivate var spinnyNode : SKShapeNode?
    var circle: SKShapeNode?
    var won: Bool = false {
        willSet(newNow) {
            print(newNow)
            if(newNow == true) {
                let timeElapsed = Date().timeIntervalSince(self.start)
                DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2), execute: {
                    self.removeAllChildren()
                    print("YOU WIN!!")
                    let scoreLabel = SKLabelNode(fontNamed: "Chalkduster")
                    scoreLabel.text = "YOU WIN!!"
                    scoreLabel.fontSize = 50
                    scoreLabel.horizontalAlignmentMode = .center
                    scoreLabel.position = CGPoint(x: 0, y: 0)
                    self.addChild(scoreLabel)
                    let timeLabel = SKLabelNode()
                    timeLabel.text = String(format: "Your time is %.2fs", timeElapsed)
                    timeLabel.horizontalAlignmentMode = .center
                    timeLabel.position = CGPoint(x: 0, y: -100)
                    self.addChild(timeLabel)
                })
            } else {
                self.removeAllChildren()
            }
        }
    }

    var level = 1;
    
    
    class func newGameScene() -> GameScene {
        // Load 'GameScene.sks' as an SKScene.
        guard let scene = SKScene(fileNamed: "GameScene") as? GameScene else {
            print("Failed to load GameScene.sks")
            abort()
        }
        
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .aspectFill
        
        
        return scene
    }
    
    func setUpScene() {
        // Origins seem to be in the middle of everything
        // for height negative is down
        // For width negative is left
        let cameraNode = SKCameraNode()
        
        cameraNode.position = CGPoint(x: self.size.width / 2,
                                      y: self.size.height / 2)
        
        self.addChild(cameraNode)
        self.camera = cameraNode

        self.maze = Maze(cellSize: 60, mazeSize: CGSize(width: pow(Double(level), 0.7) * 180, height: pow(Double(level), 0.7) * 180))
        
        if let maze = self.maze {
            for wall in maze.walls {
                self.addChild(wall)
            }
//            for label in maze.labels {
//                self.addChild(label)
//            }
        }

        self.circle = SKShapeNode(circleOfRadius: 10 )
        if let pos = maze?.startCell?.coordinates, let cir = self.circle {
            cir.position = pos
            cir.strokeColor = .white
            cir.glowWidth = 1.0
            cir.fillColor = .orange
            cir.physicsBody = SKPhysicsBody(circleOfRadius: 12)
            cir.physicsBody?.restitution = 0.6
            cir.physicsBody?.friction = 0.1
            self.addChild(cir)
        }
        self.start = Date()
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        self.setUpScene()
        
        
        let motionManager = CMMotionManager()
        motionManager.startAccelerometerUpdates()
        motionManager.accelerometerUpdateInterval = 0.1
        motionManager.startAccelerometerUpdates(to: OperationQueue.main) { (data, error) in
            if let accelerometerData = motionManager.accelerometerData {
                self.physicsWorld.gravity = CGVector(dx: accelerometerData.acceleration.x * 9.8, dy: 9.8 * accelerometerData.acceleration.y)
            }
            
        }
    }
    #endif


    override func update(_ currentTime: TimeInterval) {
        if let maze = self.maze, let exit = maze.exitCell, let cir = self.circle {
            let coords = exit.coordinates
            //print("\(cir.position.x) \(coords.x) \(maze.cellSize.width)")
            //print("\(cir.position.y) \(coords.y) \(maze.cellSize.height)")
            let distance = pow((cir.position.x - coords.x), 2) + pow((cir.position.y - coords.y), 2);
            let cSize = pow(maze.cellSize.width / 2, 2) + pow(maze.cellSize.height / 2, 2)
            if (distance < cSize && !self.won) {
                self.won = true
            }
        }
        //Camera handling
        if let cam = self.camera, let cir = self.circle {
            let distance = pow((cam.position.x - cir.position.x), 2) + pow((cam.position.y - cir.position.y), 2);
            if (distance > 50) {
                let action = SKAction.move(to: CGPoint(x: cir.position.x, y: cir.position.y), duration: 1.0)
                cam.run(action)
            }
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touches += touches.count
       
        if (self.won == true) {
            self.won = false
            self.level += 1
            self.setUpScene()
        }
        if self.touches >= 5 {
            self.won = true
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            //self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touches -= touches.count
        for t in touches {

        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.touches -= touches.count
        for t in touches {
            //self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        //self.makeSpinny(at: event.location(in: self), color: SKColor.green)
    }
    
    override func mouseDragged(with event: NSEvent) {
        //self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
    }
    
    override func mouseUp(with event: NSEvent) {
        //self.makeSpinny(at: event.location(in: self), color: SKColor.red)
    }

}
#endif

