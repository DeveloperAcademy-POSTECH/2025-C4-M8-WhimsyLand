//
//  ToyPlacementSwicherView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/22/25.
//

import SwiftUI

struct ToyPlacementSwitcherView: View {
    var mixedImmersiveState: MixedImmersiveState
    var placeableToyStore: PlaceableToyStore
    @State private var placementManager = PlacementManager()
    @Environment(ViewModel.self) var model
    
    var body: some View {
        Group {
            if mixedImmersiveState.mixedImmersiveMode == .editing {
                ToyPlacementEditView(mixedImmersiveState: mixedImmersiveState, placeableToyStore: placeableToyStore)
                    .environment(placementManager)
            } else {
                ToyPlacementView(mixedImmersiveState: mixedImmersiveState, placeableToyStore: placeableToyStore)
                    .environment(placementManager)
            }
        }
    }
}
