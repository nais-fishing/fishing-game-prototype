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
    var powerBarBackground: SKShapeNode!
    var powerBarFill: SKShapeNode!
    var lastUpdateTime: TimeInterval = 0
    var castPower: CGFloat = 0.0
    var maxCastPower: CGFloat = 100.0
    var isCharging: Bool = false
    
    var stateMachine: FishingGameStateMachine!
    var fish: SKSpriteNode!
    var bait: SKSpriteNode!
    var caughtSign: SKLabelNode!
    
    //var stateMachine: FishingGameStateMachine!
    var castingManager: CastingManager!
    var hookSystem: HookSystem!
    var fishingLineSystem: FishingLineSystem!
    
    var isFishCaught: Bool = false
    
//     Lydia(untuk catchbar)
//    var progressBarContainer: SKSpriteNode!
//    var greenBar: SKShapeNode!
//    var fillBar: SKSpriteNode!
//    var fishInBar: SKSpriteNode!
//
//    var progressValue: CGFloat = 0
//    var isMiniGameActive = false
//    var lastTouchLocation: CGPoint?
    
    
    override func didMove(to view: SKView) {
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupRiver()
        setupBear()
        setupPowerBar()
        spawnFishes()
        
        setupHookSystem()
        setupFishingLineSystem()
        
        // lydia (untuk catchbar)
        //        setupProgressBar()
        
        
        scaleMode = .resizeFill
        
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
        
        bear.position = CGPoint(x: -250, y: 50)
        bear.zPosition = 1
        
        bear.size = CGSize(width: 250, height: 250)
        
        addChild(bear)
        
        print("✅ Bear is there")
    }
    
    func playCastAnimation(withPower power: CGFloat, completion: @escaping () -> Void) {
        // Hitung jarak berdasarkan power
        let distance = power * 2  // skala lempar
        
        // Buat umpan kotak merah sebagai placeholder
        let baitSize = CGSize(width: 20, height: 20)
        let bait = SKShapeNode(rectOf: baitSize, cornerRadius: 4)
        bait.fillColor = .red
        bait.strokeColor = .clear
        bait.zPosition = 2
        bait.name = "bait"
        
        bait.position = CGPoint(x: -150, y: 0)
        addChild(bait)
        
        // Hitung target posisi lempar
        let target = bait.position.x + distance
        bait.position = CGPoint(x: target, y: bait.position.y)
    }
    
    func setupPowerBar() {
        let barWidth: CGFloat = 150
        let barHeight: CGFloat = 15
        
        // Background (abu-abu)
        powerBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 10)
        powerBarBackground.fillColor = .gray
        powerBarBackground.strokeColor = .clear
        powerBarBackground.zPosition = 100
        powerBarBackground.alpha = 0.7
        
        // Posisi kiri bawah layar
        powerBarBackground.position = CGPoint(x: -200, y: 50)
        
        // Fill (merah)
        let fillRect = CGRect(x: -barWidth / 2, y: -barHeight / 2, width: 0, height: barHeight)
        powerBarFill = SKShapeNode(rect: fillRect, cornerRadius: 10)
        powerBarFill.fillColor = .blue
        powerBarFill.strokeColor = .clear
        powerBarFill.zPosition = 101
        
        powerBarBackground.addChild(powerBarFill)
        addChild(powerBarBackground)
        
        powerBarBackground.isHidden = true
    }
    
    func showPowerBar() {
        powerBarBackground.isHidden = false
        updatePowerBar()
    }
    
    //lydia(untuk catchbar)
