//
//  AAPLEnemyChaseState.swift
//  Maze
//
//  Created by Wayne on 15/10/28.
//  Copyright © 2015年 SWIFT.HOW. All rights reserved.
//

import GameplayKit

class AAPLEnemyChaseState: AAPLEnemyState {
    
    var ruleSystem: GKRuleSystem
    
    var hunting: Bool = false {
        
        willSet {
            if self.hunting != newValue {
                if(!newValue) {
                    if let game = self.game {
                        let positions = game.random.arrayByShufflingObjects(in: game.level.enemyStartPositions!)
                        self.scatterTarget = positions.first as? GKGridGraphNode
                    }
                }
            }
        }
    }
    
    var scatterTarget: GKGridGraphNode?
    
    override init(withGame game: AAPLGame, entity: AAPLEntity) {
        
        ruleSystem = GKRuleSystem()
        
        let playerFar = NSPredicate(format: "$distanceToPlayer.floatValue >= 10.0")
        ruleSystem.add(GKRule(predicate: playerFar, assertingFact: "hunt" as NSObjectProtocol, grade: 1.0))
        
        let playerNear = NSPredicate(format: "$distanceToPlayer.floatValue < 10.0")
        ruleSystem.add(GKRule(predicate: playerNear, retractingFact: "hunt" as NSObjectProtocol, grade: 1.0))
        
        super.init(withGame: game, entity: entity)
    }
    
    func pathToPlayer() -> [GKGridGraphNode] {
        if let graph = game?.level.pathfindingGraph {
            if let playerNode = graph.node(atGridPosition: (game?.player.gridPosition)!) {
                return self.pathToNode(playerNode)
            }
        }
        
        return []
    }
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == AAPLEnemyFleeState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let component = entity.component(ofType: AAPLSpriteComponent) {
            component.useNormalAppearance()
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        // If the enemy has reached its target, choose a new target.
        let position = entity.gridPosition
        
        if let scatterTarget = self.scatterTarget {
            if (position.x == scatterTarget.gridPosition.x && position.y == scatterTarget.gridPosition.y) {
                self.hunting = true
            }
        }
        
        let distanceToPlayer = self.pathToPlayer().count
        ruleSystem.state["distanceToPlayer"] = NSNumber(value: distanceToPlayer as Int)
        
        ruleSystem.reset()
        ruleSystem.evaluate()
        
        hunting = (self.ruleSystem.grade(forFact: "hunt" as NSObjectProtocol) > 0.0)
        if hunting {
            startFollowingPath(pathToPlayer())
        } else {
            if let scatterTarget = scatterTarget {
                startFollowingPath(pathToNode(scatterTarget))
            }
        }
    }
}
