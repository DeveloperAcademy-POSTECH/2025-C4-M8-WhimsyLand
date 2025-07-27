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
                FullInfoCard()
                    .environment(placementManager)
                    .environment(model)
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
                
                placementManager.setHighlightedToy(tappedToy)
            } else {
                print("tappedToy를 찾을 수 없음")
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
