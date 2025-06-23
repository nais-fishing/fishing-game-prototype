//
//  FishingLineSystem.swift
//  Nais-Fishing
//
//  Created by Nadaa Shafa Nadhifa on 23/06/25.
//

import SpriteKit
import GameplayKit

protocol FishingLineSystemDelegate: AnyObject {
    func getRodPosition() -> CGPoint
    func getCurrentBaitPosition() -> CGPoint
    func getCurrentGameState() -> GKState?
    func getBaitDistance() -> CGFloat // for the near-far thing
}

class FishingLineSystem {
    
    weak var scene: SKScene?
    weak var delegate: FishingLineSystemDelegate?
    
    private var fishingLine: SKShapeNode!
    private var isLineVisible: Bool = false
    
    private struct lineProperties {
        let color: UIColor
        let width: CGFloat
        let pattern: [CGFloat]? // For dashed lines
        let alpha: CGFloat
        let tension: CGFloat // For curved lines
        let isStraight: Bool
    }
    
    init(scene: SKScene) {
        self.scene = scene
        setupFishingLine()
    }
    
    private func setupFishingLine() {
        fishingLine = SKShapeNode()
        //fishingLine = SKSpriteNode(color: .white, size: CGSize(width: 2, height: 2))
        fishingLine.zPosition = 2
        fishingLine.alpha = 0
        
        if let line = fishingLine {
            scene?.addChild(line)
        }
    }
    
    func updateLine() {
        guard let delegate = delegate,
              let currentState = delegate.getCurrentGameState() else {
            hideLine()
            return
        }
        
        let rodTipPosition = delegate.getRodPosition()
        let baitPosition = delegate.getCurrentBaitPosition()
        let baitDistance = delegate.getBaitDistance()
        
        let lineProperties = getLineProperties(for: currentState, baitDistance: baitDistance)
        
        if shouldShowLine(for: currentState) {
            showLine(from: rodTipPosition, to: baitPosition, with: lineProperties, distance: baitDistance)
        } else {
            hideLine()
        }
    }
    
    func forceUpdateLine() {
        updateLine()
    }
    
    private func shouldShowLine(for state: GKState) -> Bool {
        switch state {
            
        case is IdleState:
            return false
        case is CastingState:
            return true
        case is WaitingForHookState:
            return true
//        case is ReelingState:
//            return true
        default :
        return false
            
        }
    }
    
    private func getLineProperties(for state: GKState, baitDistance: CGFloat) -> lineProperties {
        
        var baseProperties: lineProperties
        
        switch state {
        case is CastingState:
            baseProperties = lineProperties(
                color: .white,
                width: 2,
                pattern: nil,
                alpha: 1,
                tension: 0,
                isStraight: false
            )
        case is WaitingForHookState:
            baseProperties = lineProperties(
                color: .white,
                width: 2,
                pattern: nil,
                alpha: 1,
                tension: 0.1,
                isStraight: true
            )
//        case is ReelingState:
        default:
            baseProperties = lineProperties(
                color: .white,
                width: 2,
                pattern: nil,
                alpha: 1,
                tension: 0,
                isStraight: false
            )
        }
        
        
        return modifyPropertyForDistance(baseProperties, distance: baitDistance)
            
    }
    
    private func modifyPropertyForDistance(_ properties: lineProperties, distance: CGFloat) -> lineProperties {
        
        let distanceMultiplier = CGFloat(distance)
        
        return lineProperties(
            color: properties.color,
            width: properties.width + (distanceMultiplier * 0.5), // Thicker line for far casts
            pattern: properties.pattern,
            alpha: max(0.3, properties.alpha - (distanceMultiplier * 0.2)), // Slightly more transparent for far
            tension: properties.tension + (distanceMultiplier * 0.3),
            isStraight: properties.isStraight // More sag for longer lines
        )
    }
    
