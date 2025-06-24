//
//  StartScene.swift
//  Nais-Fishing
//
//  Created by Nadaa Shafa Nadhifa on 24/06/25.
//

import SpriteKit

class StartScene: SKScene {
    
    var title: SKSpriteNode!
    var background: SKSpriteNode!
    var button1P: SKSpriteNode!
    var button2P: SKSpriteNode!
    
    override func didMove(to view: SKView) {
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupTitle()
        setupBackground()
        setup1PButton()
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

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let nodes = self.nodes(at: location)
        
        for node in nodes {
            if node.name == "1P" {
                handleButtonPressed(button: button1P)
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
        
        if button.name == "1P" {
            let gameScene = FishingScene(size: self.size)
            let transition = SKTransition.fade(withDuration: 1)
            self.view?.presentScene(gameScene, transition: transition)
        }
    }
}
