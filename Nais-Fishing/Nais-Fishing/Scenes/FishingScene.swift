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
    
    var isFishCaught: Bool = false
    
    override func didMove(to view: SKView) {
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupRiver()
        setupBear()
        spawnFishes()
        
        setupBait()
        setupWarning()
        
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
    
    func setupBait() {
        bait = SKSpriteNode(imageNamed: "bait")
        bait.size = CGSize(width: 25, height: 25)
        bait.position = CGPoint(x: -90, y: -30)
        bait.zPosition = 3

        //Set up physics body for bait
        bait.physicsBody = SKPhysicsBody(circleOfRadius: 7.5)
        bait.physicsBody?.isDynamic = true
        bait.physicsBody?.affectedByGravity = false
        bait.physicsBody?.categoryBitMask = 1 // Bait category
        bait.physicsBody?.contactTestBitMask = 2 // Test contact with fish
        bait.physicsBody?.collisionBitMask = 0 // No collision
                
        addChild(bait)
                
        // Add subtle bobbing animation to bait
        let bobUp = SKAction.moveBy(x: 0, y: 3, duration: 1.0)
        let bobDown = SKAction.moveBy(x: 0, y: -3, duration: 1.0)
        let bobSequence = SKAction.sequence([bobUp, bobDown])
        let bobForever = SKAction.repeatForever(bobSequence)
        bait.run(bobForever, withKey: "bobbing")
    }
    
    func setupWarning() {
        caughtSign = SKLabelNode(text: "!")
        caughtSign.fontName = "Arial-BoldMT"
        caughtSign.fontSize = 28
        caughtSign.fontColor = .yellow
        caughtSign.position = CGPoint(x: 0, y: 100)
        caughtSign.zPosition = 10
        caughtSign.alpha = 0
        
        addChild(caughtSign)
    }
    
    func showFishCaughtSign() {
            guard !isFishCaught else { return }
            
            isFishCaught = true
            
            // Show caught sign with animation
            let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
            let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            let bounce = SKAction.sequence([scaleUp, scaleDown])
            
            let showSign = SKAction.group([fadeIn, bounce])
            caughtSign.run(showSign)
            
            // Reset after 2 seconds
//            let wait = SKAction.wait(forDuration: 2.0)
//            let resetCatch = SKAction.run { [weak self] in
//                self?.resetCatchState()
//            }
//            run(SKAction.sequence([wait, resetCatch]))
    }
    
    func showExclamationMarkAboveBait() {
        // Position the "!" sign above the bait
        caughtSign.position = CGPoint(x: bait.position.x, y: bait.position.y + 40)
        
        // Show and animate the "!" sign
        let fadeIn = SKAction.fadeIn(withDuration: 0.2)
        let scaleUp = SKAction.scale(to: 1.2, duration: 0.2)
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.2)
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        
        let sequence = SKAction.sequence([fadeIn, scaleUp, scaleDown, fadeOut])
        
        // Run the animation on the "!" sign
        caughtSign.run(sequence)
    }

    
    func didBegin(_ contact: SKPhysicsContact) {
        let bodyA = contact.bodyA
        let bodyB = contact.bodyB
        
        // Check if bait and fish collided
        if (bodyA.categoryBitMask == 1 && bodyB.categoryBitMask == 2) ||
           (bodyA.categoryBitMask == 2 && bodyB.categoryBitMask == 1) {
            
            // Remove the caught fish
            if bodyA.categoryBitMask == 2 {
                bodyA.node?.removeFromParent()
            } else {
                bodyB.node?.removeFromParent()
            }
            
            self.showFishCaughtSign()  // Show the fish caught sign
            
            // Show "!" sign above the bait
            showExclamationMarkAboveBait()
            
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
