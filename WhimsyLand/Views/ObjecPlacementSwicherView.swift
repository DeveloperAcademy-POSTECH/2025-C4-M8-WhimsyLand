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
    @Environment(ToyModel.self) var toyModel

    var body: some View {
        Group {
            if mixedImmersiveState.mixedImmersiveMode == .editing {
                ObjectPlacementEditView(mixedImmersiveState: mixedImmersiveState, placeableItemStore: placeableItemStore)
                    .environment(placementManager)
                    .environment(toyModel)
            } else {
                ObjectPlacementView(mixedImmersiveState: mixedImmersiveState, placeableItemStore: placeableItemStore)
                    .environment(placementManager)
                    .environment(toyModel)
            }
        }
    }
}
