////
////  ChargingState.swift
////  Nais-Fishing
////
////  Created by Niken Larasati on 20/06/25.
////
//
//import GameplayKit
//
//class ChargingState: GKState {
//    unowned let scene: FishingScene
//
//    init(scene: FishingScene) {
//        self.scene = scene
//    }
//
//    override func didEnter(from previousState: GKState?) {
//        scene.castPower = 0
//        scene.isCharging = true
//        scene.showPowerBar()
//        print("⚡ Charging started")
//    }
//
//    override func update(deltaTime seconds: TimeInterval) {
//        if scene.isCharging {
//            scene.castPower += CGFloat(seconds * 100)  // 100 = speed of charge
//            if scene.castPower > scene.maxCastPower {
//                scene.castPower = scene.maxCastPower
//            }
//            scene.updatePowerBar() // optional visual
//        }
//    }
//
//    override func willExit(to nextState: GKState) {
//        scene.isCharging = false
//        print("🎯 Final cast power: \(scene.castPower)")
//    }
//}
