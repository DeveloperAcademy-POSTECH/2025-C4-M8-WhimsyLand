//
//  PlacementManager.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/10/25.
//

import Foundation
import ARKit
import RealityKit
import QuartzCore
import SwiftUI

@Observable
final class PlacementManager {
    private let worldTracking = WorldTrackingProvider()
    private let planeDetection = PlaneDetectionProvider()
    
    private var planeAnchorHandler: PlaneAnchorHandler
    private var persistenceManager: PersistenceManager
    
    var mixedImmersiveState: MixedImmersiveState? = nil
    
    var placeableToyStore: PlaceableToyStore? = nil {
        didSet {
            persistenceManager.placeableToysByFileName = placeableToyStore?.placeableToysByFileName ?? [:]
        }
    }
    
    private var currentDrag: DragState? = nil {
        didSet {
            placementState.dragInProgress = currentDrag != nil
        }
    }
    
    var placementState = PlacementState()
    
    var rootEntity: Entity
    
    private let deviceLocation: Entity
    private let raycastOrigin: Entity
    private let placementLocation: Entity
    private weak var placementTooltip: Entity? = nil
    weak var deleteButton: Entity? = nil
    weak var fullInfoCard: Entity? = nil
    
    // 현실 평면과 Toy 사이 간격 조정
    static private let placedToysOffsetOnPlanes: Float = 0.01
    
    // 근처에 있는 평면으로 자동 스냅되는 간격 조정
    static private let snapToPlaneDistanceForDraggedToys: Float = 0.04
    
    // info Card 고정
    var infoCardAlreadyOriented: Bool = false
    
    @MainActor
    init() {
        // 위치 관련 Entity 값 초기화
        let root = Entity()
        rootEntity = root
        placementLocation = Entity()
        deviceLocation = Entity()
        raycastOrigin = Entity()
        
        // 평면 감지
        // 월드 앵커 불러오기
        planeAnchorHandler = PlaneAnchorHandler(rootEntity: root)
        persistenceManager = PersistenceManager(worldTracking: worldTracking, rootEntity: root)
        persistenceManager.loadPersistedToys()
        
        rootEntity.addChild(placementLocation)
        
        deviceLocation.addChild(raycastOrigin)
        
        // Angle raycasts 15 degrees down.
        // 평면 인식을 위한 각도 조절
        let raycastDownwardAngle = 15.0 * (Float.pi / 180)
        raycastOrigin.orientation = simd_quatf(angle: -raycastDownwardAngle, axis: [1.0, 0.0, 0.0])
    }
    
    // 배치된 Toy 저장 함수
    func saveWorldAnchorsToysMapToDisk() {
        persistenceManager.saveWorldAnchorsToysMapToDisk()
    }
    
    // 배치 불가 안내 메시지를 띄우는 함수
    @MainActor
    func addPlacementTooltip(_ tooltip: Entity) {
        placementTooltip = tooltip
        placementLocation.addChild(tooltip)
        tooltip.position = [0.0, 0.05, 0.15]
    }
    
    // Toy 삭제 함수
    func removeHighlightedToy() async {
        if let highlightedToy = placementState.highlightedToy {
            await persistenceManager.removeToy(highlightedToy)
        }
    }
    
    @MainActor
    func runARKitSession() async {
        do {
            // 평면 인식, 기기 방향과 위치 추적
            try await mixedImmersiveState!.arkitSession.run([worldTracking, planeDetection])
        } catch {
            // AppState에서 에러 감지 중이므로 별도 처리 X
            return
        }
        
        if let firstFileName = placeableToyStore?.modelDescriptors.first?.fileName, let toy = placeableToyStore?.placeableToysByFileName[firstFileName] {
            selectToy(toy)
        }
    }
    
    // MARK: Toy 충돌 관리
    @MainActor
    func collisionBegan(_ event: CollisionEvents.Began) {
        guard let selectedToy = placementState.selectedToy else { return }
        guard selectedToy.matchesCollisionEvent(event: event) else { return }
        
        placementState.activeCollisions += 1
    }
    
    @MainActor
    func collisionEnded(_ event: CollisionEvents.Ended) {
        guard let selectedToy = placementState.selectedToy else { return }
        guard selectedToy.matchesCollisionEvent(event: event) else { return }
        guard placementState.activeCollisions > 0 else {
            print("Received a collision ended event without a corresponding collision start event.")
            return
        }
        
        placementState.activeCollisions -= 1
    }
    
