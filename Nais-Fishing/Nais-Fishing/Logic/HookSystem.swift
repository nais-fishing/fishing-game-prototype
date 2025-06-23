//
//  HookSystem.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 18/06/25.
//

import SpriteKit

protocol HookSystemDelegate: AnyObject {
    func hookSystem(_ hookSystem: HookSystem)
    func hookSystemDidShowSign(_ hookSystem: HookSystem)
    
}

class HookSystem {
    
    weak var scene: SKScene!
    weak var delegate: HookSystemDelegate?
    
    private var bait: SKSpriteNode!
    private var caughtSign: SKLabelNode!
    private var isFishCaught: Bool = false
    private var hapticManager: HapticManager?
    
    struct PhysicsCategory {
        static let bait: UInt32 = 1
        static let fish: UInt32 = 2
    }
    
    init(scene: SKScene) {
        self.scene = scene
        
        setupBait()
        setupWarning()
    }
    
    func setupBait() {
        guard let scene = scene else { return }
        
        bait = SKSpriteNode(imageNamed: "bait")
        bait.size = CGSize(width: 30, height: 30)
        bait.position = CGPoint(x: -30, y: -75)
        bait.zPosition = 3

        //Set up physics body for bait
        bait.physicsBody = SKPhysicsBody(circleOfRadius: 7.5)
        bait.physicsBody?.isDynamic = true
        bait.physicsBody?.affectedByGravity = false
        bait.physicsBody?.categoryBitMask = 1 // Bait category
        bait.physicsBody?.contactTestBitMask = 2 // Test contact with fish
        bait.physicsBody?.collisionBitMask = 0 // No collision
                
        scene.addChild(bait)
                
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
        
        scene.addChild(caughtSign)
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
    
    func handleFishContact(with fishNode: SKNode) {
        // Remove the caught fish
        fishNode.removeFromParent()
        
        // Show fish caught animations
        //showFishCaughtSign()
        showExclamationMarkAboveBait()
        
        // Notify delegate
        delegate?.hookSystem(self)
        delegate?.hookSystemDidShowSign(self)
    }
        
    func moveBait(to position: CGPoint) {
        bait?.position = position
    }
        
    func getBaitPosition() -> CGPoint {
        return bait?.position ?? CGPoint.zero
    }
        
    func resetCatchState() {
        isFishCaught = false
        caughtSign?.alpha = 0
    }
}

extension HookSystem {
    func shouldHandleContact(between bodyA: SKPhysicsBody, and bodyB: SKPhysicsBody) -> SKNode? {
        // Check if bait and fish collided
        if (bodyA.categoryBitMask == PhysicsCategory.bait && bodyB.categoryBitMask == PhysicsCategory.fish) {
            return bodyB.node
        } else if (bodyA.categoryBitMask == PhysicsCategory.fish && bodyB.categoryBitMask == PhysicsCategory.bait) {
            return bodyA.node
        }
        return nil
    }
}
