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

    @State private var placementManager = PlacementManager()

    private enum Attachments {
        case infoCard
    }

    var body: some View {
        RealityView { content, attachments in
            content.add(placementManager.rootEntity)
            placementManager.mixedImmersiveState = mixedImmersiveState

            if let infoCardAttachment = attachments.entity(for: Attachments.infoCard) {
                placementManager.fullInfoCard = infoCardAttachment
            }

            Task {
                await placementManager.runARKitSession()
            }
        } attachments: {
            Attachment(id: Attachments.infoCard) {
                InfoCardSwitcher()
                    .environment(placementManager)
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
        .onAppear {
            print("Entering immersive view-only mode.")
            mixedImmersiveState.mixedImmersiveSpaceOpened(with: placementManager)
        }
        .onDisappear {
            print("Leaving immersive view-only mode.")
            mixedImmersiveState.didLeaveMixedImmersiveSpace()
        }
        .gesture(SpatialTapGesture().targetedToAnyEntity().onEnded { event in
            let tappedEntity = event.entity
            if let tappedObject = placementManager.placedObject(for: tappedEntity) {
                    if placementManager.placementState.infoCardPresentedObject != tappedObject {
                        placementManager.placementState.infoCardPresentedObject = tappedObject
                    }
                }
        })
    }
}
