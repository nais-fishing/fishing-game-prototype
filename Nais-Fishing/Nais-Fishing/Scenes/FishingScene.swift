//
//  FishingScene.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 18/06/25.
//
import SpriteKit
import GameplayKit
import MultipeerConnectivity

class FishingScene: SKScene, SKPhysicsContactDelegate {
    
    private var hapticManager: HapticManager?
    
    var river: SKSpriteNode!
    var bear: SKSpriteNode!
    var ember1: SKSpriteNode!
    var powerBarBackground: SKShapeNode!
    var powerBarFill: SKShapeNode!
    var fishingButton: SKSpriteNode!
    var castBar: SKSpriteNode!
    
    //var buat cast bar
    var lastUpdateTime: TimeInterval = 0
    var castPower: CGFloat = 0.0
    var maxCastPower: CGFloat = 100.0
    var isCharging: Bool = false
  
    var stateMachine: FishingGameStateMachine!
    var fish: SKSpriteNode!
    var bait: SKSpriteNode!
    var caughtSign: SKLabelNode!
    
    //var buat reeling
    var progressBarContainer: SKSpriteNode!
    var greenBar: SKShapeNode!
    var fishInBar: SKSpriteNode!
    var fillBar: SKSpriteNode!
    var progressValue: CGFloat = 0
    var scoreLabel: SKLabelNode!
    var score: Int = 0
    var isPressingButton = false
    var miniGameStartTime: TimeInterval = 0
    var isMiniGameActive = false
    var lastTouchLocation: CGPoint?
    
    //random ikan
    let fishNames = ["beta", "catfish", "jellyfish", "bone", "nemo"]
    
    //var stateMachine: FishingGameStateMachine!
    var castingManager: CastingManager!
    var hookSystem: HookSystem!
    var fishingLineSystem: FishingLineSystem!
    
    var isFishCaught: Bool = false
    
    //buat game over
    var gameDuration: TimeInterval = 60.0 // total durasi game dalam detik
    var gameStartTime: TimeInterval = 0
    var isGameOver = false
    
    var buttonRestart: SKSpriteNode!
    var popupGameOver: SKSpriteNode!
    var gameOverText: SKSpriteNode!
    var scoreText: SKLabelNode!

    //countdown
    var countdownLabel: SKLabelNode!
    var gameTimer: Timer?
    var timeLeft: Int = 60 // total durasi countdown
    
    var timeAndScore: SKSpriteNode!
    var playerName: SKLabelNode!
    
    //multiplayer
    var multiplayerManager: MultiplayerManager!
    var isMultiplayerMode: Bool = false
    var opponentScore: Int = 0
    var opponentScoreLabel: SKLabelNode!
    var playerScores: [String: Int] = [:]
    
    override func didMove(to view: SKView) {
        
        hapticManager = HapticManager()
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        setupRiver()
        setupBear()
        setupPowerBar()
        setupFishingButton()
        spawnFishes()
        
        setupHookSystem()
        setupFishingLineSystem()
        
        setupScoreLabel()
        setupBox()
        
        setupCountdownLabel()
        startCountdownTimer()
        
        scaleMode = .resizeFill
        
        stateMachine = FishingGameStateMachine(scene: self)
        
        physicsWorld.contactDelegate = self
        
        gameStartTime = CACurrentMediaTime()
        
        if isMultiplayerMode {
            setupScoreOpponent()
        }
        
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
        bear = SKSpriteNode(imageNamed: "bear-idle")
        bear.name = "bearNode" // penting! agar FSM bisa akses dengan childNode(withName:)

        bear.position = CGPoint(x: -250, y: 50)
        bear.zPosition = 1
        
        bear.size = CGSize(width: 250, height: 250)
        
        addChild(bear)
        
        print("✅ Bear is there")
        
        ember1 = SKSpriteNode(imageNamed: "ember1")
        ember1.size = CGSize(width: 100, height: 100)
        ember1.position = CGPoint(x: -325, y: -110)
        ember1.zPosition = 2
        addChild(ember1)
    }
    
