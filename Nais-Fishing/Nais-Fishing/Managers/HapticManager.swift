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
    
    // Light haptic for touch interactions
    func playTouch() {
        do {
            let pattern = try touchPattern()
            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticEngine.notifyWhenPlayersFinished { _ in
                return .stopEngine
            }
        } catch {
            print("Error playing touch haptic pattern: \(error)")
        }
    }
    
    // More intense haptic for big catches or achievements
    func playBigCatch() {
        do {
            let pattern = try bigCatchPattern()
            try hapticEngine.start()
            let player = try hapticEngine.makePlayer(with: pattern)
            try player.start(atTime: CHHapticTimeImmediate)
            hapticEngine.notifyWhenPlayersFinished { _ in
                return .stopEngine
            }
        } catch {
            print("Error playing big catch haptic pattern: \(error)")
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
    
    // Gentle haptic for touch feedback
    private func touchPattern() throws -> CHHapticPattern {
        let touch = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.6),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.7)
            ],
            relativeTime: 0)
        
        return try CHHapticPattern(events: [touch], parameters: [])
    }
    
    // Intense haptic pattern with multiple pulses
    private func bigCatchPattern() throws -> CHHapticPattern {
        var events: [CHHapticEvent] = []
        
        // First strong pulse
        let firstPulse = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0)
        events.append(firstPulse)
        
        // Continuous rumble
        let rumble = CHHapticEvent(
            eventType: .hapticContinuous,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 0.8),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.5)
            ],
            relativeTime: 0.1,
            duration: 0.3)
        events.append(rumble)
        
        // Second strong pulse
        let secondPulse = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 0.8)
            ],
            relativeTime: 0.5)
        events.append(secondPulse)
        
        // Final strong pulse
        let finalPulse = CHHapticEvent(
            eventType: .hapticTransient,
            parameters: [
                CHHapticEventParameter(parameterID: .hapticIntensity, value: 1.0),
                CHHapticEventParameter(parameterID: .hapticSharpness, value: 1.0)
            ],
            relativeTime: 0.7)
        events.append(finalPulse)
        
        return try CHHapticPattern(events: events, parameters: [])
    }
}
