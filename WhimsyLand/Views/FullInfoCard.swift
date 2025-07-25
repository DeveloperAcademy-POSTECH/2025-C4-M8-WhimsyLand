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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("셋째 돼지의 집")
                .font(.title2.bold())
            Text("셋째 돼지는 늑대의 침입에 대비해 튼튼히 지었어요.\n방 안을 천천히 탐색해보며 즐겨보세요.\n솥에 불을 붙여 늑대를 막을 준비를 해주세요!")
                .font(.body)
                .multilineTextAlignment(.leading)
            Button("시작하기") {
                if model.immersiveSpaceState != .inTransition {
                    Task {
                        await model.switchToImmersiveMode(.full)
                    }
                }
            }
            .buttonStyle(.bordered)
            Button("닫기"){
                manager.placementState.infoCardPresentedObject = nil
                manager.infoCardAlreadyOriented = false
            }
        }
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
        .frame(width: 320)
    }
}
