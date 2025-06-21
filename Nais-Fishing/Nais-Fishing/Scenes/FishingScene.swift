//
//  FishingScene.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 18/06/25.
//
import SpriteKit
import GameplayKit

class FishingScene: SKScene, SKPhysicsContactDelegate {
    
    private var hapticManager: HapticManager?
    
    var river: SKSpriteNode!
    var bear: SKSpriteNode!
    var fish: SKSpriteNode!
    var bait: SKSpriteNode!
    var caughtSign: SKLabelNode!
    
    var stateMachine: FishingGameStateMachine!
    var castingManager: CastingManager!
    var hookSystem: HookSystem!
    
    var isFishCaught: Bool = false
    
    override func didMove(to view: SKView) {
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupRiver()
        setupBear()
        spawnFishes()
        
        setupHookSystem()
        
        scaleMode = .resizeFill
        
        castingManager = CastingManager(scene: self)
        
        stateMachine = FishingGameStateMachine(scene: self)
        
        physicsWorld.contactDelegate = self
        
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
    
    func setupHookSystem() {
        hookSystem = HookSystem(scene: self)
        hookSystem.delegate = self
    }
    
    func setupFish() {
        let fish = SKSpriteNode(color: .white, size: CGSize(width: CGFloat.random(in: 20...30), height: CGFloat.random(in: 35...45))) // randomize besar ikan
        //fish.alpha = 0 // agar fishnya transparan
        
        let randomX = CGFloat.random(in: -75...75)
        let startY = size.height/2 + fish.size.height
        fish.position = CGPoint(x: randomX, y: startY)
        
        fish.zPosition = 1
        
        //FISH PHYSICS
        fish.physicsBody = SKPhysicsBody(rectangleOf: fish.size)
        fish.physicsBody?.isDynamic = true
        fish.physicsBody?.categoryBitMask = 2 // Fish category
        fish.physicsBody?.contactTestBitMask = 1 // Detect bait
        fish.physicsBody?.collisionBitMask = 0 // No physical collision
        
        addChild(fish)
        
        let triggerY: CGFloat = 100
        let moveToTriggerAction = SKAction.moveTo(y: triggerY, duration: 2.0)
        
        //MOVE FROM TOP TO BOTTOM
        let endY = -size.height/2 - fish.size.height
        let totalDistance = abs(endY - triggerY)
        let speed: CGFloat = 100
        let duration = totalDistance / speed
        
        let moveAction = SKAction.moveTo(y: endY, duration: TimeInterval(duration))
        
        // move side to side
        let sideToSide = CGFloat.random(in: -75...75)
        let oscDuration = Double.random(in: 1.0...1.5)
        let oscAction = SKAction.repeatForever(SKAction.sequence([SKAction.moveBy(x: sideToSide, y: 0, duration: oscDuration)]))
        let finalPhaseAction = SKAction.group([oscAction, moveAction])
           
        // Sequence: straight down → side-to-side while moving down → remove
        let removeAction = SKAction.removeFromParent()
        let completeSequence = SKAction.sequence([
            moveToTriggerAction,
            finalPhaseAction,
            removeAction
        ])
        
        fish.run(completeSequence)
    }
    
    func spawnFishes() {
        run(SKAction.repeatForever(SKAction.sequence([
            SKAction.run(setupFish),
            SKAction.wait(forDuration: 1.0, withRange: 0.1)
        ])))
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
            
        if let fishNode = hookSystem.shouldHandleContact(between: bodyA, and: bodyB) {
            hookSystem.handleFishContact(with: fishNode)
            
            // Trigger haptic feedback
            DispatchQueue.global().async { [weak self] in
                self?.hapticManager?.playPop()
            }
        }
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Misalnya: Saat pertama disentuh, masuk ke CastingState
        stateMachine.enter(CastingState.self)
    }
}

extension FishingScene: HookSystemDelegate {
    func hookSystem(_ hookSystem: HookSystem) {
        // Handle fish caught event
        print("🎣 Fish caught at position: \(position)")
        
        // You can add score updates, sound effects, or other game logic here
        // For example:
        // gameScore += 10
        // playFishCaughtSound()
    }
    
    func hookSystemDidShowSign(_ hookSystem: HookSystem) {
        // Handle exclamation mark shown event
        print("❗ Exclamation mark shown!")
        
        // You can add additional effects here if needed
    }
}
