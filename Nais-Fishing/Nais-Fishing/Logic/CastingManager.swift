//
//  CastingManager.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 18/06/25.
//

import SpriteKit

class CastingManager {
    unowned let scene: FishingScene

    init(scene: FishingScene) {
        self.scene = scene
    }

    func playCastingAnimation(completion: @escaping () -> Void) {
        // Ganti texture ke posisi melempar
        scene.bear.texture = SKTexture(imageNamed: "bear-casting-test")

        // (Opsional) Animasi gerakan
        let wait = SKAction.wait(forDuration: 0.8)
        scene.bear.run(wait) {
            completion()
        }
    }
}

