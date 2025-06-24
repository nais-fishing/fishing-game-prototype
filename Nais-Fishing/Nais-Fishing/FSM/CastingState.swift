//
//  CastingState.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 18/06/25.
//

import GameplayKit

class CastingState: GKState {
    unowned let scene: FishingScene
    
    var bear: SKSpriteNode?
    
    init(scene: FishingScene) {
        self.scene = scene
    }
    
    override func didEnter(from previousState: GKState?) {

        scene.castPower = 0
        scene.isCharging = true
        scene.showPowerBar()
        
        if let bear = scene.childNode(withName: "bearNode") as? SKSpriteNode {
            bear.texture = SKTexture(imageNamed: "bear-casting")
        }
        
        print("⚡ Charging started")
    }

    override func update(deltaTime seconds: TimeInterval) {

        if scene.isCharging {
            scene.castPower += CGFloat(seconds * 100)
            if scene.castPower > scene.maxCastPower {
                scene.castPower = scene.maxCastPower
            }
            scene.updatePowerBar()
        }
    }

    override func willExit(to nextState: GKState) {
        scene.isCharging = false
        print("🎯 Final cast power: \(scene.castPower)")
        
//        if let bear = scene.childNode(withName: "bearNode") as? SKSpriteNode {
//            bear.texture = SKTexture(imageNamed: "bear-waiting")
//        }
        
        bear?.texture = SKTexture(imageNamed: "bear-casting")

        
        scene.playCastAnimation(withPower: scene.castPower) {
            self.stateMachine?.enter(WaitingForHookState.self)
        }
    }
}
