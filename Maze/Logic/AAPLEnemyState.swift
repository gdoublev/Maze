//
//  AAPLEnemyState.swift
//  Maze
//
//  Created by Wayne on 15/10/28.
//  Copyright © 2015年 SWIFT.HOW. All rights reserved.
//

import GameplayKit

class AAPLEnemyState: GKState {
    
    weak var game: AAPLGame?
    
    var entity: AAPLEntity
    
    init(withGame game: AAPLGame, entity: AAPLEntity) {
        self.game = game
        self.entity = entity
        
        super.init()
    }
    
    func pathToNode(_ node: GKGridGraphNode) -> [GKGridGraphNode] {
        if let graph = game?.level.pathfindingGraph {
            if let enemyNode = graph.node(atGridPosition: entity.gridPosition) {
                return graph.findPath(from: enemyNode, to: node) as! [GKGridGraphNode]
            }
        }
        
        return []
    }
    
    func startFollowingPath(_ path: [GKGridGraphNode]) {
        /*
            Set up a move to the first node on the path, but
            no farther because the next update will recalculate the path.
        */
        
        if path.count > 1 {
            let firstMove = path[1]
            if let component = entity.component(ofType: AAPLSpriteComponent) {
                component.nextGridPosition = firstMove.gridPosition
            }
        }
    }
}