    private func showLine(from startPoint: CGPoint, to endPoint: CGPoint, with properties: lineProperties, distance: CGFloat) {
        guard let fishingLine = fishingLine else { return }
        
        let path = createLinePath(from: startPoint, to: endPoint, tension: properties.tension, distance: distance, isStraight: properties.isStraight)
        
        fishingLine.path = path
        fishingLine.strokeColor = properties.color
        fishingLine.lineWidth = properties.width
        fishingLine.alpha = properties.alpha
        
        // Apply dash pattern if specified
        if let pattern = properties.pattern {
            fishingLine.path = path.copy(dashingWithPhase: 0, lengths: pattern)
        }
        
        // Animate line appearance if it wasn't visible
        if !isLineVisible {
            isLineVisible = true
            let fadeIn = SKAction.fadeIn(withDuration: 0.3)
            fishingLine.run(fadeIn)
        }
    }
    
    private func hideLine() {
        guard let fishingLine = fishingLine, isLineVisible else { return }
        isLineVisible = false
        let fadeOut = SKAction.fadeOut(withDuration: 0.2)
        fishingLine.run(fadeOut)
    }
    
    private func createLinePath(from startPoint: CGPoint, to endPoint: CGPoint, tension: CGFloat, distance: CGFloat, isStraight: Bool) -> CGPath {
            
        let path = CGMutablePath()
        let baitTopPosition = CGPoint(x: endPoint.x + 4, y: endPoint.y + 13)
        
        if isStraight == false {
            
            path.move(to: startPoint)
            path.addLine(to: baitTopPosition)
            
        } else {
            
            let distanceMultiplier = CGFloat(distance)
            let lineLength = sqrt(pow(endPoint.x - startPoint.x, 2) + pow(endPoint.y - startPoint.y, 2))
            
            // More realistic sag calculation based on line length and distance
            let sagAmount = lineLength * tension * (1 + distanceMultiplier * 0.5)
            
            let midPoint = CGPoint(
                x: (startPoint.x + endPoint.x) / 2,
                y: (startPoint.y + endPoint.y) / 2 - sagAmount
                )
            
            path.move(to: startPoint)
            path.addQuadCurve(to: baitTopPosition, control: midPoint)
        }
        
        return path
        
    }
    
    func animateLineCasting(from startPoint: CGPoint, to endPoint: CGPoint, duration: TimeInterval, completion: @escaping () -> Void) {
        guard let fishingLine = fishingLine else { return }
        
        // Start with line at bear position
        var currentPath = createLinePath(from: startPoint, to: startPoint, tension: 0, distance: 0, isStraight: true)
        fishingLine.path = currentPath
        fishingLine.alpha = 1.0
        isLineVisible = true
        
        // Animate line extending to bait position
        let steps = 20
        let stepDuration = duration / Double(steps)
        
        var currentStep = 0
        let timer = Timer.scheduledTimer(withTimeInterval: stepDuration, repeats: true) { timer in
            currentStep += 1
            let progress = CGFloat(currentStep) / CGFloat(steps)
            
            let intermediatePoint = CGPoint(
                x: startPoint.x + (endPoint.x - startPoint.x) * progress,
                y: startPoint.y + (endPoint.y - startPoint.y) * progress
            )
            
            currentPath = self.createLinePath(from: startPoint, to: intermediatePoint, tension: 0.2 * progress, distance: 0, isStraight: true)
            fishingLine.path = currentPath
            
            if currentStep >= steps {
                timer.invalidate()
                completion()
            }
        }
    }
}

extension FishingLineSystem {
    
    func handleStateTransition(from previousState: GKState?, to newState: GKState) {
        // Special animations for state transitions
        guard let delegate = delegate else { return }
        
        let rodTipPosition = delegate.getRodPosition()
        let baitPosition = delegate.getCurrentBaitPosition()
        
        switch newState {
        case is CastingState:
            print("casting. . .")
            // Animate line casting
            animateLineCasting(from: rodTipPosition, to: baitPosition, duration: 1.0) {
                 //Casting animation complete
            }
            
//        case is ReeelingState:
//            // Change line color immediately to indicate reeling
//            updateLine()
            
        case is IdleState:
            // Fade out line
            hideLine()
            
        default:
            // Default update
            updateLine()
        }
    }
}