    // MARK: Toy 선택 관리
    @MainActor
    func deselectCurrentToy() {
        if let oldSelection = placementState.selectedToy {
            // Remove the preview entity from the scene.
            placementLocation.removeChild(oldSelection.previewEntity)
            placementState.selectedToy = nil
            placeableToyStore?.selectedFileName = nil
        }
    }
    
    @MainActor
    func selectToy(_ toy: PlaceableToy?) {
        deselectCurrentToy()
        
        placementState.selectedToy = toy
        placeableToyStore?.selectedFileName = toy?.descriptor.fileName
        
        if let toy {
            placementLocation.addChild(toy.previewEntity)
        }
    }
    
    // MARK: Anchor 업데이트 처리
    @MainActor
    func processWorldAnchorUpdates() async {
        for await anchorUpdate in worldTracking.anchorUpdates {
            persistenceManager.process(anchorUpdate)
        }
    }
    
    @MainActor
    func processDeviceAnchorUpdates() async {
        await run(function: self.queryAndProcessLatestDeviceAnchor, withFrequency: 90)
    }
    
    // MARK: 현재 상태와 위치에 따라서 실시간 UI 업데이트
    @MainActor
    private func queryAndProcessLatestDeviceAnchor() async {
        // Device anchors are only available when the provider is running.
        guard worldTracking.state == .running else { return }
        
        let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: CACurrentMediaTime())
        
        placementState.deviceAnchorPresent = deviceAnchor != nil
        placementState.planeAnchorsPresent = !planeAnchorHandler.planeAnchors.isEmpty
        placementState.selectedToy?.previewEntity.isEnabled = placementState.shouldShowPreview
        
        guard let deviceAnchor, deviceAnchor.isTracked else { return }
        
