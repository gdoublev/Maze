//
//  AAPLGame.swift
//  Maze
//
//  Created by Wayne on 15/10/28.
//  Copyright © 2015年 SWIFT.HOW. All rights reserved.
//

import SpriteKit
import GameplayKit

enum ContactCategory: UInt32 {
    case player = 2
    case enemy = 4
}

class AAPLGame: NSObject, AAPLSceneDelegate, SKPhysicsContactDelegate {
    
    fileprivate var _scene: AAPLScene?
    
    var level: AAPLLevel!
    
    var enemies: [AAPLEntity]
    
    var player: AAPLEntity
    
    var intelligenceSystem: GKComponentSystem<GKComponent>
    
    var prevUpdateTime: TimeInterval = 0
    
    var playerDirection: AAPLPlayerDirection {
        get {
            if let component = player.component(ofType: AAPLPlayerControlComponent) {
                return component.direction
            } else {
                return .none
            }
        }
        set {
            if let component = player.component(ofType: AAPLPlayerControlComponent) {
                component.attemptedDirection = newValue
            }
        }
    }
    
    var hasPowerup: Bool = false {
        willSet {
            let powerupDuration: TimeInterval = 10
            if self.hasPowerup != newValue {
                var nextState: AnyClass
                if newValue {
                    nextState = AAPLEnemyFleeState.self
                } else {
                    nextState = AAPLEnemyChaseState.self
                }
                
                for component in self.intelligenceSystem.components {
                    (component as! AAPLIntelligenceComponent).stateMachine.enter(nextState)
                }
                powerupTimeRemaining = powerupDuration
            }
        }
    }
    
    var powerupTimeRemaining: CFTimeInterval = 0 {
        didSet {
            if powerupTimeRemaining < 0 {
                self.hasPowerup = false
            }
        }
    }
    
    var random: GKRandomSource
    
    override init() {
        random = GKRandomSource()
        level = AAPLLevel()
        
        // Create player entity with display and control component.
        player = AAPLEntity()
        player.gridPosition = (level.startPosition?.gridPosition)!
        player.addComponent(AAPLSpriteComponent(withDefaultColor: SKColor.cyan))
        player.addComponent(AAPLPlayerControlComponent(withLevel: level))
        
        // Create enemy entities with display and AI components.
        let colors = [SKColor.red, SKColor.green, SKColor.yellow, SKColor.magenta]
        intelligenceSystem = GKComponentSystem(componentClass: AAPLIntelligenceComponent.self)
        enemies = []
        
        super.init()
        
        for i in 0..<level.enemyStartPositions!.count {
            let node = level.enemyStartPositions![i]
            let enemy = AAPLEntity()
            enemy.gridPosition = node.gridPosition
            enemy.addComponent(AAPLSpriteComponent(withDefaultColor: colors[i]))
            enemy.addComponent(AAPLIntelligenceComponent(withGame: self, enemy: enemy, origin: node))
            intelligenceSystem.addComponent(foundIn: enemy)
            enemies.append(enemy)
        }
    }
    
    var scene: SKScene {
        get {
            if _scene == nil {
                _scene = AAPLScene(size: CGSize(width: CGFloat(level.width) * AAPLCellWidth, height: CGFloat(level.height) * AAPLCellWidth))
                
                _scene!.aaplDelegate = self
                _scene!.physicsWorld.gravity = CGVector(dx: 0, dy: 0)
                _scene!.physicsWorld.contactDelegate = self
            }
            
            return _scene!
        }
    }
    
