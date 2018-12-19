//
//  AAPLSpriteComponent.swift
//  Maze
//
//  Created by Wayne on 15/10/28.
//  Copyright © 2015年 SWIFT.HOW. All rights reserved.
//

import GameplayKit
import SpriteKit

class AAPLSpriteComponent: GKComponent {
    var sprite: AAPLSpriteNode?
    var defaultColor: SKColor
    
    var pulseEffectEnabled: Bool = false {
        didSet {
            if (pulseEffectEnabled) {
                let grow = SKAction.scale(by: 1.5, duration: 0.5)
                let sequence = SKAction.sequence([grow, grow.reversed()])
                
                sprite?.run(SKAction.repeatForever(sequence), withKey: "pulse")
            } else {
                sprite?.removeAction(forKey: "pulse")
                sprite?.run(SKAction.scale(to: 1.0, duration: 0.5))
            }
        }
    }
    
    var nextGridPosition: vector_int2 = vector_int2(0, 0) {
        willSet {
            if (self.nextGridPosition.x != newValue.x || self.nextGridPosition.y != newValue.y) {
//                self.nextGridPosition = newValue
                
                if let scene = sprite?.scene as? AAPLScene {
                    let action = SKAction.move(to: scene.pointForGridPosition(nextGridPosition), duration: 0.35)
                    let update = SKAction.run({ () -> Void in
                        if let entity = self.entity as? AAPLEntity {
                            entity.gridPosition = self.self.nextGridPosition
                        }
                    })
                    
                    sprite?.run(SKAction.sequence([action, update]), withKey: "move")
                }
            }
        }
    }
    
    init(withDefaultColor defaultColor: SKColor) {
        self.defaultColor = defaultColor
        
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func useNormalAppearance() {
        sprite?.color = defaultColor
    }
    
    func useFleeAppearance() {
        sprite?.color = SKColor.white
    }
    
    func useDefeatedAppearance() {
        sprite?.run(SKAction.scale(to: 0.25, duration: 0.25))
    }
    
    func warpToGridPosition(_ gridPosition: vector_int2) {
        if let scene = sprite?.scene as? AAPLScene {
            let fadeOut = SKAction.fadeOut(withDuration: 0.5)
            let warp = SKAction.move(to: scene.pointForGridPosition(gridPosition), duration: 0.5)
            let fadeIn = SKAction.fadeIn(withDuration: 0.5)
            let update = SKAction.run({ () -> Void in
                if let entity = self.entity as? AAPLEntity {
                    entity.gridPosition = gridPosition
                }
            })
            
            sprite?.run(SKAction.sequence([fadeOut, update, warp, fadeIn]))
        }
    }
    
    func followPath(_ path: [GKGridGraphNode], completionHandler: @escaping (() -> Void)) {
        // Ignore the first node in the path -- it's the starting position.
        let dropFirst = path[1..<path.count]
        var sequence: [SKAction] = []
        
        for node in dropFirst {
            if let scene = sprite?.scene as? AAPLScene {
                let point = scene.pointForGridPosition(node.gridPosition)
                sequence.append(SKAction.move(to: point, duration: 0.15))
                sequence.append(SKAction.run({ () -> Void in
                    if let entity = self.entity as? AAPLEntity {
                        entity.gridPosition = node.gridPosition
                    }
                }))
            }
            
            sequence.append(SKAction.run(completionHandler))
            sprite?.run(SKAction.sequence(sequence))
        }
    }
}

