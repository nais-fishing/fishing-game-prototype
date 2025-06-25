//
//  StartScene.swift
//  Nais-Fishing
//
//  Created by Nadaa Shafa Nadhifa on 24/06/25.
//

import SpriteKit
import MultipeerConnectivity

class StartScene: SKScene, MultiplayerManagerDelegate {
    
    var title: SKSpriteNode!
    var background: SKSpriteNode!
    var button1P: SKSpriteNode!
    var button2P: SKSpriteNode!
    
    var multiplayerManager: MultiplayerManager?

    
    override func didMove(to view: SKView) {
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupTitle()
        setupBackground()
        setup1PButton()
        setup2PButton()
    }
    
    func setupTitle () {
        title = SKSpriteNode(imageNamed: "title")
        title.position = CGPoint(x: 0, y: 75)
        title.zPosition = 10
        
        title.size = CGSize(width: self.size.width / 1.25 , height: self.size.height / 1.25)
        
        
        addChild(title)
        
        let bobUp = SKAction.moveBy(x: 0, y: 7, duration: 1.0)
        let bobDown = SKAction.moveBy(x: 0, y: -7, duration: 1.0)
        let bobSequence = SKAction.sequence([bobUp, bobDown])
        let bobForever = SKAction.repeatForever(bobSequence)
        title.run(bobForever, withKey: "title")
    }
    
    func setupBackground() {
        let background = SKSpriteNode(imageNamed: "start-background")
        background.position = .zero
        background.zPosition = 0
        
        background.size = self.size
        
        addChild(background)
    }
    
    func setup1PButton() {
        button1P = SKSpriteNode(imageNamed: "start-button")
        button1P.name = "1P"
        
        button1P.zPosition = 5
        button1P.position = CGPoint(x: 0, y: -50)
        button1P.size = CGSize(width: 210, height: 140)
        
        addChild(button1P)
    }
    
    func setup2PButton() {
        button2P = SKSpriteNode(imageNamed: "start-button")
        button2P.name = "2P"
        
        button2P.zPosition = 5
        button2P.position = CGPoint(x: 0, y: -120) // di bawah 1P
        button2P.size = CGSize(width: 210, height: 140)
        
        let label = SKLabelNode(text: "Multiplayer")
        label.fontName = "AvenirNext-Bold"
        label.fontSize = 18
        label.fontColor = .white
        label.verticalAlignmentMode = .center
        label.zPosition = 6
        button2P.addChild(label)
        
        addChild(button2P)
    }
    
    func handleMultiplayerStart() {
        multiplayerManager = MultiplayerManager()
        multiplayerManager?.delegate = self
        
        // Kamu bisa ganti logika ini dengan tombol pilihan atau randomizer
        let isHost = Bool.random()
        
        if isHost {
            multiplayerManager?.startHosting()
            print("🎮 Menjadi HOST")
            
            // Simulasikan tunggu 3 detik, lalu kirim gameStart
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                let message = GameMessage(type: "gameStart", value: nil)
                if let data = try? JSONEncoder().encode(message) {
                    self.multiplayerManager?.sendData(data)
                }
                self.presentMultiplayerGameScene()
            }
            
        } else {
            multiplayerManager?.startBrowsing()
            print("🎮 Menjadi CLIENT")
        }
    }
    
    func presentMultiplayerGameScene() {
        let scene = FishingScene(size: self.size)
        scene.isMultiplayerMode = true
        scene.multiplayerManager = self.multiplayerManager
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1))
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
                if node.name == "1P" {
                    handleButtonPressed(button: button1P)
                } else if node.name == "2P" {
                    handleButtonPressed(button: button2P)
                }
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
                if node.name == "1P" {
                    handleButtonReleased(button: button1P)
                } else if node.name == "2P" {
                    handleButtonReleased(button: button2P)
                }
        }
    }
    
    func handleButtonPressed(button: SKSpriteNode) {
        let scaleDown = SKAction.scale(to: 0.975, duration: 0.1)
        button.run(scaleDown)
    }
    
    func handleButtonReleased(button: SKSpriteNode) {
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        button.run(scaleUp)
        
        let transition = SKTransition.fade(withDuration: 1)
        
        if button.name == "1P" {
            let gameScene = FishingScene(size: self.size)
            self.view?.presentScene(gameScene, transition: transition)
            
        } else if button.name == "2P" {
            handleMultiplayerStart()
        }

    }
}

// MARK: - MultiplayerManagerDelegate
extension StartScene {
    func playerScoreUpdated(peerID: MCPeerID, newScore: Int) {
        // Kamu bisa abaikan ini kalau belum butuh di StartScene
    }

    func gameDidStart() {
        print("🎮 Received gameDidStart, launching multiplayer game...")
        let scene = FishingScene(size: self.size)
        scene.isMultiplayerMode = true
        scene.multiplayerManager = self.multiplayerManager
        self.view?.presentScene(scene, transition: SKTransition.fade(withDuration: 1))
    }
}

