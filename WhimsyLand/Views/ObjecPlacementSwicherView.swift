//
//  ObjecPlacementSwicherView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/22/25.
//

import SwiftUI

struct ObjectPlacementSwitcherView: View {
    var mixedImmersiveState: MixedImmersiveState
    var placeableItemStore: PlaceableItemStore
    @State private var placementManager = PlacementManager()
    @Environment(ViewModel.self) var model

    var body: some View {
        Group {
            if mixedImmersiveState.mixedImmersiveMode == .editing {
                ObjectPlacementEditView(mixedImmersiveState: mixedImmersiveState, placeableItemStore: placeableItemStore)
                    .environment(placementManager)
            } else {
                ObjectPlacementView(mixedImmersiveState: mixedImmersiveState, placeableItemStore: placeableItemStore)
                    .environment(placementManager)
            }
        }
    }
}
