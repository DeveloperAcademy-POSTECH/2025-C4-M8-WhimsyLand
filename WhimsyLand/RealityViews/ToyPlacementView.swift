//
//  ToyPlacementView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/22/25.
//

import SwiftUI
import RealityKit

@MainActor
struct ToyPlacementView: View {
    var mixedImmersiveState: MixedImmersiveState
    var placeableToyStore: PlaceableToyStore
    
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
            placementManager.placeableToyStore = placeableToyStore

            if let infoCardAttachment = attachments.entity(for: Attachments.infoCard) {
                placementManager.fullInfoCard = infoCardAttachment
            }
            
            Task {
                await placementManager.runARKitSession()
            }
        } attachments: {
            Attachment(id: Attachments.infoCard) {
                let fileName = placementManager.placementState.infoCardPresentedToyFileName
                
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
            if let tappedToy = placementManager.placedToy(for: tappedEntity) {
                if placementManager.placementState.infoCardPresentedToy == tappedToy {
                    placementManager.placementState.infoCardPresentedToy = nil
                } else {
                    placementManager.placementState.infoCardPresentedToy = tappedToy
                }
                placementManager.setTappedToy(tappedToy)
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
