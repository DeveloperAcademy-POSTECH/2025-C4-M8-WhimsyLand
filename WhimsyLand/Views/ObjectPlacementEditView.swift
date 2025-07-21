//
//  ObjectPlacementEditView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/11/25.
//

import RealityKit
import SwiftUI

@MainActor
struct ObjectPlacementEditView: View {
    var mixedImmersiveState: MixedImmersiveState
    
    @State private var placementManager = PlacementManager()
    @State private var collisionBeganSubscription: EventSubscription? = nil
    @State private var collisionEndedSubscription: EventSubscription? = nil
    
    private enum Attachments {
        case placementTooltip
        case deleteButton
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
        }
        .task {
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
            
            if tappedEntity.components[CollisionComponent.self]?.filter.group == PlaceableObject.previewCollisionGroup {
                    placementManager.placeSelectedObject()
                    return
                }
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
            print("Entering immersive edit mode.")
            mixedImmersiveState.mixedImmersiveSpaceOpened(with: placementManager)
        }
        .onDisappear() {
            print("Leaving immersive edit mode.")
            mixedImmersiveState.didLeaveMixedImmersiveSpace()
        }
    }
}
