//
//  ObjecPlacementSwicherView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/22/25.
//

import SwiftUI

struct ObjectPlacementSwitcherView: View {
    var mixedImmersiveState: MixedImmersiveState

    var body: some View {
        Group {
            if mixedImmersiveState.mixedImmersiveMode == .editing {
                ObjectPlacementEditView(mixedImmersiveState: mixedImmersiveState)
            } else {
                ObjectPlacementView(mixedImmersiveState: mixedImmersiveState)
            }
        }
    }
}
