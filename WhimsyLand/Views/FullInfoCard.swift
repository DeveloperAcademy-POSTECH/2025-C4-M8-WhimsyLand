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
    
    let toyModel = ToyModel()
    var item: ToyItem {
        toyModel.items[2]
    }
    
    var body: some View {
        VStack(alignment: .center) {
            Text(item.module?.name ?? "")
                .font(.pretendard(.semibold, size: 42))
            Text(item.fullInfoCardContent?.description ?? "")
                .font(.pretendard(.regular, size: 24))
                .padding(.vertical, 1)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
            HStack(spacing: 16) {
                Button {
                    Task {
                        await model.switchToImmersiveMode(
                            .full,
                            open: { id in await openImmersiveSpace(id: id) },
                            dismiss: dismissImmersiveSpace.callAsFunction
                        )
                    }
                } label: {
                    Text("시작하기")
                        .font(.pretendard(.semibold, size: 24))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                }
                .buttonStyle(.bordered)
                .padding(.top, 34)

                Button(action: {
                    manager.placementState.infoCardPresentedObject = nil
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
    }
}

#Preview {
    FullInfoCard()
        .environment(ViewModel())
        .environment(PlacementManager())
}