        await updateUserFacingUIOrientations(deviceAnchor)
        await checkWhichToyDeviceIsPointingAt(deviceAnchor)
        await updatePlacementLocation(deviceAnchor)
    }
    
    // MARK: AR의 UI가 사용자를 향하도록 조정
    @MainActor
    private func updateUserFacingUIOrientations(_ deviceAnchor: DeviceAnchor) async {
        //1. UI가 사용자를 바라보도록 조정
        if let uiOrigin = placementState.highlightedToy?.uiOrigin {
            // Set the UI to face the user (on the y-axis only).
            uiOrigin.look(at: deviceAnchor.originFromAnchorTransform.translation)
            let uiRotationOnYAxis = uiOrigin.transformMatrix(relativeTo: nil).gravityAligned.rotation
            uiOrigin.setOrientation(uiRotationOnYAxis, relativeTo: nil)
        }
        
        //2. Orient each UI element to face the user.
        for entity in [placementTooltip, deleteButton] {
            if let entity {
                entity.look(at: deviceAnchor.originFromAnchorTransform.translation)
            }
        }
    }
    
    // MARK: Toy 배치 미리보기
    @MainActor
    private func updatePlacementLocation(_ deviceAnchor: DeviceAnchor) async {
        deviceLocation.transform = Transform(matrix: deviceAnchor.originFromAnchorTransform)
        let originFromUprightDeviceAnchorTransform = deviceAnchor.originFromAnchorTransform.gravityAligned
        
        // Determine a placement location on planes in front of the device by casting a ray.
        
        // Cast the ray from the device origin.
        let origin: SIMD3<Float> = raycastOrigin.transformMatrix(relativeTo: nil).translation
        
        // Cast the ray along the negative z-axis of the device anchor, but with a slight downward angle.
        // (The downward angle is configurable using the `raycastOrigin` orientation.)
        let direction: SIMD3<Float> = -raycastOrigin.transformMatrix(relativeTo: nil).zAxis
        
        // Only consider raycast results that are within 0.2 to 3 meters from the device.
        let minDistance: Float = 0.2
        let maxDistance: Float = 3
        
        // Only raycast against horizontal planes.
        let collisionMask = PlaneAnchor.allPlanesCollisionGroup
        
        var originFromPointOnPlaneTransform: float4x4? = nil
        if let result = rootEntity.scene?.raycast(origin: origin, direction: direction, length: maxDistance, query: .nearest, mask: collisionMask)
            .first, result.distance > minDistance {
            if result.entity.components[CollisionComponent.self]?.filter.group != PlaneAnchor.verticalCollisionGroup {
                // If the raycast hit a horizontal plane, use that result with a small, fixed offset.
                originFromPointOnPlaneTransform = originFromUprightDeviceAnchorTransform
                originFromPointOnPlaneTransform?.translation = result.position + [0.0, PlacementManager.placedToysOffsetOnPlanes, 0.0]
            }
        }
        
        if let originFromPointOnPlaneTransform {
            placementLocation.transform = Transform(matrix: originFromPointOnPlaneTransform)
            placementState.planeToProjectOnFound = true
        } else {
            // If no placement location can be determined, position the preview 50 centimeters in front of the device.
            let distanceFromDeviceAnchor: Float = 0.5
            let downwardsOffset: Float = 0.3
            var uprightDeviceAnchorFromOffsetTransform = matrix_identity_float4x4
            uprightDeviceAnchorFromOffsetTransform.translation = [0, -downwardsOffset, -distanceFromDeviceAnchor]
            let originFromOffsetTransform = originFromUprightDeviceAnchorTransform * uprightDeviceAnchorFromOffsetTransform
            
            placementLocation.transform = Transform(matrix: originFromOffsetTransform)
            placementState.planeToProjectOnFound = false
        }
    }
    
    // MARK: 바라보고 있는 Toy 하이라이트
    @MainActor
    private func checkWhichToyDeviceIsPointingAt(_ deviceAnchor: DeviceAnchor) async {
        let origin: SIMD3<Float> = raycastOrigin.transformMatrix(relativeTo: nil).translation
        let direction: SIMD3<Float> = -raycastOrigin.transformMatrix(relativeTo: nil).zAxis
        let collisionMask = PlacedToy.collisionGroup
        
        if let result = rootEntity.scene?.raycast(origin: origin, direction: direction, query: .nearest, mask: collisionMask).first {
            
            if let pointedAtToy = persistenceManager.toy(for: result.entity) {
                setHighlightedToy(pointedAtToy)
            } else {
                setHighlightedToy(nil)
            }
        } else {
            setHighlightedToy(nil)
        }
    }
    
    @MainActor
    func setHighlightedToy(_ toyToHighlight: PlacedToy?) {
        guard placementState.highlightedToy != toyToHighlight else {
            return
        }
        
        if let oldHighlighted = placementState.highlightedToy {
            oldHighlighted.renderContent.components.remove(HoverEffectComponent.self)
        }
        
        placementState.highlightedToy = toyToHighlight
        
        // 이전 Toy 하이라이트 해제
        deleteButton?.removeFromParent()
        
        guard let toyToHighlight else { return }
        
        // Position and attach the UI to the newly highlighted toy.
        let extents = toyToHighlight.extents
        let topLeftCorner: SIMD3<Float> = [-extents.x / 2, (extents.y / 2) + 0.02, 0]
        deleteButton?.position = topLeftCorner
        
        if mixedImmersiveState?.mixedImmersiveMode == .editing {
            if let deleteButton {
                toyToHighlight.uiOrigin.addChild(deleteButton)
                deleteButton.scale = 1 / toyToHighlight.scale
            }
        }
        
        let highlightStyle = HoverEffectComponent.HighlightHoverEffectStyle(
            color: .white, // 디자이너와 협의 후 수정 필요
            strength: 0.8
        )
        
        let hoverEffect = HoverEffectComponent(.highlight(highlightStyle))
        toyToHighlight.components.set(hoverEffect)
    }
    
    @MainActor
    func setTappedToy(_ ToyToPresentInfoCard: PlacedToy?) {
        guard placementState.infoCardPresentedToy != ToyToPresentInfoCard else {
            return
        }
        
        placementState.infoCardPresentedToy = ToyToPresentInfoCard
        
        if let previousParent = fullInfoCard?.parent, previousParent != ToyToPresentInfoCard {
            previousParent.removeChild(fullInfoCard!)
        }
        
        // 이전 Toy의 fullInfoCard 해제
        // fullInfoCard?.removeFromParent()
        
        guard let ToyToPresentInfoCard else { return }
        
        // Position and attach the UI to the newly highlighted toy.
        let extents = ToyToPresentInfoCard.extents
        let topCenter: SIMD3<Float> = [0, extents.y * 1 + 0.2, 0]
        fullInfoCard?.position = topCenter
        
        if mixedImmersiveState?.mixedImmersiveMode == .viewing{
            if let fullInfoCard,
               placementState.infoCardPresentedToy == ToyToPresentInfoCard,
               fullInfoCard.parent != ToyToPresentInfoCard {
                
                ToyToPresentInfoCard.addChild(fullInfoCard)
                fullInfoCard.scale = 1 / ToyToPresentInfoCard.scale
                fullInfoCard.look(at: deviceLocation.position(relativeTo: nil))
                infoCardAlreadyOriented = true
            }
        }
    }
    
    func processPlaneDetectionUpdates() async {
        for await anchorUpdate in planeDetection.anchorUpdates {
            await planeAnchorHandler.process(anchorUpdate)
        }
    }
    
    // MARK: Toy 배치 및 고정
    @MainActor
    func placeSelectedToy() {
        // Ensure there’s a placeable toy.
        guard let toyToPlace = placementState.toyToPlace else { return }
        
        let toy = toyToPlace.materialize()
        toy.position = placementLocation.position
        toy.orientation = placementLocation.orientation
        
        Task {
            await persistenceManager.attachToyToWorldAnchor(toy)
        }
        placementState.userPlacedAToy = true
        
        deselectCurrentToy()
    }
    
    @MainActor
    func checkIfAnchoredToysNeedToBeDetached() async {
        // Check whether toys should be detached from their world anchor.
        // This runs at 10 Hz to ensure that toys are quickly detached from their world anchor
        // as soon as they are moved - otherwise a world anchor update could overwrite the
        // toy’s position.
        await run(function: persistenceManager.checkIfAnchoredToysNeedToBeDetached, withFrequency: 10)
    }
    
    @MainActor
    func checkIfMovingToysCanBeAnchored() async {
        // Check whether toys can be reanchored.
        // This runs at 2 Hz - toys should be reanchored eventually but it’s not time critical.
        await run(function: persistenceManager.checkIfMovingToysCanBeAnchored, withFrequency: 2)
    }
    
    // MARK: 드래그 처리 함수
    @MainActor
    func updateDrag(value: EntityTargetValue<DragGesture.Value>) {
        if let currentDrag, currentDrag.draggedToy !== value.entity {
            // Make sure any previous drag ends before starting a new one.
            print("A new drag started but the previous one never ended - ending that one now.")
            endDrag()
        }
        
        // At the start of the drag gesture, remember which toy is being manipulated.
        if currentDrag == nil {
            guard let toy = persistenceManager.toy(for: value.entity) else {
                print("Unable to start drag - failed to identify the dragged toy.")
                return
            }
            
            toy.isBeingDragged = true
            currentDrag = DragState(toyToDrag: toy)
            placementState.userDraggedAnToy = true
        }
        
        // Update the dragged toy’s position.
        if let currentDrag {
            currentDrag.draggedToy.position = currentDrag.initialPosition + value.convert(value.translation3D, from: .local, to: rootEntity)
            
            // If possible, snap the dragged toy to a nearby horizontal plane.
            let maxDistance = PlacementManager.snapToPlaneDistanceForDraggedToys
            if let projectedTransform = PlaneProjector.project(point: currentDrag.draggedToy.transform.matrix,
                                                               ontoHorizontalPlaneIn: planeAnchorHandler.planeAnchors,
                                                               withMaxDistance: maxDistance) {
                currentDrag.draggedToy.position = projectedTransform.translation
            }
        }
    }
    
    @MainActor
    func endDrag() {
        guard let currentDrag else { return }
        currentDrag.draggedToy.isBeingDragged = false
        self.currentDrag = nil
    }
    
    @MainActor
    func placedToy(for entity: Entity) -> PlacedToy? {
        return persistenceManager.placedToy(for: entity)
    }
}

extension PlacementManager {
    /// Run a given function at an approximate frequency.
    ///
    /// > Note: This method doesn’t take into account the time it takes to run the given function itself.
    @MainActor
    func run(function: () async -> Void, withFrequency hz: UInt64) async {
        while true {
            if Task.isCancelled {
                return
            }
            
            // Sleep for 1 s / hz before calling the function.
            let nanoSecondsToSleep: UInt64 = NSEC_PER_SEC / hz
            do {
                try await Task.sleep(nanoseconds: nanoSecondsToSleep)
            } catch {
                // Sleep fails when the Task is cancelled. Exit the loop.
                return
            }
            
            await function()
        }
    }
}
