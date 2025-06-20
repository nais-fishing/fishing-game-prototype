//
//  FishingScene.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 18/06/25.
//
import SpriteKit
import GameplayKit

class FishingScene: SKScene {
    
    var river: SKSpriteNode!
    var bear: SKSpriteNode!
    var stateMachine: FishingGameStateMachine!
    var castingManager: CastingManager!
    
    override func didMove(to view: SKView) {
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupRiver()
        setupBear()
        
        scaleMode = .resizeFill
        
        castingManager = CastingManager(scene: self)
        
        stateMachine = FishingGameStateMachine(scene: self)
        
        print("✅ Game initialized with rod fishing mechanism!")
    }
    
    func setupRiver() {
        river = SKSpriteNode(imageNamed: "bg-test")
        river.position = .zero
        river.zPosition = 0

        // Gunakan ukuran scene yang sudah aktif
        river.size = self.size
        
        addChild(river)
        
        print("🏞️ River created at position: \(river.position)")
    }
    
    func setupBear() {
        bear = SKSpriteNode(imageNamed: "bear-idle-test")
        bear.name = "bearNode" // penting! agar FSM bisa akses dengan childNode(withName:)
        bear.position = CGPoint(x: -200, y: 0)
        bear.zPosition = 1
        
        bear.size = CGSize(width: 100, height: 100)
        
        addChild(bear)
        
        print("✅ Bear is there")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Misalnya: Saat pertama disentuh, masuk ke CastingState
        stateMachine.enter(CastingState.self)
    }
}

