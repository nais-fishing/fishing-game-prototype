//
//  FishingHapticEngine.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 19/06/25.
//

import CoreHaptics

class HapticManager {
    let hapticEngine: CHHapticEngine
    
    init?() {
        let hapticCapability = CHHapticEngine.capabilitiesForHardware()
        
        guard hapticCapability.supportsHaptics else {
            return nil
        }
        
        do {
            hapticEngine = try CHHapticEngine()
        } catch let error {
            print("Failed to create haptic engine: \(error)")
            return nil
        }
    }
    
    func playPop() {
        do {
            let pattern = try popPattern()
            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticEngine.notifyWhenPlayersFinished { _ in
                return .stopEngine
            }
        } catch {
            print("Error playing haptic pattern: \(error)")
        }
    }
}

extension HapticManager {
    private func popPattern() throws -> CHHapticPattern {
        let pop = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0.08)
        
        return try CHHapticPattern(events: [pop], parameters: [])
    }
}
