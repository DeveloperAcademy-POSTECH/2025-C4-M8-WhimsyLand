//
//  ToyPlacementEditView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/11/25.
//

import RealityKit
import SwiftUI

@MainActor
struct ToyPlacementEditView: View {
    @Environment(PlacementManager.self) var placementManager
    
    @State private var collisionBeganSubscription: EventSubscription? = nil
    @State private var collisionEndedSubscription: EventSubscription? = nil
    
    var mixedImmersiveState: MixedImmersiveState
    var placeableToyStore: PlaceableToyStore
    
    private enum Attachments {
        case placementTooltip
        case deleteButton
    }
    
    var body: some View {
        
        RealityView { content, attachments in
            content.add(placementManager.rootEntity)
            placementManager.mixedImmersiveState = mixedImmersiveState
            placementManager.placeableToyStore = placeableToyStore
            
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
                await placementManager.runARKitSession()
            }
        } update: { update, attachments in
            let placementState = placementManager.placementState
            
            if let placementTooltip = attachments.entity(for: Attachments.placementTooltip) {
                placementTooltip.isEnabled = (placementState.selectedToy != nil && placementState.shouldShowPreview)
            }
            
            if let selectedToy = placementState.selectedToy {
                selectedToy.isPreviewActive = placementState.isPlacementPossible
            }
        } attachments: {
            Attachment(id: Attachments.placementTooltip) {
                PlacementTooltip(placementState: placementManager.placementState)
            }
            
            Attachment(id: Attachments.deleteButton) {
                DeleteButton {
                    Task {
                        await placementManager.removeHighlightedToy()
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
            await placementManager.checkIfAnchoredToysNeedToBeDetached()
        }
        .task {
            await placementManager.checkIfMovingToysCanBeAnchored()
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { event in
            if event.entity.components[CollisionComponent.self]?.filter.group == PlaceableToy.previewCollisionGroup {
                placementManager.placeSelectedToy()
            }
        })
        .gesture(DragGesture()
            .targetedToAnyEntity()
            .handActivationBehavior(.pinch) // Prevent moving toys by direct touch.
            .onChanged { value in
                if value.entity.components[CollisionComponent.self]?.filter.group == PlacedToy.collisionGroup {
                    placementManager.updateDrag(value: value)
                }
            }
            .onEnded { value in
                if value.entity.components[CollisionComponent.self]?.filter.group == PlacedToy.collisionGroup {
                    placementManager.endDrag()
                }
            }
        )
        .onAppear() {
            print("Entering immersive edit mode.")
            mixedImmersiveState.mixedImmersiveSpaceOpened(with: placementManager)
            mixedImmersiveState.mixedImmersiveMode = .editing
        }
        .onDisappear() {
            print("Leaving immersive edit mode.")
        }
    }
}
