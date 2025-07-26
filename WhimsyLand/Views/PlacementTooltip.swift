//
//  PlacementToolTip.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/15/25.
//

import SwiftUI

struct PlacementTooltip: View {
    var placementState: PlacementState

    var body: some View {
        if let message {
            TooltipView(text: message)
        }
    }

    var message: String? {
        // Decide on a message to display, in order of importance.
        if !placementState.planeToProjectOnFound {
            return "가까운 바닥을 향해 기기를 움직여보세요"
        }
        if placementState.collisionDetected {
            return "공간이 비어있지 않아요!"
        }
        if !placementState.userPlacedAnObject {
            return "탭하여 배치하세요"
        }
        return nil
    }
}

#Preview(windowStyle: .plain) {
    VStack {
        PlacementTooltip(placementState: PlacementState())
        PlacementTooltip(placementState: PlacementState().withPlaneFound())
        PlacementTooltip(placementState:
            PlacementState()
                .withPlaneFound()
                .withCollisionDetected()
        )
    }
}

private extension PlacementState {
    func withPlaneFound() -> PlacementState {
        planeToProjectOnFound = true
        return self
    }

    func withCollisionDetected() -> PlacementState {
        activeCollisions = 1
        return self
    }
}
