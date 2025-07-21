//
//  ObjectPlacementRealityView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/11/25.
//

import RealityKit
import SwiftUI

@MainActor
struct ObjectPlacementRealityView: View {
    var mixedImmersiveState: MixedImmersiveState
    
    @State private var placementManager = PlacementManager()
    @State private var collisionBeganSubscription: EventSubscription? = nil
    @State private var collisionEndedSubscription: EventSubscription? = nil
    
    private enum Attachments {
        case placementTooltip
        case deleteButton
        case infoCard
    }
    
    var body: some View {
        RealityView { content, attachments in
            content.add(placementManager.rootEntity)
            placementManager.mixedImmersiveState = mixedImmersiveState
            
            if let placementTooltipAttachment = attachments.entity(for: Attachments.placementTooltip) {
                placementManager.addPlacementTooltip(placementTooltipAttachment)
            }
            
            if let deleteButtonAttachment = attachments.entity(for: Attachments.deleteButton) {
                placementManager.deleteButton = deleteButtonAttachment
            }
            
            if let infoCardAttachment = attachments.entity(for: Attachments.infoCard) {
                placementManager.fullInfoCard = infoCardAttachment
            }
            
            collisionBeganSubscription = content.subscribe(to: CollisionEvents.Began.self) {  [weak placementManager] event in
                placementManager?.collisionBegan(event)
            }
            
            collisionEndedSubscription = content.subscribe(to: CollisionEvents.Ended.self) {  [weak placementManager] event in
                placementManager?.collisionEnded(event)
            }
            
            Task {
                // Run the ARKit session after the user opens the immersive space.
                await placementManager.runARKitSession()
            }
        } update: { update, attachments in
            let placementState = placementManager.placementState
            
            if let placementTooltip = attachments.entity(for: Attachments.placementTooltip) {
                placementTooltip.isEnabled = (placementState.selectedObject != nil && placementState.shouldShowPreview)
            }
            
            if let selectedObject = placementState.selectedObject {
                selectedObject.isPreviewActive = placementState.isPlacementPossible
            }
            
            
        } attachments: {
            Attachment(id: Attachments.placementTooltip) {
                PlacementTooltip(placementState: placementManager.placementState)
            }
            
            Attachment(id: Attachments.deleteButton) {
                DeleteButton {
                    Task {
                        await placementManager.removeHighlightedObject()
                    }
                }
            }
            
            Attachment(id: Attachments.infoCard) {
                InfoCardSwitcher()
                    .environment(placementManager)
            }
        }
        .task {
            // Monitor ARKit anchor updates once the user opens the immersive space.
            //
            // Tasks attached to a view automatically receive a cancellation
            // signal when the user dismisses the view. This ensures that
            // loops that await anchor updates from the ARKit data providers
            // immediately end.
            await placementManager.processWorldAnchorUpdates()
        }
        .task {
            await placementManager.processDeviceAnchorUpdates()
        }
        .task {
            await placementManager.processPlaneDetectionUpdates()
        }
        .task {
            await placementManager.checkIfAnchoredObjectsNeedToBeDetached()
        }
        .task {
            await placementManager.checkIfMovingObjectsCanBeAnchored()
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { event in
            let tappedEntity = event.entity
            
            // 오브젝트 배치 시도
            if tappedEntity.components[CollisionComponent.self]?.filter.group == PlaceableObject.previewCollisionGroup {
                    placementManager.placeSelectedObject()
                    return
                }
            // 2. 탭한 엔티티가 오브젝트인 경우 InfoCard를 열도록 설정
            // 보류
        })
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .handActivationBehavior(.pinch) // Prevent moving objects by direct touch.
            .onChanged { value in
                if value.entity.components[CollisionComponent.self]?.filter.group == PlacedObject.collisionGroup {
                    placementManager.updateDrag(value: value)
                }
            }
            .onEnded { value in
                if value.entity.components[CollisionComponent.self]?.filter.group == PlacedObject.collisionGroup {
                    placementManager.endDrag()
                }
            }
        )
        .onAppear() {
            print("Entering immersive space.")
            mixedImmersiveState.mixedImmersiveSpaceOpened(with: placementManager)
        }
        .onDisappear() {
            print("Leaving immersive space.")
            mixedImmersiveState.didLeaveMixedImmersiveSpace()
        }
    }
}