    func setupBox() {
        timeAndScore = SKSpriteNode(imageNamed: "box")
        timeAndScore.position = CGPoint(x: -260, y: 145)
        //timeAndScore.position = .zero
        timeAndScore.zPosition = 10

        // Gunakan ukuran scene yang sudah aktif
        timeAndScore.size = CGSize(width: size.width / 2, height: size.height / 2)
        
        addChild(timeAndScore)
    }
    
    func playCastAnimation(withPower power: CGFloat, completion: @escaping () -> Void) {
        
        // Hitung jarak berdasarkan power
        let distance = power * 2  // skala lempar
        
        // Set initial casting position (at bear's fishing rod tip)
        let startPosition = CGPoint(x: bear.position.x + 50, y: bear.position.y)
        
        // Calculate target position for casting
        let targetX = startPosition.x + distance
        let targetY = startPosition.y - 130 // Cast into water
        let targetPosition = CGPoint(x: targetX, y: targetY)
        
        hookSystem.moveBait(to: targetPosition)
        
    }
    
    func setupPowerBar() {
        let barWidth: CGFloat = 150
        let barHeight: CGFloat = 15
        
        castBar = SKSpriteNode(imageNamed: "cast-bar")
        castBar.name = "castBar"
        castBar.position = CGPoint(x: -250, y: 90)
        castBar.zPosition = 102
        castBar.size = CGSize(width: barWidth + 150, height: 160)
        addChild(castBar)
        castBar.isHidden = true
                
        // Background (abu-abu)
        powerBarBackground = SKShapeNode(rectOf: CGSize(width: barWidth, height: barHeight), cornerRadius: 0)
        powerBarBackground.fillColor = UIColor.lightBlue
        powerBarBackground.strokeColor = .clear
        powerBarBackground.zPosition = 100
        powerBarBackground.alpha = 1

        // Posisi kiri bawah layar
        powerBarBackground.position = CGPoint(x: -250, y: 90)

        // Fill (merah)
        let fillRect = CGRect(x: -barWidth / 2, y: -barHeight / 2, width: 0, height: barHeight)
        powerBarFill = SKShapeNode(rect: fillRect, cornerRadius: 0)
        powerBarFill.fillColor = UIColor.lightYellow
        powerBarFill.strokeColor = .clear
        powerBarFill.zPosition = 101

        powerBarBackground.addChild(powerBarFill)
        addChild(powerBarBackground)

        powerBarBackground.isHidden = true
    }

    func showPowerBar() {
        powerBarBackground.isHidden = false
        castBar.isHidden = false
        updatePowerBar()
    }

    func hidePowerBar() {
        powerBarBackground.isHidden = true
        castBar.isHidden = true
    }
    
