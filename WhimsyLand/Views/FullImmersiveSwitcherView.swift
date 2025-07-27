//
//  FullImmersiveSwitcherView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/27/25.
//

import SwiftUI

struct FullImmersiveSwitcherView: View {
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(ViewModel.self) private var model
    @Environment(ToyModel.self) var toyModel
    
    var body: some View {
        Group {
            switch model.fullImmersiveContent{
            case .none:
                EmptyView()
            case .ragHouse:
                TestRagHouse()
                    .environment(model)
                    .environment(toyModel)
            case .treeHouse:
                TestTreeHouse()
                    .environment(model)
                    .environment(toyModel)
            case .brickHouse:
                TestBrickHouse()
                    .environment(model)
                    .environment(toyModel)
            }
        }
    }
}
