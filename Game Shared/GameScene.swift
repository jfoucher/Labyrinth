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
    

    fileprivate var maze : Maze?
    fileprivate var spinnyNode : SKShapeNode?
    var circle: SKShapeNode?
    
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
        
        
        self.maze = Maze(cellSize: 80, mazeSize: CGSize(width: 2000, height: 2000))
        
        if let maze = self.maze {
            for wall in maze.walls {
                self.addChild(wall)
            }
            for label in maze.labels {
                self.addChild(label)
            }
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
        
        
        
//        if let floor = floor?.copy() as! SKNode? {
//            self.addChild(floor)
//        }
    
        
        
        // Create shape node to use during mouse interaction
        let w = (self.size.width + self.size.height) * 0.05
        self.spinnyNode = SKShapeNode.init(rectOf: CGSize.init(width: w, height: w), cornerRadius: w * 0.1)
        
        if let spinnyNode = self.spinnyNode {
            spinnyNode.lineWidth = 4.0
            spinnyNode.run(SKAction.repeatForever(SKAction.rotate(byAngle: CGFloat(Double.pi), duration: 1)))
            spinnyNode.run(SKAction.sequence([SKAction.wait(forDuration: 0.5),
                                              SKAction.fadeOut(withDuration: 0.5),
                                              SKAction.removeFromParent()]))
            
            #if os(watchOS)
                // For watch we just periodically create one of these and let it spin
                // For other platforms we let user touch/mouse events create these
                spinnyNode.position = CGPoint(x: 0.0, y: 0.0)
                spinnyNode.strokeColor = SKColor.red
                self.run(SKAction.repeatForever(SKAction.sequence([SKAction.wait(forDuration: 2.0),
                                                                   SKAction.run({
                                                                       let n = spinnyNode.copy() as! SKShapeNode
                                                                       self.addChild(n)
                                                                   })])))
            #endif
        }
    }
    
    #if os(watchOS)
    override func sceneDidLoad() {
        self.setUpScene()
    }
    #else
    override func didMove(to view: SKView) {
        let cameraNode = SKCameraNode()
        
        cameraNode.position = CGPoint(x: self.size.width / 2,
                                      y: self.size.height / 2)
        
        self.addChild(cameraNode)
        self.camera = cameraNode
        
        self.setUpScene()
        if let cir = self.circle {
            cir.addObserver(self, forKeyPath: #keyPath(SKNode.position),
                                    options: [.old, .new, .initial],
                                    context: nil)
        }
        
        
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

    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?, change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        
        print("did \(keyPath) \(#keyPath(SKNode.position))")
        if keyPath == #keyPath(SKNode.position) {
            
            guard let camera = self.camera, let circ = object as? SKNode else { fatalError() }
            
            let loop = SKAction.customAction(withDuration: TimeInterval(CGFloat.infinity)) {_,_ in
                let move = SKAction.move(to: CGPoint(x: circ.position.x, y: circ.position.y), duration: 0.2)
                camera.run(SKAction.sequence([move]))
            }
        }
    }
    
    func makeSpinny(at pos: CGPoint, color: SKColor) {
        if let spinny = self.spinnyNode?.copy() as! SKShapeNode? {
            spinny.position = pos
            spinny.strokeColor = color
            self.addChild(spinny)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {

    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.green)
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.blue)
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        for t in touches {
            self.makeSpinny(at: t.location(in: self), color: SKColor.red)
        }
    }
    
   
}
#endif

#if os(OSX)
// Mouse-based event handling
extension GameScene {

    override func mouseDown(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.green)
    }
    
    override func mouseDragged(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.blue)
    }
    
    override func mouseUp(with event: NSEvent) {
        self.makeSpinny(at: event.location(in: self), color: SKColor.red)
    }

}
#endif