    func startMiniGame() {
        let barWidth: CGFloat = 20
        
        // Bar putih (container)
        progressBarContainer = SKSpriteNode(imageNamed: "catchbar")
        progressBarContainer.size = CGSize(width: 350, height: 350)
        progressBarContainer.position = CGPoint(x: fishingButton.position.x - 3, y: fishingButton.position.y + 150)
        progressBarContainer.zPosition = 1000
        addChild(progressBarContainer)
        
        // Isi progress (kuning kecil di samping kanan)
        fillBar = SKSpriteNode(color: .yellow, size: CGSize(width: 4, height: 20))
        fillBar.anchorPoint = CGPoint(x: 0.5, y: 0)
        fillBar.position = CGPoint(x: 14, y: progressBarContainer.position.y - 95) // hanya baris ini!
        fillBar.zPosition = 1001
        progressBarContainer.addChild(fillBar)
        
        // Kotak hijau (deteksi area)
        greenBar = SKShapeNode(rectOf: CGSize(width: barWidth, height: 30), cornerRadius: 2)
        greenBar.fillColor = .green
        greenBar.alpha = 0.4
        greenBar.zPosition = 1002
        greenBar.position = CGPoint(
            x: progressBarContainer.position.x - 5,
            y: progressBarContainer.position.y - 10
        )
        addChild(greenBar)
        
        // Ikan kecil
        fishInBar = SKSpriteNode(imageNamed: "shadowfish")
        fishInBar.setScale(0.08)
        fishInBar.position = CGPoint(x: greenBar.position.x, y: progressBarContainer.position.y)
        fishInBar.zPosition = 1003
        addChild(fishInBar)
        
        progressValue = 0
        isMiniGameActive = true
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        //ini buat game over
        let elapsedTime = currentTime - gameStartTime
        if elapsedTime >= gameDuration && !isGameOver {
            isGameOver = true
            handleGameOver()
            return
        }
        
        let delta = currentTime - lastUpdateTime
        lastUpdateTime = currentTime

        stateMachine.update(deltaTime: delta)
        fishingLineSystem.updateLine()

        // Cek apakah sedang di ReelingState
        guard stateMachine.currentState is ReelingState else { return }
        
        guard isMiniGameActive else { return }

        // Jika belum ada komponen mini-game, keluar
        guard let fillBar = fillBar, let greenBar = greenBar, let fishInBar = fishInBar else { return }

        // MINI-GAME LOGIC
        let barHeight: CGFloat = 150
        let greenHeight: CGFloat = 40
        let progressCenterY = progressBarContainer.position.y - 10

        let minY = progressCenterY - (barHeight * 0.29) + (greenHeight / 2)
        let maxY = progressCenterY + (barHeight / 2) - (greenHeight / 2) + 12

        // Gerakkan ikan naik-turun
        let fishCenterY = ((minY + maxY) / 2)
        let fishAmplitude: CGFloat = 50
        fishInBar.position.y = fishCenterY + sin(currentTime * 2) * fishAmplitude

        // Batasi greenBar tetap di dalam batas
        greenBar.position.y = min(max(greenBar.position.y, minY), maxY)

        // Deteksi apakah ikan ada dalam greenBar
        if greenBar.frame.contains(fishInBar.position) {
            progressValue += 0.01
        } else {
            progressValue -= 0.01
        }

        progressValue = min(max(progressValue, 0), 1)

        // Update visual fillBar
        fillBar.size.height = 140 * progressValue

        let fillBarTopY = fillBar.convert(CGPoint(x: 0, y: fillBar.size.height), to: self).y
        let greenBarTopY = greenBar.frame.maxY

        if progressValue >= 1 && fillBarTopY >= greenBarTopY {
            print("🎉 Ikan tertangkap dan kotak kuning setara dengan kotak hijau!")

            isMiniGameActive = false

            fishInBar.texture = SKTexture(imageNamed: "shadowfish") //INI HARUSNYA IKAN YANG DILEMPAR

            if let bucket = ember1 {
                let jumpUp = SKAction.move(to: CGPoint(x: bear.position.x + 60, y: bear.position.y + 100), duration: 0.7)
                let dropToBucket = SKAction.move(to: bucket.position, duration: 0.8)
                let shrink = SKAction.scale(to: 0.05, duration: 0.8)
                let fadeOut = SKAction.fadeOut(withDuration: 0.8)
                let group = SKAction.group([dropToBucket, shrink, fadeOut])
                let sequence = SKAction.sequence([
                    jumpUp,
                    group,
                    SKAction.run { [weak self] in
                        self?.showCatchPopup() // Pop-up setelah animasi selesai
                    },
                    SKAction.removeFromParent()
                ])

                fishInBar.run(sequence)
            }

            // Bersihkan mini-game element lain (opsional)
            greenBar.removeFromParent()
            fillBar.removeFromParent()
            progressBarContainer.removeFromParent()
        }

    }
    
