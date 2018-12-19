//
//  AAPLEnemyRespawnState.swift
//  Maze
//
//  Created by Wayne on 15/10/28.
//  Copyright © 2015年 SWIFT.HOW. All rights reserved.
//

import GameplayKit

class AAPLEnemyRespawnState: AAPLEnemyState {

    var timeRemaining: TimeInterval = 10
    
    override func isValidNextState(_ stateClass: AnyClass) -> Bool {
        return stateClass == AAPLEnemyChaseState.self
    }
    
    override func didEnter(from previousState: GKState?) {
        timeRemaining = 10
        
        if let component = entity.component(ofType: AAPLSpriteComponent) {
            component.pulseEffectEnabled = true
        }
    }
    
    override func willExit(to nextState: GKState) {
        if let component = entity.component(ofType: AAPLSpriteComponent) {
            component.pulseEffectEnabled = false
        }
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        self.timeRemaining -= seconds
        if self.timeRemaining < 0 {
            stateMachine?.enter(AAPLEnemyChaseState)
        }
    }
}
