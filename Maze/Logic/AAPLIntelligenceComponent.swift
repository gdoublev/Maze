//
//  AAPLIntelligenceComponent.swift
//  Maze
//
//  Created by Wayne on 15/10/28.
//  Copyright © 2015年 SWIFT.HOW. All rights reserved.
//

import GameplayKit

class AAPLIntelligenceComponent: GKComponent {
    
    var stateMachine: GKStateMachine
    
    var game: AAPLGame
    
    var enemy: AAPLEntity
    
    var origin: GKGridGraphNode
    
    init(withGame game: AAPLGame, enemy: AAPLEntity, origin: GKGridGraphNode) {
        self.game = game
        self.enemy = enemy
        self.origin = origin
        
        let chase = AAPLEnemyChaseState(withGame: game, entity: enemy)
        let flee = AAPLEnemyFleeState(withGame: game, entity: enemy)
        let defeated = AAPLEnemyDefeatedState(withGame: game, entity: enemy)
        defeated.respawnPosition = origin
        let respawn = AAPLEnemyRespawnState(withGame: game, entity: enemy)
        
        stateMachine = GKStateMachine(states: [chase, flee, defeated, respawn])
        stateMachine.enter(AAPLEnemyChaseState)
        
        super.init()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func update(deltaTime seconds: TimeInterval) {
        stateMachine.update(deltaTime: seconds)
    }
}