    func showCatchPopup() {
        let randomIndex = Int.random(in: 0..<fishNames.count)
        let selectedFish = fishNames[randomIndex]
        
        let popup = SKSpriteNode(imageNamed: "popup")
        popup.size = CGSize(width: 180, height: 150)
        popup.zPosition = 10
        popup.position = CGPoint(x: bear.position.x, y: bear.position.y + 40)
        popup.alpha = 0
        addChild(popup)
        
        let label = SKLabelNode(fontNamed: "Pixellari")
        label.text = "You got \(selectedFish.capitalized)"
        label.fontSize = 14
        label.fontColor = .black
        label.position = CGPoint(x: 0, y: 32)
        label.zPosition = 11
        popup.addChild(label)
        
        let fishImage = SKSpriteNode(imageNamed: selectedFish)
        fishImage.size = CGSize(width: 50, height: 50)
        fishImage.position = CGPoint(x: -30, y: 0)
        fishImage.zPosition = 11
        popup.addChild(fishImage)

        let fadeIn = SKAction.fadeIn(withDuration: 0.3)
        let resetGame = SKAction.run { [weak self] in
            guard let self = self else { return }
            
            self.stateMachine.enter(IdleState.self) // pindah state segera setelah muncul
            self.isFishCaught = false
            self.hookSystem.removeBait()
            self.hidePowerBar()
            
            self.score += 1
                self.scoreLabel.text = "\(self.score)"

            // Ganti ember berdasarkan score
            if self.score == 1 {
                self.ember1.texture = SKTexture(imageNamed: "ember2")
            } else if self.score > 1 {
                self.ember1.texture = SKTexture(imageNamed: "ember3")
            }
        }

        let wait = SKAction.wait(forDuration: 3.0)
        let fadeOut = SKAction.fadeOut(withDuration: 0.5)
        let remove = SKAction.removeFromParent()
        let reset = SKAction.run { [weak self] in
            self?.score += 1
            self?.scoreLabel.text = "\(self?.score ?? 0)"
        }

        let sequence = SKAction.sequence([fadeIn, resetGame, wait, fadeOut, remove, reset])
        popup.run(sequence)
    }
    
    func setupScoreLabel() {
        scoreLabel = SKLabelNode(fontNamed: "Pixellari")
        scoreLabel.fontSize = 22
        scoreLabel.fontColor = .newBlack
        scoreLabel.position = CGPoint(x: -self.size.width / 2 + 275, y: self.size.height / 2 - 57)
        scoreLabel.horizontalAlignmentMode = .right // teks rata kanan
        scoreLabel.zPosition = 100
        scoreLabel.text = "\(score)"
        addChild(scoreLabel)
        
        playerName = SKLabelNode(fontNamed: "Pixellari")
        playerName.fontSize = 19
        playerName.fontColor = .newBlack
        playerName.position = CGPoint(x: -self.size.width / 2 + 174, y: self.size.height / 2 - 56)
        playerName.text = "PLAYER"
        playerName.zPosition = 100
        addChild(playerName)
    }
    
    //ini skor lawan
    func setupScoreOpponent() {
        opponentScoreLabel = SKLabelNode(fontNamed: "AvenirNext-Bold")
        opponentScoreLabel.fontSize = 16
        opponentScoreLabel.fontColor = .cyan
        opponentScoreLabel.position = CGPoint(x: self.size.width / 2 - 100, y: self.size.height / 2 - 50) // bawah score sendiri
        opponentScoreLabel.horizontalAlignmentMode = .right
        opponentScoreLabel.zPosition = 100
        opponentScoreLabel.text = "Opponent: 0"
        addChild(opponentScoreLabel)
    }
    
