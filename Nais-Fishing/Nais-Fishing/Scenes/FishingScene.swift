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
    var powerBarBackground: SKShapeNode!
    var powerBarFill: SKShapeNode!
    var lastUpdateTime: TimeInterval = 0
    var castPower: CGFloat = 0.0
    var maxCastPower: CGFloat = 100.0
    var isCharging: Bool = false
    var stateMachine: FishingGameStateMachine!
    
    override func didMove(to view: SKView) {
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupRiver()
        setupBear()
        setupPowerBar()
        
        scaleMode = .resizeFill
        
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
        bear.position = CGPoint(x: -220, y: 0)
        bear.zPosition = 1
        
        bear.size = CGSize(width: 150, height: 150)
        
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

    func hidePowerBar() {
        powerBarBackground.isHidden = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        stateMachine.update(deltaTime: delta)
    }

    func updatePowerBar() {
        guard let barFill = powerBarFill else { return }

        let maxWidth: CGFloat = 150
        let powerRatio = min(castPower / maxCastPower, 1.0)
        let newWidth = maxWidth * powerRatio

        let fillRect = CGRect(x: -maxWidth / 2, y: -10, width: newWidth, height: 20)
        barFill.path = CGPath(roundedRect: fillRect, cornerWidth: 10, cornerHeight: 10, transform: nil)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let bear = self.childNode(withName: "bearNode") as? SKSpriteNode {
                bear.texture = SKTexture(imageNamed: "bear-casting-test")
            }
        
        stateMachine.enter(CastingState.self)
        showPowerBar()
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let bear = self.childNode(withName: "bearNode") as? SKSpriteNode {
                bear.texture = SKTexture(imageNamed: "bear-waiting-test")
            }
        
        hidePowerBar()
        
        if stateMachine.currentState is CastingState {
            stateMachine.enter(WaitingForHookState.self)
        }
    }

}

