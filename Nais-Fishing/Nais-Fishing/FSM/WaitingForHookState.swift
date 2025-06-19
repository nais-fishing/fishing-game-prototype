//
//  WaitingForHookState.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 19/06/25.
//

import GameplayKit

class WaitingForHookState: GKState {
    unowned let scene: FishingScene

    init(scene: FishingScene) {
        self.scene = scene
    }

    override func didEnter(from previousState: GKState?) {
        guard let bear = scene.childNode(withName: "bearNode") as? SKSpriteNode else {
            print("❌ Bear node not found in WaitingForHookState")
            return
        }

        bear.texture = SKTexture(imageNamed: "bear-waiting-test")
    }
}