    func didMoveToView(_ scene: AAPLScene, view: SKView) {
        scene.backgroundColor = SKColor.black
        
        // Generate maze.
        let maze = SKNode()
        let cellSize = CGSize(width: AAPLCellWidth, height: AAPLCellWidth);
        
        if let graph = level.pathfindingGraph {
            for i in 0..<level.width {
                for j in 0..<level.height {
                    if graph.node(atGridPosition: vector_int2(Int32(i), Int32(j))) != nil {
                        // Make nodes for traversable areas; leave walls as background color.
                        let node = SKSpriteNode(color: SKColor.gray, size: cellSize)
                        node.position = CGPoint(x: CGFloat(i) * AAPLCellWidth + AAPLCellWidth / 2, y: CGFloat(j) * AAPLCellWidth  + AAPLCellWidth / 2)
                        maze.addChild(node)
                    }
                }
            }
        }
        
        scene.addChild(maze)
        
        // Add player entity to scene.
        let playerComponent = player.component(ofType: AAPLSpriteComponent)
        
        let sprite = AAPLSpriteNode(color: SKColor.cyan, size: cellSize)
        sprite.owner = playerComponent
        sprite.position = scene.pointForGridPosition(player.gridPosition)
        sprite.zRotation = CGFloat(M_PI_4)
        sprite.xScale = CGFloat(M_SQRT1_2)
        sprite.yScale = CGFloat(M_SQRT1_2)
        
        let body = SKPhysicsBody(circleOfRadius: AAPLCellWidth / 2)
        body.categoryBitMask = ContactCategory.player.rawValue
        body.contactTestBitMask = ContactCategory.enemy.rawValue
        body.collisionBitMask = 0
        
        sprite.physicsBody = body
        playerComponent?.sprite = sprite
        scene.addChild((playerComponent?.sprite)!)
        
        // Add enemy entities to scene.
        for entity in enemies {
            if let enemyComponent = entity.component(ofType: AAPLSpriteComponent) {
                enemyComponent.sprite = AAPLSpriteNode(color: enemyComponent.defaultColor, size: cellSize)
                enemyComponent.sprite?.owner = enemyComponent
                enemyComponent.sprite?.position = scene.pointForGridPosition(entity.gridPosition)
                
                let body = SKPhysicsBody(circleOfRadius: AAPLCellWidth / 2 )
                body.categoryBitMask = ContactCategory.enemy.rawValue
                body.contactTestBitMask = ContactCategory.player.rawValue
                body.collisionBitMask = 0
                enemyComponent.sprite?.physicsBody = body
                
                scene.addChild(enemyComponent.sprite!)
            }
        }
    }
    
    func update(_ currentTime: TimeInterval, for scene: SKScene) {
        // Track the time delta since the last update.
        if prevUpdateTime < 0 {
            prevUpdateTime = currentTime
        }
        
        let dt = currentTime - prevUpdateTime
        prevUpdateTime = currentTime
        
        // Track remaining time on the powerup.
        powerupTimeRemaining -= dt
        
        // Update components with the new time delta.
        intelligenceSystem.update(deltaTime: dt)
        player.update(deltaTime: dt)
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        var enemyNode: AAPLSpriteNode?
        if contact.bodyA.categoryBitMask == ContactCategory.enemy.rawValue {
            enemyNode = contact.bodyA.node as? AAPLSpriteNode
        }
        
        if contact.bodyB.categoryBitMask == ContactCategory.enemy.rawValue {
            enemyNode = contact.bodyB.node as? AAPLSpriteNode
        }
        
        assert(enemyNode != nil, "Expected player-enemy/enemy-player collision")
        
        // If the player contacts an enemy that's in the Chase state, the player is attackeed.
        let entity = enemyNode?.owner?.entity
        if let aiComponent = entity?.component(ofType: AAPLIntelligenceComponent) {
            if aiComponent.stateMachine.currentState!.isKind(of: AAPLEnemyChaseState.self) {
                self.playerAttacked()
            } else {
                // Otherwise, that enemy enters the Defeated state only if in a state that allows that transition.
                aiComponent.stateMachine.enter(AAPLEnemyDefeatedState)
            }
        }
    }
    
    func playerAttacked() {
        // Warp player back to starting point.
        if let spriteComponent = player.component(ofType: AAPLSpriteComponent) {
            spriteComponent.warpToGridPosition((level.startPosition?.gridPosition)!)
        }
        
        if let controlComponent = player.component(ofType: AAPLPlayerControlComponent) {
            controlComponent.direction = .none
            controlComponent.attemptedDirection = .none
        }
    }
}
