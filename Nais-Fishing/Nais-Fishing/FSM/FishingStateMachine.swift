//
//  FishingGameStateMachine.swift
//  Nais-Fishing
//
//  Created by Niken Larasati on 18/06/25.
//

import GameplayKit

class FishingGameStateMachine: GKStateMachine {
    init(scene: FishingScene) {
        super.init(states: [
            IdleState(scene: scene),
            CastingState(scene: scene),
            WaitingForHookState(scene: scene)
        ])
        enter(IdleState.self)
    }
}
