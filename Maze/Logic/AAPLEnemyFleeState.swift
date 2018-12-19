//
//  AAPLEnemyFleeState.swift
//  Maze
//
//  Created by Wayne on 15/10/28.
//  Copyright © 2015年 SWIFT.HOW. All rights reserved.
//

import GameplayKit

class AAPLEnemyFleeState: AAPLEnemyState {
    
    var target: GKGridGraphNode?
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == AAPLEnemyChaseState.self ||
            stateClass == AAPLEnemyDefeatedState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        if let component = entity.component(ofType: AAPLSpriteComponent) {
            component.useFleeAppearance()
        }
        
        // Choose a location to flee towards.
        if let game = game {
            target = game.random.arrayByShufflingObjects(in: (game.level.enemyStartPositions)!).first as? GKGridGraphNode
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        let position = entity.gridPosition
        
        if let target = target {
            if (position.x == target.gridPosition.x && position.y == target.gridPosition.y) {
                if let game = game {
                    self.target = game.random.arrayByShufflingObjects(in: (game.level.enemyStartPositions)!).first as? GKGridGraphNode
                }
            }
            
            // Flee towards the current target point.
            startFollowingPath(pathToNode(self.target!))
        }
    }
}
