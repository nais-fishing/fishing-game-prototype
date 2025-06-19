//
//  IdleState.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 18/06/25.
//

import GameplayKit

class IdleState: GKState {
    unowned let scene: FishingScene

    init(scene: FishingScene) {
        self.scene = scene
    }

    override func didEnter(from previousState: GKState?) {
        // Set sprite idle
        let bear = scene.childNode(withName: "bearNode") as! SKSpriteNode
        bear.texture = SKTexture(imageNamed: "bear-idle-test")
    }
}
