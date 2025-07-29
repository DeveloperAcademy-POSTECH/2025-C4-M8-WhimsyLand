//
//  ToyPlacementSwitcherView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/22/25.
//

import SwiftUI

struct ToyPlacementSwitcherView: View {
    @Environment(ToyModel.self) var toyModel
    
    @State private var placementManager = PlacementManager()
    
    var mixedImmersiveState: MixedImmersiveState
    var placeableToyStore: PlaceableToyStore
    
    var body: some View {
        
        Group {
            if mixedImmersiveState.mixedImmersiveMode == .editing {
                ToyPlacementEditView(mixedImmersiveState: mixedImmersiveState, placeableToyStore: placeableToyStore)
                    .environment(placementManager)
                    .environment(toyModel)
            } else {
                ToyPlacementView(mixedImmersiveState: mixedImmersiveState, placeableToyStore: placeableToyStore)
                    .environment(placementManager)
                    .environment(toyModel)
            }
        }
    }
}