//    func setupProgressBar() {
//        progressBarContainer = SKSpriteNode(color: .gray, size: CGSize(width: 100, height: 150))
//        progressBarContainer.position = CGPoint(x: 200, y: 0)
//        progressBarContainer.zPosition = 10
//        addChild(progressBarContainer)
//
//        fillBar = SKSpriteNode(color: .yellow, size: CGSize(width: 12, height: 1))
//        fillBar.anchorPoint = CGPoint(x: 0.5, y: 0)
//        fillBar.position = CGPoint(x: -30, y: -75)
//        progressBarContainer.addChild(fillBar)
//
//        greenBar = SKShapeNode(rectOf: CGSize(width: 30, height: 50))
//        greenBar.fillColor = .green
//        greenBar.position = CGPoint(x: -30, y: 0)
//        progressBarContainer.addChild(greenBar)
//
//        fishInBar = SKSpriteNode(imageNamed: "shadowfish1")
//        fishInBar.setScale(0.2)
//        fishInBar.position = CGPoint(x: -30, y: 0)
//        progressBarContainer.addChild(fishInBar)
//    }
    
    func hidePowerBar() {
        powerBarBackground.isHidden = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime
        
        stateMachine.update(deltaTime: delta)
        fishingLineSystem.updateLine()
        
    // lydia(untuk catchbar)
//        if isMiniGameActive {
//            progressValue += 0.01
//            progressValue = min(progressValue, 1.0)
//            fillBar.size.height = 1 + (150 * progressValue)
//            // Tambahkan ke dalam if isMiniGameActive di update
//            let barHeight: CGFloat = 150
//            let greenHeight: CGFloat = 50
//            let progressCenterY = progressBarContainer.position.y
//
//            let minY = progressCenterY - (barHeight * 0.29) + (greenHeight / 2)
//            let maxY = progressCenterY + (barHeight / 2) - (greenHeight / 2) + 12
//
//            let fishCenterY = (minY + maxY) / 2
//            let fishAmplitude: CGFloat = 35
//            fishInBar.position.y = fishCenterY + sin(currentTime * 2) * fishAmplitude
//
//            // Clamp posisi greenBar agar tetap di dalam batas
//            greenBar.position.y = min(max(greenBar.position.y, minY), maxY)
//
//            // Tambahkan deteksi apakah ikan dalam kotak hijau
//            if greenBar.frame.contains(fishInBar.position) {
//                progressValue += 0.01
//            } else {
//                progressValue -= 0.01
//            }
//            progressValue = min(max(progressValue, 0), 1)
//        }
    }
    
    func updatePowerBar() {
        guard let barFill = powerBarFill else { return }
        
        let maxWidth: CGFloat = 150
        let powerRatio = min(castPower / maxCastPower, 1.0)
        let newWidth = maxWidth * powerRatio
        
        let fillRect = CGRect(x: -maxWidth / 2, y: -10, width: newWidth, height: 20)
        barFill.path = CGPath(roundedRect: fillRect, cornerWidth: 10, cornerHeight: 10, transform: nil)
    }
        
    func setupHookSystem() {
        hookSystem = HookSystem(scene: self)
        hookSystem.delegate = self
    }
        
    func setupFishingLineSystem() {
        fishingLineSystem = FishingLineSystem(scene: self)
        fishingLineSystem.delegate = self
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
        let previousState = stateMachine.currentState
        stateMachine.enter(CastingState.self)
        showPowerBar()
        
        if let newState = stateMachine.currentState {
            fishingLineSystem.handleStateTransition(from: previousState, to: newState)
        }
        // lydia
//        if !isMiniGameActive {
//            isMiniGameActive = true
//            progressValue = 0
//        }
//        lastTouchLocation = touches.first?.location(in: self)
    }
    
//    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
//        guard isMiniGameActive,
//              let touch = touches.first,
//              let lastLocation = lastTouchLocation else { return }
//
//        let currentLocation = touch.location(in: self)
//        let deltaY = currentLocation.y - lastLocation.y
//
//        greenBar.position.y += deltaY
//        lastTouchLocation = currentLocation
//
//        let barHeight: CGFloat = 150
//        let greenHeight: CGFloat = 50
//        let centerY = progressBarContainer.position.y
//
//        let minY = centerY - (barHeight * 0.29) + (greenHeight / 2)
//        let maxY = centerY + (barHeight / 2) + 20
//
//        greenBar.position.y = min(max(greenBar.position.y, minY), maxY)
//    }
        
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let bear = self.childNode(withName: "bearNode") as? SKSpriteNode {
            bear.texture = SKTexture(imageNamed: "bear-waiting-test")
        }
        
        hidePowerBar()
        
        if stateMachine.currentState is CastingState {
            stateMachine.enter(WaitingForHookState.self)
        }
        
//        lastTouchLocation = nil
    }
}

extension FishingScene: HookSystemDelegate {
    func hookSystem(_ hookSystem: HookSystem) {
        // Handle fish caught event
        print("🎣 Fish caught at position: \(position)")
        
        if stateMachine.currentState is WaitingForHookState {
            stateMachine.enter(ReelingState.self)
        }
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

extension FishingScene: FishingLineSystemDelegate {
    
    func getRodPosition() -> CGPoint {
        guard let state = getCurrentGameState() else {
            fatalError("Current state is nil")
        }
        
        switch state {
        case is WaitingForHookState:
            return CGPoint(x: bear.position.x + 77, y: bear.position.y - 20) // For WaitingForHookState
        case is ReelingState:
            return CGPoint(x: bear.position.x - 57, y: bear.position.y + 41) // For CastingState (different position)
        default:
            return CGPoint(x: bear.position.x - 77, y: bear.position.y - 40) // Ensure all cases are handled
        }
    }
    
    func getCurrentBaitPosition() -> CGPoint {
        return hookSystem.getBaitPosition()
    }
    
    func getCurrentGameState() -> GKState? {
        return stateMachine.currentState
    }
    
    func getBaitDistance() -> CGFloat {
        // Calculate distance based on your near-far system
        // This is just an example - replace with your actual distance calculation
        let rodTip = getRodPosition()
        let bait = getCurrentBaitPosition()
        
        let distance = sqrt(pow(bait.x - rodTip.x, 2) + pow(bait.y - rodTip.y, 2))
        let maxDistance: Float = 300.0 // Adjust based on your game's max cast distance
        
        return CGFloat(min(Float(distance) / maxDistance, 1.0)) // Normalize to 0.0-1.0
    }
    
}

