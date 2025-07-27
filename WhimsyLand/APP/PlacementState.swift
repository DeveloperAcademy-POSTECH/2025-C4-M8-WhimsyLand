//
//  PlacementState.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/10/25.
//
//  배치 프로세스에서 사용되는 상태 관리

import Foundation
import RealityKit

@Observable
class PlacementState {

    var selectedToy: PlaceableToy? = nil
    var infoCardPresentedToy: PlacedToy? = nil
    var highlightedToy: PlacedToy? = nil
    var toyToPlace: PlaceableToy? { isPlacementPossible ? selectedToy : nil }
    var userDraggedAnToy = false

    var planeToProjectOnFound = false

    var activeCollisions = 0
    var collisionDetected: Bool { activeCollisions > 0 }
    var dragInProgress = false
    var userPlacedAToy = false
    var deviceAnchorPresent = false
    var planeAnchorsPresent = false

    var shouldShowPreview: Bool {
        return deviceAnchorPresent && planeAnchorsPresent && !dragInProgress && highlightedToy == nil
    }

    var isPlacementPossible: Bool {
        return selectedToy != nil && shouldShowPreview && planeToProjectOnFound && !collisionDetected && !dragInProgress
    }
}
