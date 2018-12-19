//
//  GameViewController.swift
//  Maze
//
//  Created by Wayne on 15/10/28.
//  Copyright (c) 2015年 SWIFT.HOW. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {
    
    var game: AAPLGame?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Create the game and its SpriteKit scene.
        game = AAPLGame()
        if let scene = game?.scene {
            scene.scaleMode = .aspectFit
            
            // Present the scene and configure the SpriteKit view.
            let skView = self.view as! SKView
            skView.presentScene(scene)
            skView.ignoresSiblingOrder = true
            skView.showsFPS = true
            skView.showsNodeCount = true
        }
    }
    
    @IBAction func swipeUp(_ sender: AnyObject) {
        game?.playerDirection = .up
    }
    
    @IBAction func swipeRight(_ sender: AnyObject) {
        game?.playerDirection = .right
    }
    
    @IBAction func swipeDown(_ sender: AnyObject) {
        game?.playerDirection = .down
    }
    
    @IBAction func swipeLeft(_ sender: AnyObject) {
        game?.playerDirection = .left
    }
    
    @IBAction func tap(_ sender: AnyObject) {
        game?.hasPowerup = true
    }
    
}
