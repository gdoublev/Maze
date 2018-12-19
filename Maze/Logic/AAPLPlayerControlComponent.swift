//
//  AAPLPlayerControlComponent.swift
//  Maze
//
//  Created by Wayne on 15/10/28.
//  Copyright © 2015年 SWIFT.HOW. All rights reserved.
//

import GameplayKit

enum AAPLPlayerDirection {
    case none, left, right, down, up
}

class AAPLPlayerControlComponent: GKComponent {
    var level: AAPLLevel
    
    var direction: AAPLPlayerDirection = .none {
        willSet {
            var proposedNode: GKGridGraphNode?
            if self.direction == .none {
                if let nextNode = self.nextNode {
                    proposedNode = self.nodeInDirection(newValue, fromNode: nextNode)
                }
            } else {
                if let entity = self.entity as? AAPLEntity {
                    let currentNode = self.level.pathfindingGraph?.node(atGridPosition: entity.gridPosition)
                    proposedNode = self.nodeInDirection(newValue, fromNode: currentNode!)
                }
            }
            
            if proposedNode == nil {
                return
            }
        }
    }
    
    var attemptedDirection: AAPLPlayerDirection = .none
    
    var nextNode: GKGridGraphNode?
    
    init(withLevel level: AAPLLevel) {
        self.level = level
        
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func nodeInDirection(_ direction: AAPLPlayerDirection, fromNode node: GKGridGraphNode) -> GKGridGraphNode? {
        var nextPosition: vector_int2
        switch (direction) {
        case .left:
            nextPosition = vector_int2(node.gridPosition.x - 1, node.gridPosition.y)
            break
            
        case .right:
            nextPosition = vector_int2(node.gridPosition.x + 1, node.gridPosition.y)
            break
            
        case .down:
            nextPosition = vector_int2(node.gridPosition.x, node.gridPosition.y - 1)
            break
            
        case .up:
            nextPosition = vector_int2(node.gridPosition.x, node.gridPosition.y + 1)
            break
            
        case .none:
            return nil
        }
        
        return level.pathfindingGraph?.node(atGridPosition: nextPosition)
    }
    
    func makeNextMove() {
        if let entity = entity as? AAPLEntity {
            let currentNode = level.pathfindingGraph?.node(atGridPosition: entity.gridPosition)
            let nextNode = nodeInDirection(direction, fromNode: currentNode!)
            let attemptedNode = nodeInDirection(self.attemptedDirection, fromNode: currentNode!)
            
            if attemptedNode != nil {
                // Move in the attempted direction.
                direction = self.self.attemptedDirection
                self.nextNode = attemptedNode!
                if let component = entity.component(ofType: AAPLSpriteComponent) {
                    component.nextGridPosition = self.nextNode!.gridPosition
                }
            } else if ((attemptedNode == nil) && (nextNode != nil)) {
                // Keep moving in the same direction.
                let dir = self.direction
                self.direction = dir
                self.nextNode = nextNode!
                if let component = entity.component(ofType: AAPLSpriteComponent) {
                    component.nextGridPosition = self.nextNode!.gridPosition
                }
            } else {
                // Can't move any more.
                direction = .none
            }
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        makeNextMove()
    }
}
