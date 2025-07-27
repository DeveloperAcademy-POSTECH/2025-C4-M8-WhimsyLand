//
//  ObjectPlacementView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/22/25.
//

import SwiftUI
import RealityKit

@MainActor
struct ObjectPlacementView: View {
    var mixedImmersiveState: MixedImmersiveState
    var placeableItemStore: PlaceableItemStore
    
    @Environment(PlacementManager.self) var placementManager
    @Environment(ViewModel.self) var model
    @Environment(ToyModel.self) var toyModel
    
    private enum Attachments {
        case infoCard
    }
    
    var body: some View {
        RealityView { content, attachments in
            content.add(placementManager.rootEntity)
            placementManager.mixedImmersiveState = mixedImmersiveState
            placementManager.placeableItemStore = placeableItemStore
            
            if let infoCardAttachment = attachments.entity(for: Attachments.infoCard) {
                placementManager.fullInfoCard = infoCardAttachment
            }
            
            Task {
                await placementManager.runARKitSession()
            }
        } attachments: {
            Attachment(id: Attachments.infoCard) {
                let fileName = placementManager.placementState.infoCardPresentedObjectFileName
                
                if let item = toyModel.items.first(where: { $0.ImageName == fileName }),
                   item.fullInfoCardContent != nil {
                    FullInfoCard()
                        .environment(placementManager)
                        .environment(model)
                } else {
                    EmptyView()
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
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { event in
            let tappedEntity = event.entity
            if let tappedObject = placementManager.placedObject(for: tappedEntity) {
                if placementManager.placementState.infoCardPresentedObject == tappedObject {
                    placementManager.placementState.infoCardPresentedObject = nil
                } else {
                    placementManager.placementState.infoCardPresentedObject = tappedObject
                }
                
                placementManager.setHighlightedObject(tappedObject)
            }
        })
        .onAppear {
            print("Entering immersive view-only mode.")
            mixedImmersiveState.mixedImmersiveSpaceOpened(with: placementManager)
            mixedImmersiveState.mixedImmersiveMode = .viewing
        }
        .onDisappear {
            print("Leaving immersive view-only mode.")
        }
    }
}
