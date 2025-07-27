//
//  FullInfoCard.swift
//  WhimsyLand
//
//  Created by 제하맥프로 on 7/21/25.
//

import SwiftUI

struct FullInfoCard: View {
    @Environment(\.openImmersiveSpace) private var openImmersiveSpace
    @Environment(\.dismissImmersiveSpace) private var dismissImmersiveSpace
    @Environment(ViewModel.self) var model
    @Environment(PlacementManager.self) var manager
    @Environment(ToyModel.self) var toyModel
    
    var toyItemFileName: String {
        manager.placementState.infoCardPresentedToyFileName
    }
    var toyItem: ToyItem? {
        toyModel.items.first { $0.ImageName == toyItemFileName }
    }
    
    var body: some View {
        if let toyItem = toyItem {
            VStack(alignment: .center) {
                Text(toyItem.module?.name ?? "")
                    .font(.pretendard(.semibold, size: 42))
                Text(toyItem.fullInfoCardContent?.description ?? "")
                    .font(.pretendard(.regular, size: 24))
                    .padding(.vertical, 1)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                HStack(spacing: 16) {
                    EnterFullButton(toyItem: toyItem)
                        .environment(model)
                    
                    Button(action: {
                        manager.placementState.infoCardPresentedToy = nil
                        manager.infoCardAlreadyOriented = false
                    }) {
                        Image(systemName: "xmark")
                            .font(.pretendard(.semibold, size: 18))
                    }
                    .frame(width: 44, height: 44)
                    .contentShape(Circle()
                    )
                    .buttonStyle(.plain)
                    .background(.ultraThinMaterial, in: Circle()
                    )
                    .padding(.top, 34)
                }
            }
            .padding(.vertical, 44)
            .padding(.horizontal, 100)
            .glassBackgroundEffect()
        } else {
            EmptyView()
        }
    }
}

#Preview {
    FullInfoCard()
        .environment(ViewModel())
        .environment(PlacementManager())
}
