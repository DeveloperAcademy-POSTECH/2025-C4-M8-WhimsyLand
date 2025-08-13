//
//  FullImmersiveSwitcherView.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/27/25.
//

import SwiftUI

struct FullImmersiveSwitcherView: View {
    @Environment(ViewModel.self) private var viewModel
    @Environment(ToyModel.self) var toyModel
    
    var body: some View {
        Group {
            switch viewModel.fullImmersiveContent{
            case .none:
                EmptyView()
            case .FirstHouse:
                FirstHouse()
                    .environment(viewModel)
                    .environment(toyModel)
            case .SecondHouse:
                SecondHouse()
                    .environment(viewModel)
                    .environment(toyModel)
            case .ThirdHouse:
                ThirdHouse()
                    .environment(viewModel)
                    .environment(toyModel)
            }
        }
    }
}
