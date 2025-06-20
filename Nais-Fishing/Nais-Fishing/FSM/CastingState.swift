//
//  CastingState.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 18/06/25.
//

import GameplayKit

class CastingState: GKState {
    unowned let scene: FishingScene
    
    init(scene: FishingScene) {
        self.scene = scene
    }
    
    override func didEnter(from previousState: GKState?) {
        guard let bear = scene.childNode(withName: "bearNode") as? SKSpriteNode else {
            print("❌ Bear node not found in CastingState")
            return
        }
        
        bear.texture = SKTexture(imageNamed: "bear-casting-test")
        
        scene.castingManager.playCastingAnimation {
            self.stateMachine?.enter(WaitingForHookState.self)
        }
    }
}