    func playerScoreUpdated(peerID: MCPeerID, newScore: Int) {
        // Simpan skor pemain lawan berdasarkan ID-nya
        playerScores[peerID.displayName] = newScore
        print("🔁 Skor \(peerID.displayName) diupdate jadi \(newScore)")

        // Update tampilan label lawan
        if isMultiplayerMode {
            updateOpponentScoreLabel()
        }
    }
    
    func updateOpponentScoreLabel() {
        if let (_, score) = playerScores.first {
            opponentScoreLabel.text = "Opponent: \(score)"
        }
    }
    
    //ini buat nampilin timer
    func setupCountdownLabel() {
        countdownLabel = SKLabelNode(fontNamed: "Pixellari")
        countdownLabel.fontSize = 25
        countdownLabel.fontColor = .newBlack
        countdownLabel.position = CGPoint(x: -self.size.width / 2 + 49, y: self.size.height / 2 - 57)
        countdownLabel.horizontalAlignmentMode = .left
        countdownLabel.zPosition = 100
        countdownLabel.text = "00:\(timeLeft)"
        addChild(countdownLabel)
    }
    
    func startCountdownTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }

            self.timeLeft -= 1
            self.countdownLabel.text = "00:\(self.timeLeft)"

            if self.timeLeft <= 0 {
                self.gameTimer?.invalidate()
                self.handleGameOver()
            }
        }
    }


    func updatePowerBar() {
        guard let barFill = powerBarFill else { return }

        let maxWidth: CGFloat = 150
        let powerRatio = min(castPower / maxCastPower, 1.0)
        let newWidth = maxWidth * powerRatio

        let fillRect = CGRect(x: -maxWidth / 2, y: -7.5, width: newWidth, height: 15)
        barFill.path = CGPath(roundedRect: fillRect, cornerWidth: 0, cornerHeight: 0, transform: nil)
    }
        
    func setupHookSystem() {
        hookSystem = HookSystem(scene: self)
        hookSystem.delegate = self
    }
    
    func setupFishingLineSystem() {
        fishingLineSystem = FishingLineSystem(scene: self)
        fishingLineSystem.delegate = self
    }
    
    func setupFishingButton() {
        fishingButton = SKSpriteNode(imageNamed: "button")
        fishingButton.name = "fishingButton"
        
        fishingButton.position = CGPoint(x: (size.width/2) - 75, y: -size.height/2 + 75)
        fishingButton.zPosition = 100
        
        fishingButton.size = CGSize(width: 100, height: 100)
        
        fishingButton.isUserInteractionEnabled = false
        
        addChild(fishingButton)
    }
    
    func setupFish() {
        let fish = SKSpriteNode(color: .white, size: CGSize(width: CGFloat.random(in: 20...30), height: CGFloat.random(in: 35...45))) // randomize besar ikan
        fish.alpha = 0 // agar fishnya transparan
        
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
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)
        
        if isMiniGameActive {
            lastTouchLocation = location
            return
        }

        if touchedNode.name == "fishingButton" {
            handleFishingButtonPressed(button: fishingButton)
        } else if touchedNode.name == "restartButton" {
            handleFishingButtonPressed(button: buttonRestart)
        }
        
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard isMiniGameActive,
              let touch = touches.first,
              let lastLocation = lastTouchLocation else { return }

        let currentLocation = touch.location(in: self)
        let deltaY = currentLocation.y - lastLocation.y
        
        greenBar.position.y += deltaY
        lastTouchLocation = currentLocation

        // Batasi posisi greenBar di dalam area catchbar
        let barHeight: CGFloat = 150
        let greenHeight: CGFloat = 50
        let centerY = progressBarContainer.position.y

        let minY = centerY - (barHeight * 0.29) + (greenHeight / 2)
        let maxY = centerY + (barHeight / 2) + 20

        greenBar.position.y = min(max(greenBar.position.y, minY), maxY)
        
        DispatchQueue.global().async { [weak self] in
            self?.hapticManager?.playTouch()
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        let touchedNode = atPoint(location)

        lastTouchLocation = nil

        if isMiniGameActive {
            // ⬇️ Jangan lakukan apapun saat mini-game aktif
            return
        }

        if touchedNode.name == "fishingButton" {
            handleFishingButtonReleased(button: fishingButton)
        }
        
        if touchedNode.name == "restartButton" {
            let startScene = StartScene(size: self.size)
            let transition = SKTransition.fade(withDuration: 1)
            self.view?.presentScene(startScene, transition: transition)
            
            handleFishingButtonReleased(button: buttonRestart)
        }
    }
    
    func handleGameOver() {
        isMiniGameActive = false
        gameTimer?.invalidate()
        self.removeAllActions()
        
        // Hentikan semua aksi semua node
        for node in self.children {
            node.removeAllActions()
        }

        // Buat popup Game Over
        popupGameOver = SKSpriteNode(color: UIColor.black.withAlphaComponent(0.7), size: CGSize(width: 1920, height: 1080))
        popupGameOver.name = "gameOverPopup"
        popupGameOver.setScale(0.5)
        popupGameOver.zPosition = 9999
        popupGameOver.position = CGPoint(x: 0, y: 0)
        addChild(popupGameOver)

        gameOverText = SKSpriteNode(imageNamed: "game-over")
        gameOverText.name = "gameOverText"
        gameOverText.size = CGSize(width: gameOverText.size.width / 3, height: gameOverText.size.height / 3)
        gameOverText.position = CGPoint(x: 0, y: 100)
        gameOverText.zPosition = 10000
        popupGameOver.addChild(gameOverText)
        
        // Buat tombol hitam
        buttonRestart = SKSpriteNode(imageNamed: "button-menu")
        buttonRestart.name = "restartButton"
        buttonRestart.size = CGSize(width: 420, height: 280)
        buttonRestart.position = CGPoint(x: 0, y: -150)
        buttonRestart.zPosition = 10000
        popupGameOver.addChild(buttonRestart)
    }

}

