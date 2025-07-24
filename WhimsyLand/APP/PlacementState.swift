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

    var selectedObject: PlaceableObject? = nil
    var infoCardPresentedObject: PlacedObject? = nil
    var highlightedObject: PlacedObject? = nil
    var objectToPlace: PlaceableObject? { isPlacementPossible ? selectedObject : nil }
    var userDraggedAnObject = false

    var planeToProjectOnFound = false

    var activeCollisions = 0
    var collisionDetected: Bool { activeCollisions > 0 }
    var dragInProgress = false
    var userPlacedAnObject = false
    var deviceAnchorPresent = false
    var planeAnchorsPresent = false

    var shouldShowPreview: Bool {
        return deviceAnchorPresent && planeAnchorsPresent && !dragInProgress && highlightedObject == nil
    }

    var isPlacementPossible: Bool {
        return selectedObject != nil && shouldShowPreview && planeToProjectOnFound && !collisionDetected && !dragInProgress
    }
}