extension FishingScene: HookSystemDelegate {
    func hookSystem(_ hookSystem: HookSystem) {
        // Handle fish caught event
        print("🎣 Fish caught at position: \(position)")
        
        if stateMachine.currentState is WaitingForHookState {
            stateMachine.enter(ReelingState.self)
            isFishCaught = true
            
            DispatchQueue.global().async { [weak self] in
                self?.hapticManager?.playPop()
            }
            //hapticManager?.playPop()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                self.startMiniGame()
            }
        } // trigger reeling state
        // You can add score updates, sound effects, or other game logic here
        // For example:
        // gameScore += 10
        // playFishCaughtSound()
    }
    
    func hookSystemDidShowSign(_ hookSystem: HookSystem) {
        // Handle exclamation mark shown event
        print("❗ Exclamation mark shown!")

    }

    func handleFishingButtonPressed(button: SKSpriteNode) {
        let previousState = stateMachine.currentState
        
        stateMachine.enter(CastingState.self)
    
        showPowerBar()
        
        if let newState = stateMachine.currentState {
            fishingLineSystem.handleStateTransition(from: previousState, to: newState)
        }
        
        if previousState is WaitingForHookState {
            hookSystem.removeBait()
        }
        
        let scaleDown = SKAction.scale(to: 0.975, duration: 0.1)
        button.run(scaleDown)
        
    }
    
    func handleFishingButtonReleased(button: SKSpriteNode) {
        if let bear = self.childNode(withName: "bearNode") as? SKSpriteNode {
                bear.texture = SKTexture(imageNamed: "bear-waiting")
            }
        
        hidePowerBar()
        
        if stateMachine.currentState is CastingState {
            hookSystem.removeBait()
            hookSystem.setupBait()
            stateMachine.enter(WaitingForHookState.self)
        }
        
        let scaleUp = SKAction.scale(to: 1.0, duration: 0.1)
        button.run(scaleUp)
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
